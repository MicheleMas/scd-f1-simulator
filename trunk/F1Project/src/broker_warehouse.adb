with YAMI;
use YAMI;
with YAMI.Parameters;
with YAMI.Incoming_Messages;
with YAMI.Agents;
with Ada; use Ada;
with Ada.Strings;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with custom_types;
use custom_types;

package body broker_warehouse is

   type Incoming_Message_Handler is
     new YAMI.Incoming_Messages.Message_Handler with null record;

   overriding
   procedure Call
     (H : in out Incoming_Message_Handler;
      Message : in out YAMI.Incoming_Messages.Incoming_Message'Class) is

      procedure Process
        (Content : in out YAMI.Parameters.Parameters_Collection)
      is

         Reply_params : YAMI.Parameters.Parameters_Collection :=
           YAMI.Parameters.Make_Parameters;

         request : constant String := Content.Get_String("type");

         tire : Integer;
         rain : Boolean;
         avgspeed : Float;
         beh : Integer;
         speed : Integer;

      begin
         -- S -> setup
         -- D -> details | car = (String)ID

         if(request = "S")
         then
            Reply_params.Set_Integer("laps", YAMI.Parameters.YAMI_Integer(race_status.get_laps));
            Reply_params.Set_Integer("cars", YAMI.Parameters.YAMI_Integer(race_status.get_cars));
            -- TODO forse qui potremmo inviare altri dati utili
            Message.Reply(Reply_params);
         else
            -- All other requests contains "car" parameter
            declare
               ID : Integer := Integer'Value(Content.Get_String("car"));
            begin
               detail(ID).get_data(tire, rain, avgspeed, beh, speed);
               Reply_params.Set_Integer("tire", YAMI.Parameters.YAMI_Integer(tire));
               Reply_params.Set_Boolean("rain", rain);
               Reply_params.Set_Long_Float("avgspeed", YAMI.Parameters.YAMI_Long_Float(avgspeed));
               Reply_params.Set_Integer("beh", YAMI.Parameters.YAMI_Integer(beh));
               Reply_params.Set_Integer("speed", YAMI.Parameters.YAMI_Integer(speed));

               Message.Reply(Reply_params);
            end;
         end if;

      end Process;

   begin

      Message.Process_Content (Process'Access);

   end Call;

   task body pull_server is

      My_Handler : aliased Incoming_Message_Handler;
      Address : Ada.Strings.Unbounded.Unbounded_String := Ada.Strings.Unbounded.To_Unbounded_String("tcp://localhost:12347");

      Server_Agent : YAMI.Agents.Agent := YAMI.Agents.Make_Agent;
      Resolved_Server_Address : String (1 .. YAMI.Agents.Max_Target_Length);
      Resolved_Server_Address_Last : Natural;

      stop : boolean := false;

   begin

      -- initialization
      race_status := status;
      detail := Cdetail;

      if Ada.Command_Line.Argument_Count /= 3
      then
         Ada.Text_IO.Put_Line("No server address specified, using tcp://localhost:12347");
      else
         Address := Ada.Strings.Unbounded.To_Unbounded_String(Ada.Command_Line.Argument(3));
      end if;

      Server_Agent.Add_Listener(Ada.Strings.Unbounded.To_String(Address),
                                Resolved_Server_Address,
                                Resolved_Server_Address_Last);

      Ada.Text_IO.Put_Line("Pull server listening on " &
                             Resolved_Server_Address (1 .. Resolved_Server_Address_Last));

      Server_Agent.Register_Object("warehouse", My_Handler'Unchecked_Access);

      while (not stop)
      loop
         status.is_over(stop);
         delay 5.0;
      end loop;
   end;

end broker_warehouse;
