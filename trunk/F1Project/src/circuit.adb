with Ada; use Ada;
with Ada.Real_Time;
with Ada.Text_IO;

package body Circuit is

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
      function get_tires_state return Positive is
      begin
         return tires_status;
      end get_tires_state;
      function get_currentSegment return Positive is
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

end Circuit;