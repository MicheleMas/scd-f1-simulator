with Ada.Real_Time;
with Ada.Text_IO;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body Circuit is

   -- place for global variables


   -----------------------------------------------------------------------
   --------------------------- TASK WEATHER ------------------------------
   -----------------------------------------------------------------------

   task body weather_forecast is

      isRaining : Boolean := false;

      use type Ada.Real_Time.Time_Span;
      Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
      Period    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (15000);
      Sveglia   :          Ada.Real_Time.Time := Poll_Time;

   begin
      -- TODO add random
      loop
         if isRaining then
            event_buffer.insert_event(Ada.Strings.Unbounded.To_Unbounded_String("Piove, governo ladro"));
         else
            event_buffer.insert_event(Ada.Strings.Unbounded.To_Unbounded_String("Non Piove, ma il governo e' comunque ladro"));
         end if;
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
         Ada.Text_IO.Put_Line ("Processed event " & Ada.Strings.Unbounded.To_String(event));

      end loop;
   end Event_Handler;

end Circuit;
