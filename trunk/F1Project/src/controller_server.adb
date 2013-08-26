with YAMI; use YAMI;
with YAMI.Incoming_Messages;
with YAMI.Parameters;
with YAMI.Agents;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with global_custom_types;
use global_custom_types;
with Ada.Command_Line;
with Ada.Text_IO;

package body controller_server is


   type Incoming_Message_Handler is
     new YAMI.Incoming_Messages.Message_Handler
       with null record;

   overriding procedure Call(H : in out Incoming_Message_Handler;
                             Message : in out YAMI.Incoming_Messages.Incoming_Message'Class) is
      procedure Process(Content : in out YAMI.Parameters.Parameters_Collection) is
        kind : String := Content.Get_String("type");
      begin
         if(kind = "Obeh")
         then
            -- TODO aggiornare il behaviour
            null;
         else
            if(kind = "Obox")
            then
            -- TODO forzare il rientro ai box
               null;
            end if;
         end if;
      end Process;

   begin
      Message.Process_Content(Process'Access);
   end Call;

   My_Handler : aliased Incoming_Message_Handler;

   task body controller_listener is
      address : Unbounded_String := Ada.Strings.Unbounded.To_Unbounded_String("tcp://localhost:12348");
      controller_Agent : YAMI.Agents.Agent := YAMI.Agents.Make_Agent;
      Resolved_Server_Address : String (1 .. YAMI.Agents.Max_Target_Length);
      Resolved_Server_Address_Last : Natural;

      stop : boolean := false;
   begin
      if(Ada.Command_Line.Argument_Count < 2)
      then
         Ada.Text_IO.Put_Line("No controller address specified, using tcp://localhost:12348");
      else
         address := Ada.Strings.Unbounded.To_Unbounded_String(Ada.Command_Line.Argument(2));
      end if;

      controller_Agent.Add_Listener(Ada.Strings.Unbounded.To_String(address), Resolved_Server_Address,
                                    Resolved_Server_Address_Last);
      Ada.Text_IO.Put_Line("Controller server listening on " &
                             Resolved_Server_Address(1 .. Resolved_Server_Address_Last));
      controller_Agent.Register_Object("override", My_Handler'Unchecked_Access);

      while(not stop)
      loop
         status.isOver(stop);
         --Ada.Text_IO.Put_Line("sono vivo!!****!*!**!*!*!*!*");
         delay 2.0;
      end loop;

   end controller_listener;

end controller_server;
