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

package body broker_warehouse is

   protected body storage is
      procedure set_data(Navg_speed : in Float;
                         Ntire_status : in Integer;
                         Nbehaviour : in Integer;
                         Nspeed : in Integer) is
      begin
         avg_speed := Navg_speed;
         tire_status := Ntire_status;
         behaviour := Nbehaviour;
         speed := Nspeed;
      end set_data;
      procedure get_data(Navg_speed : out Float;
                         Ntire_status : out Integer;
                         Nbehaviour : out Integer;
                         Nspeed : out Integer) is
      begin
         Navg_speed := avg_speed;
         Ntire_status := tire_status;
         Nbehaviour := behaviour;
         Nspeed := speed;
      end get_data;
   end storage;

   type Incoming_Message_Handler is
     new YAMI.Incoming_Messages.Message_Handler with null record;

   overriding
   procedure Call
     (H : in out Incoming_Message_Handler;
      Message : in out YAMI.Incoming_Messages.Incoming_Message'Class) is

      procedure Process
        (Content : in out YAMI.Parameters.Parameters_Collection)
      is
         request : Ada.Strings.Unbounded.Unbounded_String;

         Reply_params : YAMI.Parameters.Parameters_Collection :=
           YAMI.Parameters.Make_Parameters;

      begin
         request := Ada.Strings.Unbounded.To_Unbounded_String(Content.Get_String("R"));

         -- controlla cosa vuole il client e mandalo

         Reply_params.Set_Integer("aaa", 1); -- TODO

         Message.Reply(Reply_params);

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

   begin

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

      loop
         -- TODO controlla se la gara è finita
         delay 10.0;
      end loop;

   end;

end broker_warehouse;
