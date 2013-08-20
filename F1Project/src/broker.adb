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

with Ada.Real_Time;
use Ada.Real_Time;

procedure Broker is

   stop : boolean := false;
   position_history : car_positions;
   position_index : index_positions;
   last_incident : array (1 .. car_number) of incident_event_Access;
   last_box : array (1 .. car_number) of box_event_Access;

   distances : cars_distances;
   speed_avgs : array (1 .. car_number) of Integer;
   n_speed_avgs : array (1 .. car_number) of Integer;
   lap_time_avg : array (1 .. car_number) of Integer;
   current_lap : array (1 .. car_number) of Integer;
   retired_cars : array (1 .. car_number) of boolean; -- true means retired
   snapshot : snapshot_array;
   --status : race_status_Access;

   Poll_Time : Ada.Real_Time.Time;
   setup_done : boolean := false;

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
         if (not setup_done)
         then
            setup_done := true;
            Poll_Time := Ada.Real_Time.Clock;
         end if;

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
               current_lap(car) := lap;
            end;
         end if;
         if(event = "ER")
         then
            stop := true;
         end if;
         if(event = "CA")
         then
            -- TODO gestire le altre azioni per l'incidente
            declare
               car : Positive := Positive'Value(Content.Get_String("car"));
               retired : Boolean := Content.Get_Boolean("retired");
               damage : Boolean := Content.Get_Boolean("damage");
               time : Integer := Integer((Float'Value(Content.Get_String("time")))*1000.0);
               seg : Positive := Positive'Value(Content.Get_String("seg"));
            begin
               --Ada.Text_IO.Put_Line("--------------> Setto incidente al time " & Integer'Image(time));
               last_incident(car):=new incident_event(time,99999,damage,retired);
            if(retired)
            then
               retired_cars(Positive'Value(Content.Get_String("car"))) := true;
            end if;
            end;
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

      --Initialization
      for i in Positive range 1 .. car_number loop
         --we add a special ES event to each car, to show that they are on starting lane
         position_history(i)(1) := new enter_segment(0,0,0);
         position_index(i) := 2;
         last_incident(i) := new incident_event(0,0,false,false);
         last_box(i) := new box_event(0);
         speed_avgs(i) := 0;
         lap_time_avg(i) := 0;
         n_speed_avgs(i) := 0;
         current_lap(i) := 1;
         retired_cars(i) := false;
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

      --Aspettiamo fino a quando non viene fatto il setup
      while(not setup_done)
      loop
         delay 2.0;
      end loop;

      --task che interpola gli eventi
      declare
         t:Integer := 0;
         indexPreEvent:Integer;
         indexNextEvent:Integer;
         progress:Float;

         nextTime:Integer;
         precTime:Integer;
      begin
         while(not stop)
         loop
            -- snapshot
            for i in Positive range 1 .. car_number loop
               if(position_index(i) > 2 and retired_cars(i) = false) --se abbiamo almeno un evento per la macchina i E non si e' ritirata
               then
                  --cerco l'evento ES immediatamente successivo al tempo t
                  indexPreEvent := position_index(i)-1;
                  while( indexPreEvent > 0 and t < position_history(i)(indexPreEvent).get_time)
                  loop
                     indexPreEvent := indexPreEvent - 1;
                  end loop;
                  indexNextEvent := indexPreEvent +  1; --indice dell'evento immediatamente successivo

                  --uso il tempo segnato nell'evento per capire a che percentuale del tratto segnato è al tempo t
                  precTime := position_history(i)(indexPreEvent).get_time;
                  if(position_index(i) > indexNextEvent)
                  then

                     nextTime := position_history(i)(indexNextEvent).get_time;
                     progress := Float(100*(t-precTime)) / Float((nextTime - precTime));
                     snapshot(i).set_data(position_history(i)(indexPreEvent).get_segment,progress,false,false,false);
                     -- casi limite, la macchina o sta facendo un incidente, o è ai box,
                  else if(last_box(i).get_time > t)
                  then
                     nextTime := last_box(i).get_time;
                     progress := Float(100*(t-precTime)) / Float((nextTime - precTime));
                     snapshot(i).set_data(-1,progress,false,false,false);
                  else if(last_incident(i).get_time > t)
                  then
                     --è incidentata
                     nextTime := last_incident(i).get_time;
                     progress := Float(100*(t-precTime)) / Float((nextTime - precTime));
                     snapshot(i).set_data(last_incident(i).get_segment,progress,true,last_incident(i).car_retired,false);
                     if(last_incident(i).car_retired) then
                        retired_cars(i):=true;
                     end if;
                  else
                     --sono successe cose molto strane
                     snapshot(i).set_data(-9,0.0,false,false,false);

                  end if;
                     end if;
                  end if;
               end if;

            end loop;
            t := t + 500;
            delay 0.5;
            stop :=stop; -- WARNING
            Ada.Text_IO.Put_Line("-- SNAP TIME " & Integer'Image(t) & " --");
            Ada.Text_IO.Put_Line(" ## 1: ");
            snapshot(1).print_data;
            Ada.Text_IO.Put_Line(" ## 2: ");
            snapshot(2).print_data;
            Ada.Text_IO.Put_Line("---");
         end loop;
      end;
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
