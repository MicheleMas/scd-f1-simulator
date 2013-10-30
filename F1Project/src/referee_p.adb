with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Text_IO;
with Ada.Real_Time;
use Ada.Real_Time;
with event_bkt;
use event_bkt;
with Ada.Numerics;
with Ada.Numerics.Discrete_Random;
with Ada.Containers.Generic_Array_Sort;

package body referee_p is

   package Float_Function is new Ada.Numerics.Generic_Elementary_Functions(Float);
   type timeArray is array(Natural range <>) of Ada.Real_Time.Time;
   procedure Sort is new Ada.Containers.Generic_Array_Sort (Natural,Ada.Real_Time.Time,timeArray,"<" => ">");
   sortedCarArray : timeArray(1 .. car_number);
   i : integer;

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
      procedure enterSegment (car_ID : in Positive;
                          c_status : in Car_Status_Access;
                          speed : in out Float;
                          toSleep : in out Ada.Real_Time.Time;
                          nextReferee : out Referee_Access;
                          box_stop : out Boolean;
                          isRaining : in Boolean;
                          incident : out Natural;
                          last_lap : in Boolean) is
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
         Incident_Chance : Integer := 1;
         numRandom : Integer := 1;
      begin
         incident := 0;

         if ((c_status.pitStop4tires or c_status.is_damaged) and seg.isBoxEntrance and (not last_lap))
         then

            -- box
            toSleep := initialTime + Ada.Real_Time.Milliseconds (5000);
            if (c_status.pitStop4tires)
            then
               c_status.Change_Tires(false);
               toSleep := toSleep + Ada.Real_Time.Milliseconds (3500);
               c_status.set_tires_status(10000);
               if(isRaining)
               then
                  c_status.set_rain_tires(true);
               else
                  c_status.set_rain_tires(false);
               end if;
            end if;
            if(c_status.is_damaged)
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
         else
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

            -- check segment multiplicity
            if (carCounter >= seg.multiplicity)
            then
               -- segment full, the car will exit 100ms after the last one
               maxWait := toSleep;
               -- at sortedCarArray(seg.multiplicity) we have the time when there will be a free spot in the segment
               if (maxWait < (sortedCarArray(seg.multiplicity) + Ada.Real_Time.Milliseconds (100)))
               then
                  maxWait := sortedCarArray(seg.multiplicity);
               end if;

               toSleep := maxWait + Ada.Real_Time.Milliseconds (100);

               deltaTime := toSleep - initialTime;
               toWait := Positive(Ada.Real_time.To_Duration(deltaTime*1000));

               --update speed
               speed := (Float(seg.length) / (Float(toWait) / 1000.0)); -- average speed
               currentAcceleration := (2.0*(Float(seg.length) - (initialSpeed*(Float(toWait)/1000.0)))) / ((Float(toWait)/1000.0)**2);
               speed := (initialSpeed + (currentAcceleration * (Float(toWait)/1000.0))) * 3.6;
            else

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
            end;

            -- calculate incident, based
            -- on difficulty, rain, tires_status, rain_tires, car_behaviour
            declare
               type Rand_Incident_Limit is range 1..10000;
               package Rand_Incident is new Ada.Numerics.Discrete_Random(Rand_Incident_Limit);
               seed  : Rand_Incident.Generator;
               Num   : Rand_Incident_Limit;
            begin
               Rand_Incident.Reset(seed);
               Num := Rand_Incident.Random(seed);
               numRandom := Positive(Num);
               Incident_Chance := (car_behaviour) + (seg.difficulty);
               if (isRaining)
               then
                  Incident_Chance := Incident_Chance + 10;
                  if (not c_status.get_rain_tires)
                  then
                     Incident_Chance := Incident_Chance + 10;
                  end if;
               end if;
               if(c_status.get_tires_state > 9950)
               then
                  Incident_Chance := 1;
               end if;
               if (Incident_Chance > numRandom)
               then
                  -- incident occurs
                  incident := 1;
                  toSleep := toSleep + Ada.Real_Time.Milliseconds (3000 + ((numRandom)*150));
                  if(numRandom < 5)
                  then
                     incident := 2;
                     c_status.set_damage(true);
                     c_status.Change_Behaviour(4);
                  end if;
		  if(numRandom < 3)
                  then
                     incident := 3;
                  end if;
                  speed := 0.0;
               end if;
            end;

            -- update referee
            nextReferee := next;
		
	    -- TODO controlliamo se toSleep è uguale (a meno di una costante epsilon) ad un elemento del sortedCarArray, nel caso sommiamo un certo valore (dimostrare che è piccolo ma grande abbastanza) al toSleep e ricontrolliamo.
	    i := 1;
	    while(i <= carCounter and sortedCarArray(i) - toSleep > epsilon)
	    loop
		i := i + 1;
	    end loop;
	    -- a car exit in the same (too close) time
	    if( abs(sortedCarArray(i) - toSleep) < epsilon )
	    then
		--Ada.Text_IO.Put_Line ("Sono vivo!");
		while(i > 0)
		loop
			-- that's because there is no lazy evaluation in two while conditions separated by an AND operator
			if(abs(sortedCarArray(i) - toSleep) < epsilon)
			then
				toSleep := toSleep + epsilon;
			end if;
			i := i - 1;
		end loop;
		--Ada.Text_IO.Put_Line ("E ora no.");
	    end if;

            -- update counter and status
            carCounter := carCounter + 1;
            sortedCarArray(car_number) := toSleep;
            Sort(sortedCarArray); --bigger value at position 1.

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
