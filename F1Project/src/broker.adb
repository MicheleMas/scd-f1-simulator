with YAMI.Agents;
with YAMI.Incoming_Messages;
with YAMI.Parameters;

with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;

with broker_race_status;
use broker_race_status;
use YAMI.Parameters;

with global_custom_types;
use global_custom_types;

with broker_publisher;
use broker_publisher;

with broker_warehouse;
use broker_warehouse;

with Ada.Real_Time;
use Ada.Real_Time;
with Ada.Strings;
with Ada.Strings.Unbounded;

procedure Broker is

   race_stat : race_status_Access := new global_custom_types.race_status;

   stop : boolean := false;
   position_history : car_positions;
   position_index : index_positions;
   last_incident : array (1 .. car_number) of incident_event_Access;
   last_box : array (1 .. car_number) of box_event_Access;
   last_end : array (1 .. car_number) of end_race_event_Access;
   last_lap : array (1 .. car_number) of lap_event_Access;

   distances : cars_distances;
   speed_avgs : array (1 .. car_number) of Float;
   n_speed_avgs : array (1 .. car_number) of Integer;
   lap_time_avg : array (1 .. car_number) of Integer;
   current_lap : array (1 .. car_number) of Integer;
   retired_cars : array (1 .. car_number) of boolean; -- true means retired
   damaged_cars : array (1 .. car_number) of boolean; -- true means.. ok, you know
   completed_cars : array (1 .. car_number) of boolean; -- true means completed
   nCompleted : Integer;
   snapshot : snapshot_array_Access := new snapshot_array;
   detailed_snapshot : detailed_array_Access := new detailed_array;

   snap_box : snapshot_vault_Access := new snapshot_vault;
   detailed_snap_box : detailed_snapshot_vault_Access := new detailed_snapshot_vault;
   --status : race_status_Access;

   --race_general_stats : broker_race_status.race_status_Access := new broker_race_status.race_status(global_custom_types.laps_number, car_number);
   snapshot_bucket : condition_Access := new condition(50);
   snapshot_publisher : updater_Access := new updater(snapshot_bucket, race_stat);
   information_handler : pull_server_Access := new pull_server(race_stat, detailed_snap_box);

   Wake_Time : Ada.Real_Time.Time;
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
         cars : Integer;
      begin
         if (not setup_done and event = "SE")
         then
            setup_done := true;
            race_stat.set_real_car_number(Integer'Value(Content.Get_String("ncar")));
            race_stat.set_real_laps_number(Integer'Value(Content.Get_String("nlap")));
            race_stat.real_car_number(cars);
            Ada.Text_IO.Put_Line("DEBUG " & Integer'Image(cars) & "   " & Integer'Image(race_stat.real_laps_number));
         end if;

         --Ada.Text_IO.Put_Line ("ricevuto: " & event & " at " & Content.Get_String("time"));
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
               behaviour : Integer := Integer'Value(Content.Get_String("beh"));
               tires_status : Integer := Integer'Value(Content.Get_String("tire_s"));
               rain_tires : Boolean := Content.Get_Boolean("tire_t");
               require_box : Boolean := Content.Get_Boolean("r_box");
            begin
               speed_avgs(car) := (speed_avgs(car) * Float(n_speed_avgs(car)) + Float(speed)) / Float(n_speed_avgs(car)+1);
               n_speed_avgs(car) := n_speed_avgs(car) + 1;
               position_history(car)(position_index(car)) := new enter_segment(time,seg,speed,behaviour,tires_status,rain_tires,require_box);
               position_index(car) := position_index(car) + 1;
               if(position_index(car) > 100)
               then
                  position_index(car) := 1;
               end if;
            end;
         end if;
         if(event = "EL" or event = "LB")
         then
            declare
               car : Positive := Positive'Value(Content.Get_String("car"));
               time : Integer := Integer((Float'Value(Content.Get_String("time")))*1000.0);
               lap : Integer := (Integer'Value(Content.Get_String("lap")));
            begin
               lap_time_avg(car) := time / lap;
               current_lap(car) := lap;
               last_lap(car) := new lap_event(time,lap);
               if(event = "LB")
               then
                  position_history(car)(position_index(car)) := new enter_segment(time,-1,0,-1,-1,Content.Get_Boolean("tire_t"),false);
                  position_index(car) := position_index(car) + 1;
                  if(position_index(car) > 100)
                  then
                     position_index(car) := 1;
                  end if;
               end if;
            end;
         end if;
         if(event = "ER")
         then
            stop := true;
            --race_general_stats.set_over;
         end if;
         if(event = "CA")
         then
            declare
               car : Positive := Positive'Value(Content.Get_String("car"));
               retired : Boolean := Content.Get_Boolean("retired");
               damage : Boolean := Content.Get_Boolean("damage");
               time : Integer := Integer((Float'Value(Content.Get_String("time")))*1000.0);
               seg : Positive := Positive'Value(Content.Get_String("seg"));
            begin
               --Ada.Text_IO.Put_Line("--------------> Setto incidente al time " & Integer'Image(time));
               if(retired) then
                  last_incident(car):=new incident_event(time+10000,seg,damage,retired);
                  position_history(car)(position_index(car)) := new enter_segment(time,seg,0,0,0,false,false);
                  position_index(car) := position_index(car) + 1;
                  if(position_index(car)=2)
                  then
                      position_history(car)(position_index(car)) := new enter_segment(time,seg,0,0,0,false,false);
                      position_index(car) := position_index(car) + 1;
                  end if;

               else
                  last_incident(car):=new incident_event(time,seg,damage,retired);
               end if;
            end;
         end if;
         if(event = "EB" or event = "LB")
         then
            declare
               car : Positive := Positive'Value(Content.Get_String("car"));
               time : Integer := Integer((Float'Value(Content.Get_String("time")))*1000.0);
            begin
               last_box(car):=new box_event(time);

            end;
         end if;
         if(event = "CE")
         then
            declare
               car : Positive := Positive'Value(Content.Get_String("car"));
               time : Integer := Integer((Float'Value(Content.Get_String("time")))*1000.0);
            begin
               last_end(car):=new end_race_event(time);
            end;
         end if;
         if(event = "WC")
         then
            snapshot_bucket.set_rain(Content.Get_Boolean("rain"));
         end if;

      end Process;

   begin
      Message.Process_Content (Process'Access);
   end Call;

   My_Handler : aliased Incoming_Message_Handler;

   publisher_as_argument : boolean := false;

begin

   if Ada.Command_Line.Argument_Count < 1 then
      Ada.Text_IO.Put_Line
        ("Expecting one parameter: server destination");
      Ada.Command_Line.Set_Exit_Status
        (Ada.Command_Line.Failure);
      if Ada.Command_Line.Argument_Count = 2
      then
         publisher_as_argument := true;
      end if;
      return;
   end if;

   declare
      Server_Address : constant String :=
        Ada.Command_Line.Argument (1);

      Server_Agent : YAMI.Agents.Agent :=
        YAMI.Agents.Make_Agent;

      Resolved_Server_Address : String (1 .. YAMI.Agents.Max_Target_Length);
      Resolved_Server_Address_Last : Natural;

      cars : Integer;

   begin

      Server_Agent.Add_Listener(Server_Address,
                                Resolved_Server_Address,
                                Resolved_Server_Address_Last);

      Ada.Text_IO.Put_Line("The server is listening on " &
                             Resolved_Server_Address (1 .. Resolved_Server_Address_Last));

      Server_Agent.Register_Object("Event_Dispatcher", My_Handler'Unchecked_Access);

      Ada.text_io.Put_Line("Aspetto il setup");
      --Aspettiamo fino a quando non viene fatto il setup
      while(not setup_done)
      loop
         delay 1.0;
      end loop;
      Ada.text_io.Put_Line("Faccio l'inizializzazione");

      --Initialization
      race_stat.real_car_number(cars);
      nCompleted:=0;
      for i in Positive range 1 ..cars loop
         --we add a special ES event to each car, to show that they are on starting lane
         position_history(i)(1) := new enter_segment(0,0,0,0,0,false,false);
         position_index(i) := 2;
         last_incident(i) := new incident_event(0,0,false,false);
         last_box(i) := new box_event(0);
         speed_avgs(i) := 0.0;
         lap_time_avg(i) := 0;
         n_speed_avgs(i) := 0;
         current_lap(i) := 1;
         retired_cars(i) := false;
         damaged_cars(i) := false;
         completed_cars(i) := false;
         snapshot(i) := new car_snapshot;
         detailed_snapshot(i) := new detailed_status;
         last_end(i) := new end_race_event(999999999);
         last_lap(i) := new lap_event(0,0);
         for k in Positive range 1 .. cars loop
            distances(i)(k) := 0;
         end loop;
      end loop;

      --delay 2.0;
      Wake_Time := Ada.Real_Time.Clock;

      --task che interpola gli eventi
      declare
         t:Integer := 0;
         indexPreEvent:Integer;
         indexNextEvent:Integer;
         progress:Float;
         lap:Integer;

         nextTime:Integer;
         precTime:Integer;
         raceFinished:boolean := false;
         ranking : array (1 .. car_number) of Integer;
      begin
         Ada.text_io.Put_Line("Inizio l'interpolazione");
         while(not raceFinished or not stop)
         loop
            -- snapshot
            for i in Positive range 1 .. cars loop
               if(position_index(i) > 2 and retired_cars(i) = false and completed_cars(i) = false) --se abbiamo almeno un evento per la macchina i E non si e' ritirata
               then
                  --segno il lap corrente
                  lap := last_lap(i).get_laps;
                  if(t > last_lap(i).get_time)
                  then
                     lap := lap+1;
                  end if;
                  --cerco l'evento ES immediatamente successivo al tempo t
                  indexPreEvent := position_index(i) - 1;

                  if(indexPreEvent < 1) then
                     indexPreEvent := 100 - indexPreEvent;
                  end if;

                  while( indexPreEvent > 0 and t < position_history(i)(indexPreEvent).get_time)
                  loop
                     indexPreEvent := indexPreEvent - 1;
                     if(indexPreEvent < 1) then
                        indexPreEvent := 100 - indexPreEvent;
                     end if;
                  end loop;
                  indexNextEvent := indexPreEvent +  1; --indice dell'evento immediatamente successivo
                  if(indexNextEvent > 100) then
                     indexNextEvent := indexNextEvent - 100;
                  end if;

                  --uso il tempo segnato nell'evento per capire a che percentuale del tratto segnato è al tempo t
                  precTime := position_history(i)(indexPreEvent).get_time;
                  if(position_index(i) > indexNextEvent and last_incident(i).get_time < t)
                  then

                     nextTime := position_history(i)(indexNextEvent).get_time;
                     progress := Float(100*(t-precTime)) / Float((nextTime - precTime));
                     snapshot(i).set_data(lap,position_history(i)(indexNextEvent).get_segment,progress,false,damaged_cars(i),false,false);
                     detailed_snapshot(i).set_data(position_history(i)(indexNextEvent).get_tire_status,
                                                   position_history(i)(indexNextEvent).get_rain_tire,
                                                   speed_avgs(i),
                                                   position_history(i)(indexNextEvent).get_behaviour,
                                                   position_history(i)(indexNextEvent).get_speed,
                                                   position_history(i)(indexNextEvent).get_require_box);
                     if(position_history(i)(indexNextEvent).get_segment = -1 and damaged_cars(i))
                     then
                        damaged_cars(i):=false;
                     end if;
                     -- casi limite, la macchina o sta facendo un incidente, o è ai box,
                  else if(last_box(i).get_time > t)
                  then
                        --è ai box
                     nextTime := last_box(i).get_time;

                     progress := Float(100*(t-precTime)) / Float((nextTime - precTime));
                     snapshot(i).set_data(lap,-1,progress,false,damaged_cars(i),false,false);
                     detailed_snapshot(i).set_data(position_history(i)(indexPreEvent).get_tire_status,
                                                   position_history(i)(indexPreEvent).get_rain_tire,
                                                   speed_avgs(i),
                                                   position_history(i)(indexPreEvent).get_behaviour,
                                                   80,
                                                   true);
                        if(damaged_cars(i))
                        then
                           damaged_cars(i):=false;
                        end if;
                  else if(last_incident(i).get_time > t)
                  then
                     --è incidentata
                     nextTime := last_incident(i).get_time;
                     progress := Float(100*(t-precTime)) / Float((nextTime - precTime));
                     snapshot(i).set_data(lap,last_incident(i).get_segment,progress,true,last_incident(i).is_damaged,last_incident(i).car_retired,false);
                     detailed_snapshot(i).set_data(position_history(i)(indexPreEvent).get_tire_status,
                                                   position_history(i)(indexPreEvent).get_rain_tire,
                                                   speed_avgs(i),
                                                   position_history(i)(indexPreEvent).get_behaviour,
                                                   0,
                                                   position_history(i)(indexPreEvent).get_require_box);
                     if(last_incident(i).car_retired) then
                        retired_cars(i):=true;
                     end if;
                     if(last_incident(i).is_damaged) then
                        damaged_cars(i):= true;
                     end if;
                  else if(last_end(i).get_time < t)
                  then --ha fatto l'ultimo giro
                     snapshot(i).set_data(lap,0,0.0,false,damaged_cars(i),false,true);
                     detailed_snapshot(i).set_data(0,
                                                   position_history(i)(indexPreEvent).get_rain_tire,
                                                   speed_avgs(i),
                                                   position_history(i)(indexPreEvent).get_behaviour,
                                                   0,
                                                   position_history(i)(indexPreEvent).get_require_box);
                     completed_cars(i):=true;
                     nCompleted := nCompleted +1;
                  else
                     --sono successe cose molto strane TODO da togliere
                     snapshot(i).set_data(-9,-9,0.0,false,false,false,false);
                     Ada.Text_IO.Put_Line("DEBUG COSE STRANE!");
                  end if;
                  end if;
                  end if;
                  end if;
                  end if;

            end loop;
            -- calcola la classifica (male)
            for i in Positive range 1 .. cars loop
               if(retired_cars(i)) then
                  ranking(i):=0; -- retired car
               else
                  if(not completed_cars(i))
                  then
                     ranking(i):=nCompleted + 1;
                     for k in Positive range 1 .. cars loop
                        if(not completed_cars(k) and not retired_cars(k))
                        then
                           if(snapshot(i).getLap < snapshot(k).getLap or
                                (snapshot(i).getLap = snapshot(k).getLap and snapshot(i).getSeg < snapshot(k).getSeg) or
                                (snapshot(i).getLap = snapshot(k).getLap and snapshot(i).getSeg = snapshot(k).getSeg and snapshot(i).getProg < snapshot(k).getProg) or
                                (i /= k and snapshot(i).getLap = snapshot(k).getLap and snapshot(i).getSeg = snapshot(k).getSeg and snapshot(i).getProg = snapshot(k).getProg))
                           then
                              ranking(i):=ranking(i) + 1;
                           end if;
                        end if;
                     end loop;
                  end if;
               end if;
            end loop;
            --la parte sopra è decisamente da migliorare
            for i in Positive range 1 .. cars loop
               snapshot(i).setRank(ranking(i));
            end loop;


            --we put the updated data in the vault, ready to be retrieved
            snap_box.set_data(snapshot);
            detailed_snap_box.set_data(detailed_snapshot);

            raceFinished:=true;
            for i in Positive range 1 .. cars loop
               if(not retired_cars(i) and not completed_cars(i))
               then
	          --Ada.Text_IO.Put_Line("La macchina " & Positive'Image(i) & " e' ancora in corsa");
                  raceFinished:=false;
               end if;
            end loop;
            if raceFinished
            then
               race_stat.finish_race;
            end if;
            t := t + 500;
            -- send snapshot array to the publisher
            snapshot_bucket.insert_snapshot(snap_box);
            wake_time := wake_time + Ada.Real_Time.Milliseconds(500);
            delay until wake_time;
            ---DEBUG
            Ada.Text_IO.Put_Line("-- SNAP TIME " & Integer'Image(t-500) & " --");
            for i in Positive range 1 .. cars loop
               Ada.Text_IO.Put_Line("### " & Positive'Image(i) &": ");
               snapshot(i).print_data;
               --detailed_snapshot(i).print_data;
               Ada.Text_IO.Put_Line("---");
            end loop;
            --Ada.Text_IO.Put_Line("### 2: ");
            --snapshot(2).print_data;
            --detailed_snapshot(2).print_data;
            --Ada.Text_IO.Put_Line("---");
         end loop;
      end;
      --Ada.Text_IO.Put_Line(Positive'Image(position_index(1)));
      -- DEBUG stampa tabella posizioni
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
