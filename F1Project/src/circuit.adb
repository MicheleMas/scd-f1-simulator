with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with parser;
use parser;
with Ada.Numerics;
with Ada.Numerics.Discrete_Random;
with Publisher;
use Publisher;
with controller_server;
use controller_server;
with Ada.Real_Time; use Ada.Real_Time;

package body Circuit is

   -- place for global variables
   firstReferee : Referee_Access;
   car_status_array : arrayOfCarsAccess;
   publisher : Event_Handler_Access;
   controller : controller_listener_Access;

   car_array : array(1 .. car_number) of Car_Access;
   ref_array : array(1 .. 3) of Referee_Access;

   task body bootstrap is

      real_cnumber : Integer;
      real_lapn : Integer;
      event : event_array_Access := new event_array;
      
      Poll_Time : Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
   begin
      firstReferee := parser.readCircuit("circuit.txt");
      Ada.Text_IO.Put_Line ("Circuit parsed.");
      car_status_array := parser.readCars("cars.txt");
      Ada.Text_IO.Put_Line ("Cars parsed.");
      parser.readProperties("race_properties.txt",real_cnumber,real_lapn);

      race_stat.set_real_car_number(real_cnumber);
      race_stat.set_real_laps_number(real_lapn);
      Poll_Time := Poll_Time + Ada.Real_Time.Milliseconds (5000);
      race_stat.set_starting_time(Poll_Time);

      For_Loop :
      for i in Integer range 1 .. real_cnumber loop
         car_array(i) := new Car(i,firstReferee,car_status_array(i), event_buffer, race_stat);
      end loop For_Loop;
      Ada.Text_IO.Put_Line ("Tasks built. ");

      controller := new controller_listener(race_stat, car_status_array);
      publisher := new Event_Handler(event_buffer, race_stat);

      --let's start the race
      delay until Poll_Time;
      event(1) := Ada.Strings.Unbounded.To_Unbounded_String("SE");
      event(2) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(real_cnumber));
      event(3) := Ada.Strings.Unbounded.To_Unbounded_String(Positive'Image(race_stat.real_laps_number));
      event_buffer.insert_event(event);
     
      race_stat.start_race;
      firstReferee.setStart;

   end bootstrap;

   -----------------------------------------------------------------------
   --------------------------- TASK WEATHER ------------------------------
   -----------------------------------------------------------------------

   task body weather_forecast is

      isRaining : Boolean := true;
      raceOver : Boolean := false;

      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      Period    : 	   Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (15000);
      Sveglia   :          Ada.Real_Time.Time := Poll_Time;

      type Rand_Range is range 150..1500;
      package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Range);
      seed 	: Rand_Int.Generator;
      Num 	: Rand_Range;
      numRandom : Positive := 1;

      event : event_array_Access := new event_array;
   begin
      race_stat.isOver(raceOver);
      event(1) := Ada.Strings.Unbounded.To_Unbounded_String("WC");
      while (not raceOver)
      loop
         if(numRandom <= 5) then

            isRaining := not isRaining;
            if isRaining then
               event(2) := Ada.Strings.Unbounded.To_Unbounded_String("T"); -- rainy
               event_buffer.insert_event(event);
            else
               event(2) := Ada.Strings.Unbounded.To_Unbounded_String("F"); -- sunny
               event_buffer.insert_event(event);
            end if;
            event_buffer.set_raining(isRaining);

            Rand_Int.Reset(seed);
            Num := Rand_Int.Random(seed);
            numRandom := Positive(Num);
         else
            numRandom := numRandom - 5;
         end if;

         Period := Ada.Real_Time.Milliseconds (5000);
         Sveglia := Sveglia + Period;
         delay until Sveglia;
         race_stat.isOver(raceOver);
      end loop;
      Ada.Text_IO.Put_Line ("Task weather closed");
   end weather_forecast;

end Circuit;
