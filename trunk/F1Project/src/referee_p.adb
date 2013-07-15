with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Text_IO;
with Ada.Real_Time;
use Ada.Real_Time;

package body referee_p is

   package Float_Function is new Ada.Numerics.Generic_Elementary_Functions(Float);
   carArray : array(1 .. custom_types.car_number) of Ada.Real_Time.Time;

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
                          toSleep : in out Ada.Real_Time.Time;
                          nextReferee : out Referee_Access) when segmentOverridden is
         diff : Float := Float(seg.difficulty) / 10.0;
         penality : Float := 0.8 * diff;
         currentAcceleration : Float := Float(acceleration);
         toWait : Positive;
         Period : Ada.Real_Time.Time_Span;
         maxWait : Ada.Real_Time.Time;
      begin
         --Ada.Text_IO.Put_Line ("Initial speed = " & Float'Image(speed));
         --Ada.Text_IO.Put_Line ("Initial acceleration = " & Positive'Image(acceleration));

         -- calculate time to wait
         speed := (speed * (1.0 - penality)) / 3.6;
         currentAcceleration := currentAcceleration * (1.0 - penality);
         toWait := Positive((((0.0 - speed) + Float_Function.Sqrt((speed**2) +
           (2.0 * currentAcceleration * Float(seg.length)))) /
             currentAcceleration) * 1000.0);

         -- calculate queue with other car
         if (carCounter >= seg.multiplicity) -- TODO controllarne la correttezza
         then
            maxWait := toSleep;
            for i in carArray'Range loop
               if (maxWait < carArray(i))
               then
                  maxWait := maxWait;
               end if;
            end loop;
            toSleep := maxWait + Ada.Real_Time.Milliseconds (100);
         end if;

         -- Debug!
         Ada.Text_IO.Put_Line ("Time (millis) to wait = " & Positive'Image(toWait));

         -- update speed (with cap)
         speed := ((currentAcceleration * (Float(toWait)/1000.0)) + speed) * 3.6;
         if(speed > Float(maxSpeed))
         then
            speed := Float(maxSpeed);
         end if;

         -- update referee and calculate absolute time to wait to
         nextReferee := next;
         Period := Ada.Real_Time.Milliseconds (toWait);
         toSleep := toSleep + Period;

         -- update counter and status
         carCounter := carCounter + 1;
         carArray(car_ID) := toSleep;
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
