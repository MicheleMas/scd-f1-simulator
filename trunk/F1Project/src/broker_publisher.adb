with YAMI; use YAMI;
with YAMI.Agents;
with Ada.Text_IO;
with Ada.Command_Line;
with YAMI.Parameters;
use YAMI.Parameters;
with YAMI.Value_Publishers;


package body broker_publisher is

   protected body condition is
      procedure set_up (cars : Integer;
                       laps : Integer) is
      begin
         cars_number := cars;
         laps_number := laps;
         set_up_completed := true;
      end set_up;
      procedure stop is
      begin
         race_over := true;
      end stop;
      procedure insert_snapshot(snapshot : in snapshot_array_Access) is
         snapshot_copy : snapshot_array_Access := new snapshot_array;
      begin
         snapshot_copy.all := snapshot.all;
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
      default_Address : constant String := "tcp://localhost:12346";
      default : boolean := false;
   begin
      if(Ada.Command_Line.Argument_Count < 2)
      then
         Ada.Text_IO.Put_Line("expecting 2 parameter, using default tcp://localhost:12346");
         default := true;
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
         Ada.Text_IO.Put_Line("*****************Arrivo qui*****************");
         Publisher_Agent.Add_Listener(address, Resolved_Publish_Address,
                                      Resolved_Publisher_Address_Last);
         if(default)
         then
            Publisher_Agent.Add_Listener(default_Address, Resolved_Publisher_Address,
                                         Resolved_Publisher_Address_Last);
         --else
            --Publisher_Agent.Add_Listener(Publish_Address, Resolved_Publisher_Address,
                                        -- Resolved_Publisher_Address_Last);
         end if;

         Snapshot_Publisher.Register_At(Publisher_Agent'Unchecked_Access, "snapshots");

         while(not race_over)
         loop
            -- read the snapshot and convert it to a Content
            frame.get_snapshot(current_snapshot);
            declare
               seg : Integer;
               prog : Float;
               inci : boolean;
               ret : boolean;
               over : boolean;
            begin
               for i in Positive range 1 .. cars_number loop
                  current_snapshot(i).get_data(seg, prog, inci, ret, over);
                  Content.Set_Integer("seg" & Positive'Image(i), YAMI_Integer(seg));
                  Content.Set_Long_Float("prog" & Positive'Image(i), YAMI_Long_Float(prog));
                  Content.Set_Boolean("inci" & Positive'Image(i), inci);
                  Content.Set_Boolean("ret" & Positive'Image(i), ret);
                  Content.Set_Boolean("over" & Positive'Image(i), over);
               end loop;
            end;
            Snapshot_Publisher.Publish(Content);
            Ada.Text_IO.Put_Line("-------inviato!!-------");
         end loop;

      end;

   end updater;

end broker_publisher;
