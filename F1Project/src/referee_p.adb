with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Text_IO;
with Ada.Real_Time;
use Ada.Real_Time;
with event_bkt;
use event_bkt;
with Ada.Numerics;
with Ada.Numerics.Discrete_Random;

package body referee_p is

   package Float_Function is new Ada.Numerics.Generic_Elementary_Functions(Float);
   carArray : array(1 .. car_number) of Ada.Real_Time.Time;

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
                          isRaining : in Boolean;
                          incident : out Natural;
                          last_lap : in Boolean) when isStarted is
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
         Incident_Chance : Positive := 1;
         numRandom : Positive := 1;
      begin
         incident := 0;
         --Ada.Text_IO.Put_Line ("Initial speed = " & Float'Image(speed));
         --Ada.Text_IO.Put_Line ("Initial acceleration = " & Positive'Image(acceleration));

         if (not ((c_status.pitStop4tires or c_status.is_damaged) and seg.isBoxEntrance and (not last_lap))) -- TODO non deve entrare ai box all'ultimo giro!
         then
            -- check if the car is broken
            if(c_status.is_damaged)
            then
               maxSpeed := 100; -- the car run slowly to the box
               acceleration := 1;
            end if;

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
               --Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " trova occupato");
               -- segment full, the car will exit 100ms after the last one
               maxWait := toSleep;
               for i in carArray'Range loop
                  if (maxWait < (carArray(i) + Ada.Real_Time.Milliseconds (100)))
                  then
                     --Ada.Text_IO.Put_Line ("sono " & Positive'Image(car_ID) & " e " & Positive'Image(i) & " mi intralcia");
                     maxWait := carArray(i);
                     blockingCar := i;
                  end if;
               end loop;

               toSleep := maxWait + Ada.Real_Time.Milliseconds (100); -- TODO insert a variable time based on speed

               if(blockingCar = car_ID)
               then
                  --Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " ha una accelerazione di " & Float'Image(currentAcceleration));
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
               --Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " trova libero");

               -- update speed
               speed := ((currentAcceleration * (Float(toWait)/1000.0)) + speed) * 3.6;

            end if;

            -- cap max speed
            if(speed > Float(maxSpeed))
               then
                  speed := Float(maxSpeed);
            end if;

            box_stop := false;

            -- Debug!
            --Ada.Text_IO.Put_Line ("Time (millis) to wait for car " & Positive'Image(car_ID) & " = " & Positive'Image(toWait));
            --Ada.Text_IO.Put_Line ("New speed for car " & Positive'Image(car_ID) & " = " & Float'Image(speed));

            -- update tires consumption (related to the behaviour, segment difficulty, and random)
            declare
               type Rand_Tire_Cons is range 1..3;
               package Rand_Tire is new Ada.Numerics.Discrete_Random(Rand_Tire_Cons);
               seed 	: Rand_Tire.Generator;
               Num 	: Rand_Tire_Cons;
            begin

               Rand_Tire.Reset(seed);
               Num := Rand_Tire.Random(seed);
               numRandom := Positive(Num);
               c_status.set_tires_status(c_status.get_tires_state - (car_behaviour/2) - (seg.difficulty/2) - numRandom);
               --Ada.Text_IO.Put_Line ("New tires status for car " & Positive'Image(car_ID) & " = " & Integer'Image(c_status.get_tires_state));
            end;

            -- calculate if incident occur
            -- on difficulty, rain, tires_status, rain_tires, car_behaviour
            declare
               type Rand_Incident_Limit is range 1..1000;
               package Rand_Incident is new Ada.Numerics.Discrete_Random(Rand_Incident_Limit);
               seed  : Rand_Incident.Generator;
               Num   : Rand_Incident_Limit;
            begin
               Rand_Incident.Reset(seed);
               Num := Rand_Incident.Random(seed);
               numRandom := Positive(Num);
               Incident_Chance := (car_behaviour * 2) + (seg.difficulty * 2);
               if (isRaining)
               then
                  Incident_Chance := Incident_Chance + 20;
                  if (not c_status.get_rain_tires)
                  then
                     Incident_Chance := Incident_Chance + 20;
                  end if;
               end if;
               if(c_status.get_tires_state > 9950)
               then
                  Incident_Chance := 1;
               end if;
               if (Incident_Chance > numRandom)
               then
                  -- incident occurs
                  Ada.Text_IO.Put_Line ("######## car " & Positive'Image(car_ID) & " - incident ###### ");
                  incident := 1;
                  Ada.Text_IO.Put_Line ("Macchina " & Positive'Image(car_ID) & " perde " & Integer'Image(3000 + (numRandom)*150));
                  toSleep := toSleep + Ada.Real_Time.Milliseconds (3000 + ((numRandom)*150));
                  if(numRandom < 15) -- 15% di prob. di danneggiare il veicolo nell'uscita
                  then
                     incident := 2;
                     c_status.set_damage(true);
                     c_status.Change_Behaviour(4);
                  end if;
		  if(numRandom < 5) -- 5% prob. di danneggiare il veicolo irrimediabilmente
                  then
                     incident := 3;
                  end if;
                  speed := 0.0;
               end if;
            end;

            -- update referee
            nextReferee := next;

            -- update counter and status
            carCounter := carCounter + 1;
            carArray(car_ID) := toSleep;
         else
            -- box
            toSleep := initialTime + Ada.Real_Time.Milliseconds (15000);
            if (c_status.pitStop4tires) -- cambio gomme
            then
               c_status.Change_Tires(false);
               toSleep := toSleep + Ada.Real_Time.Milliseconds (3500);
               c_status.set_tires_status(10000);
               if(isRaining)
               then
                  c_status.set_rain_tires(true);
                  Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " monta gomme da pioggia");
               else
                  c_status.set_rain_tires(false);
                  Ada.Text_IO.Put_Line ("macchina " & Positive'Image(car_ID) & " monta gomme da asciutto");
               end if;
            end if;
            if(c_status.is_damaged) -- riparazione
            then
               c_status.set_damage(false);
               c_status.Change_Behaviour(8);
               toSleep := toSleep + Ada.Real_Time.Milliseconds (6000);
            end if;
            box_stop := true;
            speed := 80.0;
            nextReferee := First_Referee.getNext;
            nextReferee := nextReferee.getNext;
            nextReferee := nextReferee.getNext;
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
