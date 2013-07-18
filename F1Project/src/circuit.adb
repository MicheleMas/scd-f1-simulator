with Ada.Real_Time;
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with parser;
use parser;
with Ada.Numerics;
with Ada.Numerics.Discrete_Random;

package body Circuit is

   -- place for global variables
   firstReferee : Referee_Access;
   car_status_array : arrayOfCars;

   car_array : array(1 .. custom_types.car_number) of Car_Access;
   ref_array : array(1 .. 3) of Referee_Access;

   task body bootstrap is

      test : Positive := 1;

   begin
 	--Ada.Text_IO.Put_Line ("Inizio il boot. ");
      firstReferee := parser.readCircuit("circuit.txt");
 	--Ada.Text_IO.Put_Line ("Letto il circuito. ");
      car_status_array := parser.readCars("cars.txt");
 	--Ada.Text_IO.Put_Line ("Lette le macchine. ");

      For_Loop :
      for i in Integer range 1 .. custom_types.car_number loop
         car_array(i) := new Car(i,firstReferee,car_status_array(i), Circuit.event_buffer);
      end loop For_Loop;
	--Ada.Text_IO.Put_Line ("Costruiti i tasks. ");

      --let's start the race
      firstReferee.setStart;

   end bootstrap;

   -----------------------------------------------------------------------
   --------------------------- TASK WEATHER ------------------------------
   -----------------------------------------------------------------------

   task body weather_forecast is

      --isRaining : Boolean := false;

      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      Period    : 	   Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (15000);
      Sveglia   :          Ada.Real_Time.Time := Poll_Time;

      type Rand_Range is range 15..150;
      package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Range);
      seed 	: Rand_Int.Generator;
      Num 	: Rand_Range;
      numRandom : Positive := 1;

   begin
      loop
         if isRaining then
            event_buffer.insert_event(Ada.Strings.Unbounded.To_Unbounded_String("Wheater: Piove, governo ladro"));
         else
            event_buffer.insert_event(Ada.Strings.Unbounded.To_Unbounded_String("Wheater: Non Piove, ma il governo e' comunque ladro"));
         end if;
         event_buffer.set_raining(isRaining);

         Rand_Int.Reset(seed);
         Num := Rand_Int.Random(seed);
         --Put_Line(Rand_Range'Image(Num));
         numRandom := Positive(Num);


	 Period := Ada.Real_Time.Milliseconds (100 * numRandom);
         Sveglia := Sveglia + Period;
         delay until Sveglia;
         isRaining := not isRaining;
      end loop;

   end weather_forecast;

   -----------------------------------------------------------------------
   --------------------------- TASK EVENT HANDLER ------------------------
   -----------------------------------------------------------------------

   task body Event_Handler is

      -- timer to simulate a remote communication with an high latency (300ms)
      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      Period    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (50);
      Sveglia   :          Ada.Real_Time.Time;

      event : Unbounded_String;

   begin
      -- Ada.Text_IO.Put_Line ("il thread e' partito");
      loop

         event_buffer.get_event(event);
         Poll_Time := Ada.Real_Time.Clock;
         Sveglia := Poll_Time + Period;
         -- Ada.Text_IO.Put_Line ("ho mangiato l'evento " & Ada.Strings.Unbounded.To_String(event));
         delay until Sveglia;

	 --filtro per stampare solo quello che ci serve
        -- if Ada.Strings.Unbounded.To_String(event)(Ada.Strings.Unbounded.To_String(event)'First) = 'W' then
            Ada.Text_IO.Put_Line ("Processed event " & Ada.Strings.Unbounded.To_String(event));
         --end if;

      end loop;
   end Event_Handler;

end Circuit;
