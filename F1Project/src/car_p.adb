package body car_p is

   -----------------------------------------------------------------------
   --------------------------- TASK CAR ----------------------------------
   -----------------------------------------------------------------------

   task body Car is
      --toWait : Positive;
      nextReferee : Referee_Access := initialReferee;
      speed : Float;
      previousReferee : Referee_Access;
      event : event_array_Access := new event_array;
      box_stop : Boolean;
      incident : Natural;
      toRepair : Boolean := false;
      lap : Positive := 1;
      last_lap : Boolean := false;
      race_over : Boolean := false;
      request_box : Boolean := false;

      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      --Period    :          Ada.Real_Time.Time_Span;
      toSleep   :          Ada.Real_Time.Time := Poll_Time;
      --secondsToSleep : Ada.Real_Time.Seconds_Count;
      durationToSleep : Ada.Real_Time.Time_Span;
   begin

      --Ada.Real_Time.Split(Poll_Time,secondsToSleep,durationToSleep);

      --Ada.Text_IO.Put_Line ("--> " & Ada.Real_Time.Seconds_Count'image(secondcount));	--STAMPARE Seconds_Count
      --Ada.Text_IO.Put_Line ("-DIVERSA-> " & Duration'Image(Ada.Real_Time.To_Duration(duratiosn))); --STAMPARE TIME_SPAN
      speed := status.get_currentSpeed; -- the initial speed should be zero?
      while (not race_over) loop
         --Ada.Text_IO.Put_Line ("->" & Positive'Image(status.get_name) & " ed entro nel segmento " & Positive'Image(nextReferee.id));
         previousReferee := nextReferee;

	 --here, we have inadeguated tires for rain status
         if event_buffer.isRaining xor status.get_rain_tires then
            status.Change_Tires(true);
         end if;

         -- check if tire status is below 10%
         if (status.get_tires_state < 100)
         then
            status.Change_Tires(true);
            -- if the status is below 0% the car is damaged
            if (status.get_tires_state < 0)
            then
               status.set_damage(true);
            end if;
         end if;

         -- enterSegment need to be done as first thing, in order to compensate lag
         nextReferee.enterSegment(id, status, speed, toSleep, nextReferee, box_stop, event_buffer.isRaining, incident, last_lap);
         --Ada.Real_Time.Split(toSleep,secondsToSleep,durationToSleep);
         durationToSleep := toSleep - Poll_Time;
        -- Ada.Text_IO.Put_Line ("--seconds_count--> " & Ada.Real_Time.Seconds_Count'image(secondsToSleep));	--STAMPARE Seconds_Count
         --Ada.Text_IO.Put_Line ("----time_span----> " & Duration'Image(Ada.Real_Time.To_Duration(durationToSleep))); --STAMPARE TIME_SPAN

         status.set_currentSpeed(speed); -- set new speed on status
         request_box := status.is_damaged or status.pitStop4tires;

         event (8) := Ada.Strings.Unbounded.To_Unbounded_String
           (Duration'Image(Ada.Real_Time.To_Duration(durationToSleep)));

         if (incident > 0)
         then
            event(1) := Ada.Strings.Unbounded.To_Unbounded_String("CA");
            event(2) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(id));
            if (incident = 2)
            then
               toRepair := true;
               event(3) := Ada.Strings.Unbounded.To_Unbounded_String("T");  -- car damaged
            else
               event(3) := Ada.Strings.Unbounded.To_Unbounded_String("F");  -- car not damaged
            end if;
            if (incident = 3)
            then
               race_over := true;
               race_stat.car_end_race;
               event(4) := Ada.Strings.Unbounded.To_Unbounded_String("T");  -- car retired
               previousReferee.leaveSegment(id, box_stop);
            else
               event(4) := Ada.Strings.Unbounded.To_Unbounded_String("F");  -- car not retired
            end if;
            event(5) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(previousReferee.id));

            event_buffer.insert_event(event);
         end if;

         if (not (incident = 3))
         then

            if (box_stop)
            then
               toRepair := false;
               event(1) := Ada.Strings.Unbounded.To_Unbounded_String("EB");
               event(2) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(id));
               event_buffer.insert_event(event);
               event(1) := Ada.Strings.Unbounded.To_Unbounded_String("LB");
               event(2) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(id));
               if(status.get_rain_tires)
               then
                  event(3) := Ada.Strings.Unbounded.To_Unbounded_String("T"); -- rain tires
               else
                  event(3) := Ada.Strings.Unbounded.To_Unbounded_String("F"); -- dry tires
               end if;
               event(4) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(lap)); -- ended lap
               event_buffer.insert_event(event);
               delay until toSleep;
               lap := lap + 1;
            else
               event(1) := Ada.Strings.Unbounded.To_Unbounded_String("ES");
               event(2) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(id));
               event(3) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(previousReferee.id));
               --Ada.Text_IO.Put_Line ("->" & Positive'Image(status.get_name) & " e sono vivo");
               event(4) := Ada.Strings.Unbounded.To_Unbounded_String(Integer'Image(Integer(speed)));
               --Ada.Text_IO.Put_Line ("->" & Positive'Image(status.get_name) & " e sono morto");
               event(5) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(status.get_currentBehaviour));
               event(6) := Ada.Strings.Unbounded.To_Unbounded_String(Integer'Image(status.get_tires_state));
               if(status.get_rain_tires)
               then
                  event(7) :=  Ada.Strings.Unbounded.To_Unbounded_String("T");
               else
                  event(7) :=  Ada.Strings.Unbounded.To_Unbounded_String("F");
               end if;
               if(request_box)
               then
                  event(9) :=  Ada.Strings.Unbounded.To_Unbounded_String("T");
               else
                  event(9) :=  Ada.Strings.Unbounded.To_Unbounded_String("F");
               end if;
               event_buffer.insert_event(event);
               delay until toSleep;
            end if;

            previousReferee.leaveSegment(id, box_stop);

            -- update lap
	    if (nextReferee.id = 1)
            then
               event(1) := Ada.Strings.Unbounded.To_Unbounded_String("EL"); -- end lap
               event(2) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(id));
               event(3) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(lap));
               event_buffer.insert_event(event);
	       lap := lap + 1;
               if(lap = race_stat.real_laps_number)
	       then
        	  last_lap := true;
	       end if;
            end if;

	    -- check if the race is over
            if(lap > race_stat.real_laps_number)
	    then
               race_over := true;
               event(1) := Ada.Strings.Unbounded.To_Unbounded_String("CE");
               event(2) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(id));
               event_buffer.insert_event(event);
	       race_stat.car_end_race; -- this must be done as last thing to not compromise the order of arrival
            end if;
         end if;
      end loop;

   end Car;

end car_p;
