package body car_p is

   -----------------------------------------------------------------------
   --------------------------- TASK CAR ----------------------------------
   -----------------------------------------------------------------------

   task body Car is
      --toWait : Positive;
      nextReferee : Referee_Access := initialReferee;
      speed : Float;
      previousReferee : Referee_Access;
      event : Unbounded_String;
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

         --if nextReferee.getSegment.isBoxEntrance and status.pitStop4tires then
	 --	Ada.Text_IO.Put_Line ("--> Dovrei entrare in un box");
         --end if;

         -- enterSegment need to be done as first thing, in order to compensate lag
         nextReferee.enterSegment(id, status, speed, toSleep, nextReferee, box_stop, event_buffer.isRaining, incident, last_lap);

         status.set_currentSpeed(speed); -- set new speed on status

         if (incident > 0)
         then
            event := Ada.Strings.Unbounded.To_Unbounded_String("macchina " & Positive'Image(id) & " uscita di pista");
            event_buffer.insert_event(event);
         end if;

         if (incident = 2)
            then
               toRepair := true;
               event := Ada.Strings.Unbounded.To_Unbounded_String("macchina " & Positive'Image(id) & " ha riportato danni");
               event_buffer.insert_event(event);
         end if;

         if (incident = 3)
         then
            race_over := true;
            event := Ada.Strings.Unbounded.To_Unbounded_String("macchina " & Positive'Image(id) & " ha abbandonato la gara!");
            event_buffer.insert_event(event);
            race_stat.car_end_race; -- this must be done as last thing to not compromise the order of arrival
         else

         	if (box_stop)
         	then
         	   toRepair := false;
	            event := Ada.Strings.Unbounded.To_Unbounded_String("macchina " & Positive'Image(id) & " entra ai box");
        	    event_buffer.insert_event(event);
	            delay until toSleep;
        	    event := Ada.Strings.Unbounded.To_Unbounded_String("macchina " & Positive'Image(id) & " esce dai box concludendo il giro "
	                                                               & Positive'Image(lap));
        	    lap := lap + 1;
	         else
      		    delay until toSleep;
	            event := Ada.Strings.Unbounded.To_Unbounded_String("macchina " & Positive'Image(id) & " uscita dal segmento " &
        	                                                       Positive'Image(previousReferee.id) & " - giro " & Positive'Image(lap) &
                	                                               " con velocita' " & Natural'Image(Natural(speed)));
	         end if;

        	 previousReferee.leaveSegment(id, box_stop);
	         event_buffer.insert_event(event);

        	 -- update lap
	         if (nextReferee.id = 1)
        	 then
	            event := Ada.Strings.Unbounded.To_Unbounded_String("macchina " & Positive'Image(id) & " ha finito il giro " & Positive'Image(lap));
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
	            event := Ada.Strings.Unbounded.To_Unbounded_String("macchina " & Positive'Image(id) & " ha finito la gara!");
        	    event_buffer.insert_event(event);
	            race_stat.car_end_race; -- this must be done as last thing to not compromise the order of arrival
            end if;
         end if;
      end loop;

   end Car;

end car_p;
