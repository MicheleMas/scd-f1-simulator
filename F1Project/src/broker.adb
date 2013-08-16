with YAMI.Agents;
with YAMI.Incoming_Messages;
with YAMI.Parameters;

with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;

procedure Broker is

   stop : boolean := false;

   type Incoming_Message_Handler is
     new YAMI.Incoming_Messages.Message_Handler
       with null record;

   overriding procedure Call
     (H : in out Incoming_Message_Handler;
      Message : in out YAMI.Incoming_Messages.Incoming_Message'Class) is

      procedure Process
        (Content : in out YAMI.Parameters.Parameters_Collection)
      is
         event : constant String := Content.Get_String("type");
      begin
         Ada.Text_IO.Put_Line ("ricevuto: " & event);
         if(event = "ER")
         then
            stop := true;
         end if;
      end Process;

   begin
      Message.Process_Content (Process'Access);
   end Call;

   My_Handler : aliased Incoming_Message_Handler;

begin

   if Ada.Command_Line.Argument_Count /= 1 then
      Ada.Text_IO.Put_Line
        ("Expecting one parameter: server destination");
      Ada.Command_Line.Set_Exit_Status
        (Ada.Command_Line.Failure);
      return;
   end if;

   declare
      Server_Address : constant String :=
        Ada.Command_Line.Argument (1);

      Server_Agent : YAMI.Agents.Agent :=
        YAMI.Agents.Make_Agent;

      Resolved_Server_Address : String (1 .. YAMI.Agents.Max_Target_Length);
      Resolved_Server_Address_Last : Natural;

   begin

      Server_Agent.Add_Listener(Server_Address,
                                Resolved_Server_Address,
                                Resolved_Server_Address_Last);

      Ada.Text_IO.Put_Line("The server is listening on " &
                             Resolved_Server_Address (1 .. Resolved_Server_Address_Last));

      Server_Agent.Register_Object("Event_Dispatcher", My_Handler'Unchecked_Access);

      while(not stop)
      loop
         delay 10.0;
      end loop;
   end;
exception
   when E : others =>
      Ada.Text_IO.Put_Line
        (Ada.Exceptions.Exception_Message (E));
end Broker;
