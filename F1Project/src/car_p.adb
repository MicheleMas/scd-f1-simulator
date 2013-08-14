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

      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      --Period    :          Ada.Real_Time.Time_Span;
      toSleep   :          Ada.Real_Time.Time := Poll_Time;
   begin
      speed := status.get_currentSpeed; -- the initial speed should be zero?
      while (not race_over) loop
         --Ada.Text_IO.Put_Line ("sono la macchina " & Positive'Image(status.get_name) & " ed entro nel segmento " & Positive'Image(nextReferee.id));
         previousReferee := nextReferee;

	 --here, we have inadeguated tires for rain status
         if event_buffer.isRaining xor status.get_rain_tires then
            status.Change_Tires(true);
         end if;

         -- enterSegment need to be done as first thing, in order to compensate lag
         nextReferee.enterSegment(id, status, speed, toSleep, nextReferee, box_stop, event_buffer.isRaining, incident, last_lap);

         status.set_currentSpeed(speed); -- set new speed on status

         if (incident > 0)
         then
            event(1) := Ada.Strings.Unbounded.To_Unbounded_String("CA");
            if (incident = 2)
            then
               toRepair := true;
               event(2) := Ada.Strings.Unbounded.To_Unbounded_String("T");  -- car damaged
            else
               event(2) := Ada.Strings.Unbounded.To_Unbounded_String("F");  -- car not damaged
            end if;
            if (incident = 3)
            then
               race_over := true;
               race_stat.car_end_race;
               event(3) := Ada.Strings.Unbounded.To_Unbounded_String("T");  -- car retired
            else
               event(3) := Ada.Strings.Unbounded.To_Unbounded_String("F");  -- car not retired
            end if;
            event_buffer.insert_event(event);
         end if;

         if (not (incident = 3))
         then

            if (box_stop)
            then
               toRepair := false;
               event(1) := Ada.Strings.Unbounded.To_Unbounded_String("EB");
               event_buffer.insert_event(event);
               delay until toSleep;
               event(1) := Ada.Strings.Unbounded.To_Unbounded_String("LB");
               if(status.get_rain_tires)
               then
                  event(2) := Ada.Strings.Unbounded.To_Unbounded_String("T"); -- rain tires
               else
                  event(2) := Ada.Strings.Unbounded.To_Unbounded_String("F"); -- dry tires
               end if;
               event(3) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(lap)); -- ended lap
               lap := lap + 1;
	       else
                  delay until toSleep;
                  event(1) := Ada.Strings.Unbounded.To_Unbounded_String("ES");
                  event(2) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(id));
                  event(3) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(previousReferee.id));
                  event(4) := Ada.Strings.Unbounded.To_Unbounded_String(Natural'Image(Natural(speed)));
                  event(5) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(status.get_currentBehaviour));
                  event(6) := Ada.Strings.Unbounded.To_Unbounded_String(Integer'Image(status.get_tires_state));
                  if(status.get_rain_tires)
                  then
                     event(7) :=  Ada.Strings.Unbounded.To_Unbounded_String("T");
                  else
                     event(7) :=  Ada.Strings.Unbounded.To_Unbounded_String("F");
                  end if;
               end if;

               previousReferee.leaveSegment(id, box_stop);
	       event_buffer.insert_event(event);

               -- update lap
	       if (nextReferee.id = 1)
               then
                  event(1) := Ada.Strings.Unbounded.To_Unbounded_String("EL"); -- end lap
                  event(2) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(id));
        	  event_buffer.insert_event(event);
	          lap := lap + 1;
        	  if(lap = custom_types.laps_number)
	          then
        	     last_lap := true;
	          end if;
               end if;

	       -- check if the race is over
               if(lap > custom_types.laps_number)
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
