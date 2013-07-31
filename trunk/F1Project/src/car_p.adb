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
      incident : Boolean;

      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      --Period    :          Ada.Real_Time.Time_Span;
      toSleep   :          Ada.Real_Time.Time := Poll_Time;
   begin
      speed := status.get_currentSpeed; -- the initial speed should be zero?
      --- DEBUG, togliere!
      --- status.Take_Fuel(true);
      loop
         --Ada.Text_IO.Put_Line ("sono la macchina " & Positive'Image(status.get_name) & " ed entro nel segmento " & Positive'Image(nextReferee.id));
         previousReferee := nextReferee;

	 --here, we have inadeguated tires for rain status
         if event_buffer.isRaining xor status.get_rain_tires then
            status.Change_Tires(true);
         end if;

         if nextReferee.getSegment.isBoxEntrance and status.pitStop4tires then
		Ada.Text_IO.Put_Line ("--> Dovrei entrare in un box");
         end if;

         -- enterSegment need to be done as first thing, in order to compensate lag
         -- nextReferee.enterSegment(id, status.get_currentBehaviour, speed, status.max_speed, status.acceleration, status.get_rain_tires, toSleep, nextReferee);
         nextReferee.enterSegment(id, status, speed, toSleep, nextReferee, box_stop, event_buffer.isRaining, incident);

      	 status.set_currentSpeed(speed); -- set new speed on status
         --Period := Ada.Real_Time.Milliseconds (toWait);
         --if(toSleep < toSleep)
         --then
         --   toSleep := toSleep + Period;
         --end if;

      	 --toSleep := toSleep + Period;
      	 delay until toSleep;
         event := Ada.Strings.Unbounded.To_Unbounded_String("macchina " & Positive'Image(id) & " uscita dal segmento " & Positive'Image(previousReferee.id));
         previousReferee.leaveSegment(id, box_stop);
         event_buffer.insert_event(event);
         --Ada.Text_IO.Put_Line ("--> ToWait " & Positive'Image(toWait));
      end loop;
   end Car;

end car_p;
