with Ada; use Ada;
with Ada.Real_Time;
with Ada.Text_IO;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body Circuit is

   -- place for global variables

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
         Ada.Text_IO.Put_Line ("Initial speed = " & Positive'Image(speed));
         speed := speed + 1;
         toWait := 1000;
         nextReferee := next;
      end enterSegment;
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

      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      Period    :          Ada.Real_Time.Time_Span;
      Sveglia   :          Ada.Real_Time.Time := Poll_Time;
   begin
      loop
      	speed := status.get_currentSpeed;
      	Ada.Text_IO.Put_Line ("sono la macchina " & Positive'Image(id) & " ed entro nel segmento " & Positive'Image(nextReferee.id));
      	nextReferee.enterSegment(id, status.get_currentBehaviour, speed, 1, toWait, nextReferee);
      	-- set new speed on status
      	Period := Ada.Real_Time.Milliseconds (toWait);
      	Sveglia := Sveglia + Period;

      	delay until Sveglia;
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
      Period    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (51000);
      Sveglia   :          Ada.Real_Time.Time := Poll_Time;

   begin

      loop
         if isRaining then
            Ada.Text_IO.Put_Line ("Piove, governo ladro");
         else
            Ada.Text_IO.Put_Line ("Non piove, ma il governo e' comunque ladro");
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
      entry get_event (event : out String) when bucket_size > 0 is
      begin
         event := bucket.First_Element;
         bucket.Delete_First;
         bucket_size := bucket_size - 1;
      end get_event;
      procedure insert_event (event : in String) is
      begin
         if bucket_size >= capacity
         then
            bucket.Delete_First;
         else
            bucket_size := bucket_size + 1;
         end if;
         bucket.Append(event);
      end insert_event;
   end event_bucket;

   task body Event_Handler is

      -- timer to simulate a remote communication with an high latency (300ms)
      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      Period    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (600);
      Sveglia   :          Ada.Real_Time.Time;

      event : String := "";

   begin
      loop

         Poll_Time := Ada.Real_Time.Clock;
         Sveglia := Poll_Time + Period;
         delay until Sveglia;
         bucket.get_event(event);

      end loop;
   end Event_Handler;

end Circuit;
