with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Text_IO;
with Ada.Real_Time;
use Ada.Real_Time;
with event_bkt;
use event_bkt;

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
                          c_status : in Car_Status_Access;
                          speed : in out Float;
                          toSleep : in out Ada.Real_Time.Time;
                          nextReferee : out Referee_Access;
                          box_stop : out Boolean;
                          isRaining : in Boolean) when isStarted is
         car_behaviour : Positive := c_status.get_currentBehaviour;
         maxSpeed : Positive := c_status.max_speed;
         acceleration : Positive := c_status.acceleration;
         rain_tires : Boolean := c_status.get_rain_tires;
         diff : Float := Float(seg.difficulty) / 10.0;
         penality : Float := 0.8 * diff;
         currentAcceleration : Float := Float(acceleration) * (Float(car_behaviour) / 10.0); -- acceleration based on behaviour
         toWait : Positive;
         Period : Ada.Real_Time.Time_Span;
         maxWait : Ada.Real_Time.Time;
         initialTime : Ada.Real_Time.Time := toSleep;
         deltaTime : Ada.Real_Time.Time_Span;
         blockingCar : Positive := car_ID;
         initialSpeed : Float;
      begin
         --Ada.Text_IO.Put_Line ("Initial speed = " & Float'Image(speed));
         --Ada.Text_IO.Put_Line ("Initial acceleration = " & Positive'Image(acceleration));

         if (not ((c_status.pitStop4tires or c_status.pitStop4fuel) and seg.isBoxEntrance))
         then
            -- calculate time to wait
            speed := (speed * (1.0 - penality)) / 3.6;
            initialSpeed := speed;
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
                  if (maxWait < (carArray(i) + Ada.Real_Time.Milliseconds (100)))
                  then
                     Ada.Text_IO.Put_Line ("sono " & Positive'Image(car_ID) & " e " & Positive'Image(i) & " mi intralcia");
                     maxWait := carArray(i);
                     blockingCar := i;
                  end if;
               end loop;

               toSleep := maxWait + Ada.Real_Time.Milliseconds (100); -- TODO insert a variable time based on speed

               if(blockingCar = car_ID)
               then
                  Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " ha una accelerazione di " & Float'Image(currentAcceleration));
                  speed := ((currentAcceleration * (Float(toWait)/1000.0)) + speed) * 3.6;
               else
                  deltaTime := toSleep - initialTime;
                  toWait := Positive(Ada.Real_time.To_Duration(deltaTime*1000));

                  --update speed
                  speed := (Float(seg.length) / (Float(toWait) / 1000.0)); -- average speed
                  --Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " ha una media di " & Float'Image(speed));
                  currentAcceleration := (2.0*(Float(seg.length) - (initialSpeed*(Float(toWait)/1000.0)))) / ((Float(toWait)/1000.0)**2);
                  --Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " ha una accelerazione di " & Float'Image(currentAcceleration));
                  speed := (initialSpeed + (currentAcceleration * (Float(toWait)/1000.0))) * 3.6;
               end if;
            else
               Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " trova libero");

               -- update speed
               speed := ((currentAcceleration * (Float(toWait)/1000.0)) + speed) * 3.6;

            end if;

            -- cap max speed
            if(speed > Float(maxSpeed))
               then
                  speed := Float(maxSpeed);
            end if;

            box_stop := false;

            -- calculate if incident occur
            -- on difficulty, rain, tires_status, rain_tires, car_behaviour

            -- Debug!
            Ada.Text_IO.Put_Line ("Time (millis) to wait for car " & Positive'Image(car_ID) & " = " & Positive'Image(toWait));
            Ada.Text_IO.Put_Line ("New speed for car " & Positive'Image(car_ID) & " = " & Float'Image(speed));

            -- update referee
            nextReferee := next;

            -- update counter and status
            Ada.Text_IO.Put_Line ("numero di macchine nel segmento " & Positive'Image(seg.id) & ": " & Natural'Image(carCounter));
            carCounter := carCounter + 1;
            carArray(car_ID) := toSleep;
         else
            -- box
            Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " entra ai box");
            toSleep := initialTime + Ada.Real_Time.Milliseconds (2000);
            if (c_status.pitStop4fuel) -- rifornimento
            then
               toSleep := toSleep + Ada.Real_Time.Milliseconds (4500);
               c_status.set_currentFuelLevel(100);
               Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " deve fare rifornimento");
            end if;
            if (c_status.pitStop4tires) -- cambio gomme
            then
               c_status.Change_Tires(false);
               toSleep := toSleep + Ada.Real_Time.Milliseconds (3500);
               c_status.set_tires_status(100);
               if(isRaining)
               then
                  c_status.set_rain_tires(true);
                  Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " monta gomme da pioggia");
               else
                  c_status.set_rain_tires(false);
                  Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " monta gomme da asciutto");
               end if;
            end if;
            box_stop := true;
            nextReferee := First_Referee.getNext;
         end if;

      end enterSegment;

      procedure leaveSegment (car_ID : in Positive;
                              box_stop : in Boolean) is
      begin
         if (not box_stop)
         then
            carCounter := carCounter - 1;
         end if;
      end leaveSegment;

      procedure setNext (nextReferee : in Referee_Access) is
      begin
         next := nextReferee;
      end setNext;

      function getNext return Referee_Access is
      begin
         return next;
      end getNext;

   end Referee;

end referee_p;
