with Ada.Real_Time;
with Ada.Text_IO;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body Circuit is

   -- place for global variables
   event_buffer : Event_Bucket_Access := new Event_Bucket(10);

   -----------------------------------------------------------------------
   --------------------------- REFEREE -----------------------------------
   -----------------------------------------------------------------------

   protected body Referee is
      function getSegment return Segment_Access is
      begin
         return seg;
      end getSegment;
      procedure setSegment (new_seg : in Segment_Access) is
      begin
         seg := new_seg;
         segmentOverridden := true;
      end setSegment;
      entry enterSegment (car_ID : in Positive;
                          car_behaviour : in Positive;
                          speed : in out Positive;
                          acceleration : in Positive;
                          toWait : out Positive;
                          nextReferee : out Referee_Access) when segmentOverridden is
      begin
         -- TEST
         -- Ada.Text_IO.Put_Line ("Initial speed = " & Positive'Image(speed));
         speed := speed + 1;
         toWait := 1000; -- TODO calculate toWait
         nextReferee := next;
      end enterSegment;
      procedure leaveSegment (car_ID : in Positive) is
      begin
         -- TODO remove car from current car list
         car_number := car_number; -- DEBUG
      end leaveSegment;
      procedure setNext (nextReferee : in Referee_Access) is
      begin
         next := nextReferee;
      end setNext;
   end Referee;

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
      procedure set_currentSpeed (newSpeed : in Positive) is
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
      function get_tires_state return Positive is
      begin
         return tires_status;
      end get_tires_state;
      function get_currentSegment return Segment_Access is
      begin
         return currentSegment;
      end get_currentSegment;
      function get_currentSpeed return Positive is
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
      speed : Positive;
      previousReferee : Referee_Access;
      event : Unbounded_String;

      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      Period    :          Ada.Real_Time.Time_Span;
      toSleep   :          Ada.Real_Time.Time := Poll_Time;
   begin
      speed := status.get_currentSpeed; -- the initial speed should be zero?
      loop
         Ada.Text_IO.Put_Line ("sono la macchina " & Positive'Image(id) & " ed entro nel segmento " & Positive'Image(nextReferee.id));
         previousReferee := nextReferee;
         -- enterSegment need to be done as first thing, in order to compensate lag
      	 nextReferee.enterSegment(id, status.get_currentBehaviour, speed, 1, toWait, nextReferee);

      	 status.set_currentSpeed(speed); -- set new speed on status
      	 Period := Ada.Real_Time.Milliseconds (toWait);
      	 toSleep := toSleep + Period;
      	 delay until toSleep;
         event := Ada.Strings.Unbounded.To_Unbounded_String("macchina " & Positive'Image(id) & " uscita dal segmento " & Positive'Image(previousReferee.id));
         previousReferee.leaveSegment(id);
         event_buffer.insert_event(event);
         --Ada.Text_IO.Put_Line ("--> ToWait " & Positive'Image(toWait));
      end loop;
   end Car;

   -----------------------------------------------------------------------
   --------------------------- TASK WEATHER ------------------------------
   -----------------------------------------------------------------------

   task body weather_forecast is

      isRaining : Boolean := false;

      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      Period    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (15000);
      Sveglia   :          Ada.Real_Time.Time := Poll_Time;

   begin
      -- TODO add random
      loop
         if isRaining then
            event_buffer.insert_event(Ada.Strings.Unbounded.To_Unbounded_String("Piove, governo ladro"));
         else
            event_buffer.insert_event(Ada.Strings.Unbounded.To_Unbounded_String("Non Piove, ma il governo e' comunque ladro"));
         end if;
         Sveglia := Sveglia + Period;
         delay until Sveglia;
         isRaining := not isRaining;
      end loop;

   end weather_forecast;

   -----------------------------------------------------------------------
   --------------------------- EVENT BUCKET ------------------------------
   -----------------------------------------------------------------------

   protected body event_bucket is
      entry get_event (event : out Unbounded_String) when bucket_size > 0 is
      begin
         event := bucket.First_Element;  -- bucket.First_Element;
         -- Ada.Text_IO.Put_Line ("ho mangiato l'evento " & Ada.Strings.Unbounded.To_String(event));
         bucket.Delete_First;
         bucket_size := bucket_size - 1;
      end get_event;
      procedure insert_event (event : in Unbounded_String) is
      begin
         -- Ada.Text_IO.Put_Line ("inserisco evento " & Ada.Strings.Unbounded.To_String(event));
         if bucket_size >= capacity
         then
            bucket.Delete_First;
            Ada.Text_IO.Put_Line ("*** bucket pieno *** ");
         else
            bucket_size := bucket_size + 1;
         end if;
         bucket.Append(event);
         -- Ada.Text_IO.Put_Line ("size " & Positive'image(bucket_size));
      end insert_event;
   end event_bucket;

   -----------------------------------------------------------------------
   --------------------------- TASK EVENT HANDLER ------------------------
   -----------------------------------------------------------------------

   task body Event_Handler is

      -- timer to simulate a remote communication with an high latency (300ms)
      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      Period    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (100);
      Sveglia   :          Ada.Real_Time.Time;

      event : Unbounded_String;

   begin
      -- Ada.Text_IO.Put_Line ("il thread e' partito");
      loop

         event_buffer.get_event(event);
         Poll_Time := Ada.Real_Time.Clock;
         Sveglia := Poll_Time + Period;
         -- Ada.Text_IO.Put_Line ("ho mangiato l'evento " & Ada.Strings.Unbounded.To_String(event));
         delay until Sveglia;
         Ada.Text_IO.Put_Line ("Processed event " & Ada.Strings.Unbounded.To_String(event));

      end loop;
   end Event_Handler;

end Circuit;
