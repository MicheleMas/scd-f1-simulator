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
      end setSegment;
      procedure setStart is
      begin
         isStarted := true;
      end setStart;
      entry enterSegment (car_ID : in Positive;
                          car_behaviour : in Positive;
                          speed : in out Float;
                          maxSpeed : in Positive;
                          acceleration : in Positive;
			  rain_tires : in Boolean;
                          toSleep : in out Ada.Real_Time.Time;
                          nextReferee : out Referee_Access) when isStarted is
         diff : Float := Float(seg.difficulty) / 10.0;
         penality : Float := 0.8 * diff;
         currentAcceleration : Float := Float(acceleration);
         toWait : Positive;
         Period : Ada.Real_Time.Time_Span;
         maxWait : Ada.Real_Time.Time;
         initialTime : Ada.Real_Time.Time := toSleep;
         deltaTime : Ada.Real_Time.Time_Span;

      begin
         --Ada.Text_IO.Put_Line ("Initial speed = " & Float'Image(speed));
         --Ada.Text_IO.Put_Line ("Initial acceleration = " & Positive'Image(acceleration));

         -- calculate time to wait
         speed := (speed * (1.0 - penality)) / 3.6;
            currentAcceleration := currentAcceleration * (1.0 - penality);
            toWait := Positive((((0.0 - speed) + Float_Function.Sqrt((speed**2) +
           (2.0 * currentAcceleration * Float(seg.length)))) /
             currentAcceleration) * 1000.0);
         Period := Ada.Real_Time.Milliseconds (toWait);
         toSleep := toSleep + Period;
         --Ada.Text_IO.Put_Line ("molteplicita' segmento " & Positive'Image(seg.id) & ": " & Positive'Image(seg.multiplicity));

         -- check segment multiplicity
         if (carCounter >= seg.multiplicity)
         then
            Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " trova occupato");
            -- segment full, the car will exit 100ms after the last one
            maxWait := toSleep;
            for i in carArray'Range loop
               if (maxWait < carArray(i))
               then
                  Ada.Text_IO.Put_Line ("sono " & Positive'Image(car_ID) & " e " & Positive'Image(i) & " mi intralcia");
                  maxWait := carArray(i);
               end if;
            end loop;
            toSleep := maxWait + Ada.Real_Time.Milliseconds (100); -- TODO insert a variable time based on speed
            deltaTime := toSleep - initialTime;
            toWait := Positive(Ada.Real_time.To_Duration(deltaTime*1000));

            --update speed (without acceleration)
            speed := (Float(seg.length) / (Float(toWait) / 1000.0)) * 3.6;
         else
            Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " trova libero");

            -- update speed (with acceleration)
            speed := ((currentAcceleration * (Float(toWait)/1000.0)) + speed) * 3.6;
            if(speed > Float(maxSpeed))
            then
               speed := Float(maxSpeed);
            end if;
         end if;

         -- Debug!
         Ada.Text_IO.Put_Line ("Time (millis) to wait for car " & Positive'Image(car_ID) & " = " & Positive'Image(toWait));

         -- update referee
         nextReferee := next;

         -- update counter and status
         Ada.Text_IO.Put_Line ("numero di macchine nel segmento " & Positive'Image(seg.id) & ": " & Natural'Image(carCounter));
         carCounter := carCounter + 1;
         carArray(car_ID) := toSleep;
      end enterSegment;

      procedure leaveSegment (car_ID : in Positive) is
      begin
         carCounter := carCounter - 1;
      end leaveSegment;

      procedure setNext (nextReferee : in Referee_Access) is
      begin
         next := nextReferee;
      end setNext;
   end Referee;

end referee_p;
