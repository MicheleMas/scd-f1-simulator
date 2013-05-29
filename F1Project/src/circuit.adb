with Ada; use Ada;
with Ada.Real_Time;
with Ada.Text_IO;

package body Circuit is

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
         Ada.Text_IO.Put_Line ("Initial speed = " & Positive'Image(speed));
         speed := speed + 1;
         toWait := 1000;
         nextReferee := next;
      end enterSegment;
   end Referee;

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
