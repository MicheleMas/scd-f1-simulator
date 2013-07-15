package body car_p is

   -----------------------------------------------------------------------
   --------------------------- CAR STATUS --------------------------------
   -----------------------------------------------------------------------

   protected body Car_Status is
      -- override procedure
      procedure Take_Fuel (order : in Boolean) is
      begin
         refuel_required := order;
      end Take_Fuel;
      procedure Change_Tires (order : in Boolean) is
      begin
         change_tires_required := order;
      end Change_Tires;
      procedure Change_Behaviour (bv : in Positive) is
      begin
         behaviour := bv;
      end Change_Behaviour;

      -- setter procedure
      procedure set_tires_status (newState : in Positive) is
      begin
         tires_status := newState;
      end set_tires_status;
      procedure set_currentSegment (currentSeg : in Segment_Access) is
      begin
         currentSegment := currentSeg;
      end set_currentSegment;
      procedure set_currentSpeed (newSpeed : in Float) is
      begin
         currentSpeed := newSpeed;
      end set_currentSpeed;
      procedure set_currentFuelLevel (newLevel : in Positive) is
      begin
         fuel_level := newLevel;
      end set_currentFuelLevel;
      procedure set_damage (status : in Boolean) is
      begin
         damaged := status;
      end set_damage;

      -- getter function
      function get_name return Positive is
      begin
         return name;
      end get_name;
      function get_tires_state return Positive is
      begin
         return tires_status;
      end get_tires_state;
      function get_currentSegment return Segment_Access is
      begin
         return currentSegment;
      end get_currentSegment;
      function get_currentSpeed return Float is
      begin
         return currentSpeed;
      end get_currentSpeed;
      function get_currentBehaviour return Positive is
      begin
         return behaviour;
      end get_currentBehaviour;
      function get_currentFuelLevel return Positive is
      begin
         return fuel_level;
      end get_currentFuelLevel;
      function is_damaged return Boolean is
      begin
         return damaged;
      end is_damaged;
   end Car_Status;

   -----------------------------------------------------------------------
   --------------------------- TASK CAR ----------------------------------
   -----------------------------------------------------------------------

   task body Car is
      toWait : Positive;
      nextReferee : Referee_Access := initialReferee;
      speed : Float;
      previousReferee : Referee_Access;
      event : Unbounded_String;

      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      Period    :          Ada.Real_Time.Time_Span;
      toSleep   :          Ada.Real_Time.Time := Poll_Time;
   begin
      speed := status.get_currentSpeed; -- the initial speed should be zero?
      loop
         --Ada.Text_IO.Put_Line ("sono la macchina " & Positive'Image(status.get_name) & " ed entro nel segmento " & Positive'Image(nextReferee.id));
         previousReferee := nextReferee;
         -- enterSegment need to be done as first thing, in order to compensate lag
      	 nextReferee.enterSegment(id, status.get_currentBehaviour, speed, status.max_speed, status.acceleration, toWait, nextReferee);

      	 status.set_currentSpeed(speed); -- set new speed on status
         Period := Ada.Real_Time.Milliseconds (toWait);
         --if(toSleep < toSleep)
         --then
         --   toSleep := toSleep + Period;
         --end if;

      	 toSleep := toSleep + Period;
      	 delay until toSleep;
         event := Ada.Strings.Unbounded.To_Unbounded_String("macchina " & Positive'Image(id) & " uscita dal segmento " & Positive'Image(previousReferee.id));
         previousReferee.leaveSegment(id);
         event_buffer.insert_event(event);
         --Ada.Text_IO.Put_Line ("--> ToWait " & Positive'Image(toWait));
      end loop;
   end Car;

end car_p;
