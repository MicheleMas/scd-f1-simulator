with YAMI.Agents;
with YAMI.Incoming_Messages;
with YAMI.Parameters;

with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;

with broker_race_status;
use broker_race_status;
use YAMI.Parameters;

with custom_types;
use custom_types;

procedure Broker is

   stop : boolean := false;
   position_history : car_positions;
   position_index : index_positions;
   distances : cars_distances;
   speed_avgs : array (1 .. car_number) of Integer;
   n_speed_avgs : array (1 .. car_number) of Integer;
   lap_time_avg : array (1 .. car_number) of Integer;
   lap_completed : array (1 .. car_number) of Integer;
   --status : race_status_Access;

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
         --if(event = "SP")
         --then
         --   status := new race_status(Integer'Value(Content.Get_String("laps")),
         --                             Integer'Value(Content.Get_String("car_number")));
         --end if;
         if(event = "ES")
         then
            declare
               car : Positive := Positive'Value(Content.Get_String("car"));
               time : Integer := Integer((Float'Value(Content.Get_String("time")))*1000.0);
               seg : Positive := Positive'Value(Content.Get_String("seg"));
               speed : Integer := Integer'Value(Content.Get_String("vel"));
            begin
               speed_avgs(car) := (speed_avgs(car) * n_speed_avgs(car) + speed) / (n_speed_avgs(car)+1);
               n_speed_avgs(car) := n_speed_avgs(car) + 1;
               position_history(car)(position_index(car)) := new enter_segment(time,seg,speed);
               position_index(car) := position_index(car) + 1;
               if(position_index(car) > 100)
               then
                  position_index(car) := 1;
               end if;
            end;
         end if;
         if(event = "EL")
         then
            declare
               car : Positive := Positive'Value(Content.Get_String("car"));
               time : Integer := Integer((Float'Value(Content.Get_String("time")))*1000.0);
               lap : Integer := Integer((Float'Value(Content.Get_String("lap"))));
            begin
               lap_time_avg(car) := time / lap;
               lap_completed(car) := lap;
            end;
         end if;
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

      --Inizialization
      for i in Positive range 1 .. car_number loop
         position_index(i) := 1;
         speed_avgs(i) := 0;
         lap_time_avg(i) := 0;
         n_speed_avgs(i) := 0;
         lap_completed(i) := 0;
         for k in Positive range 1 .. car_number loop
            distances(i)(k) := 0;
         end loop;
      end loop;

      Server_Agent.Add_Listener(Server_Address,
                                Resolved_Server_Address,
                                Resolved_Server_Address_Last);

      Ada.Text_IO.Put_Line("The server is listening on " &
                             Resolved_Server_Address (1 .. Resolved_Server_Address_Last));

      Server_Agent.Register_Object("Event_Dispatcher", My_Handler'Unchecked_Access);

      --task che interpola gli evente
      --devo salvarmi la velocità media di ogni macchina, e il tempo medio di giro
      while(not stop)
      loop
         for i in Positive range 1 .. car_number loop
            for k in Positive range i+1 .. car_number loop
               if(position_index(i)>1 and position_index(k)>1)
               then
                  declare
                     posi : Integer := position_index(i)-1;
                     segi : Integer := position_history(i)(posi).get_segment; --segmento in cui è i
                     posk : Ingeget := position_index(k)-1;
                     segk : Integer := position_history(k)(posk).get_segment; --segmento in cui è k
                     precPosK: Integer ;
                     deltaK:Integer;
                  begin
                     if(lap_completed(i) = lap_completed(k))
                     then
                        if(segi < segk)
                        then
                           precPosK := posk-(segk-segi);
                           if(precPosK <= 0)
                           then
                              precPosK := 100 + precPosK;
                           end if;
                           deltaK := position_history(k)(posk).get_time-position_history(k)(precPosK).get_time; -- tempo in cui k era al segmento i

                        end if;
                     else

                     end if;
                  end;

               end if;
            end loop;
         end loop;
         delay 1.0;
         stop :=stop; -- WARNING
      end loop;

      Ada.Text_IO.Put_Line(Positive'Image(position_index(1)));
      -- stampa tabella posizioni
      for i in Positive range 1 .. position_index(1)-1 loop
         Ada.Text_IO.Put_Line(Positive'Image(position_history(1)(i).get_segment) & " " &
                                Integer'Image(position_history(1)(i).get_time));
      end loop;
   end;
exception
   when E : others =>
      Ada.Text_IO.Put_Line
        (Ada.Exceptions.Exception_Message (E));
end Broker;
