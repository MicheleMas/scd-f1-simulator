with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Text_IO;

package body referee_p is

   package Float_Function is new Ada.Numerics.Generic_Elementary_Functions(Float);

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
                          speed : in out Float;
                          maxSpeed : in Positive;
                          acceleration : in Positive;
                          toWait : out Positive;
                          nextReferee : out Referee_Access) when segmentOverridden is
         diff : Float := Float(seg.difficulty) / 10.0;
         penality : Float := 0.8 * diff;
         currentAcceleration : Float := Float(acceleration);
         --calc1 : Float;
      begin
         --Ada.Text_IO.Put_Line ("Initial speed = " & Float'Image(speed));
         --Ada.Text_IO.Put_Line ("Initial acceleration = " & Positive'Image(acceleration));
         speed := (speed * (1.0 - penality)) / 3.6;
         currentAcceleration := currentAcceleration * (1.0 - penality);

         -- DEBUG --
         --Ada.Text_IO.Put_Line ("Initial speed = " & Float'Image(speed));
         --Ada.Text_IO.Put_Line ("Current acceleration = " & Float'Image(currentAcceleration));
         --Ada.Text_IO.Put_Line ("Lenght = " & Float'Image(Float(seg.length)));
         --calc1 := ((speed**2) + (2.0 * currentAcceleration * Float(seg.length)));
         --Ada.Text_IO.Put_Line ("Delta = " & Float'Image(Float(seg.length)));
         -- Fine DEBUG --
         toWait := Positive((((0.0 - speed) + Float_Function.Sqrt((speed**2) +
           (2.0 * currentAcceleration * Float(seg.length)))) /
             currentAcceleration) * 1000.0);

         --toWait := 1000;
         Ada.Text_IO.Put_Line ("Time (millis) to wait = " & Positive'Image(toWait));
         speed := ((currentAcceleration * (Float(toWait)/1000.0)) + speed) / 3.6;
         if(speed > Float(maxSpeed))
         then
            speed := Float(maxSpeed);
         end if;
         nextReferee := next;
         --Ada.Text_IO.Put_Line ("Final speed = " & Float'Image(speed));
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

end referee_p;
