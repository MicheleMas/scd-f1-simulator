with YAMI; use YAMI;
with YAMI.Agents;
with Ada.Text_IO;
with Ada.Command_Line;
with YAMI.Parameters;
use YAMI.Parameters;
with YAMI.Value_Publishers;


package body broker_publisher is

   protected body condition is
      procedure insert_snapshot(snapshot : in snapshot_vault_Access) is
         snapshot_copy : snapshot_array_Access := new snapshot_array;
         snap_unboxed : snapshot_array_Access;
      begin
         snapshot.get_data(snap_unboxed);
         snapshot_copy.all := snap_unboxed.all;
         bucket_size := bucket_size + 1;
         bucket.Append(snapshot_copy);
      end insert_snapshot;
      entry get_snapshot(snapshot : out snapshot_array_Access) when bucket_size > 0 is
      begin
         snapshot := bucket.First_Element;
         bucket.Delete_First;
         bucket_size := bucket_size - 1;
      end get_snapshot;
      procedure is_bucket_empty(state : out boolean) is
      begin
         if(bucket_size = 0)
         then
            state := true;
         else
            state := false;
         end if;
      end is_bucket_empty;
      procedure set_rain(rain : in boolean) is
      begin
         is_raining := rain;
      end set_rain;
      procedure get_rain(rain : out boolean) is
      begin
         rain := is_raining;
      end get_rain;
   end condition;

   task body updater is
      Address : Unbounded_String := Ada.Strings.Unbounded.To_Unbounded_String("tcp://localhost:12346");
      cars_number : Integer;
   begin
      race_stats.real_car_number(cars_number);
      if(Ada.Command_Line.Argument_Count > 1)
      then
         Address := Ada.Strings.Unbounded.To_Unbounded_String(Ada.Command_Line.Argument(2));
      else
         Ada.Text_IO.Put_Line("expecting 2 parameter, using default tcp://localhost:12346 as monitor server");
      end if;

      declare
         --Publish_Address : constant String := Ada.Command_Line.Argument(2);
         Publisher_Agent : aliased YAMI.Agents.Agent := YAMI.Agents.Make_Agent;
         Resolved_Publisher_Address : String (1 .. YAMI.Agents.Max_Target_Length);
         Resolved_Publisher_Address_Last : Natural;

         Snapshot_Publisher : YAMI.Value_Publishers.Value_Publisher:=
           YAMI.Value_Publishers.Make_Value_Publisher;

         Content : YAMI.Parameters.Parameters_Collection := Yami.Parameters.Make_Parameters;

         current_snapshot : snapshot_array_Access;
      begin
         Publisher_Agent.Add_Listener(Ada.Strings.Unbounded.To_String(Address), Resolved_Publisher_Address,
                                      Resolved_Publisher_Address_Last);
         Snapshot_Publisher.Register_At(Publisher_Agent'Unchecked_Access, "snapshots");
         while(not race_over)
         loop
            -- read the snapshot and convert it to a Content
            frame.get_snapshot(current_snapshot);
            declare
               lap : Integer;
               seg : Integer;
               prog : Float;
               inci : Boolean;
               ret : Boolean;
               dama : Boolean;
               over : Boolean;
               weather : Boolean;
               rank : Integer;
	       dist : Integer;
            begin
               -- insert weather in the content
               frame.get_rain(weather);
               Content.Set_Boolean("rain", weather);
               for i in Positive range 1 .. cars_number loop
                  current_snapshot(i).get_data(lap, seg, prog, inci, dama, ret ,over, rank, dist);
                  Content.Set_Integer("lap" & Positive'Image(i), YAMI_Integer(lap));
                  Content.Set_Integer("seg" & Positive'Image(i), YAMI_Integer(seg));
                  Content.Set_Integer("prog" & Positive'Image(i), YAMI_Integer(Integer(prog)));
                  Content.Set_Boolean("inci" & Positive'Image(i), inci);
                  Content.Set_Boolean("ret" & Positive'Image(i), ret);
                  Content.Set_Boolean("dama" & Positive'Image(i), dama);
                  Content.Set_Boolean("over" & Positive'Image(i), over);
                  Content.Set_Integer("rank" & Positive'Image(i), YAMI_Integer(rank));
		  Content.Set_Integer("dist" & Positive'Image(i), YAMI_Integer(dist));
               end loop;
            end;
            Snapshot_Publisher.Publish(Content);
            --Ada.Text_IO.Put_Line("-------sent!!-------");
            race_stats.isOver(race_over);
         end loop;
         -- take some time before send the last snapshot
         delay 2.0;
      end;

   end updater;

end broker_publisher;
