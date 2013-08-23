with broker_race_status;
use broker_race_status;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with global_custom_types; use global_custom_types;

package broker_publisher is

   package Snapshot_Vector is new Ada.Containers.Indefinite_Vectors(Natural, snapshot_array_Access);

   set_up_completed : boolean := false;
   race_over : boolean := false;
   --cars_number : Integer;
   laps_number : Integer;

   protected type condition (capacity : Positive) is
      --procedure set_up (cars : Integer;
      --                  laps : Integer);
      --procedure stop;
      procedure insert_snapshot(snapshot : in snapshot_vault_Access);
      entry get_snapshot(snapshot : out snapshot_array_Access);
      procedure is_bucket_empty(state : out boolean);
      procedure set_rain(rain : in boolean);
      procedure get_rain(rain : out boolean);

   private
      bucket : Snapshot_Vector.Vector;
      bucket_size : Integer := 0;
      is_raining : boolean := false;
   end condition;

   type condition_Access is access condition;

   task type updater (frame : condition_Access;
                      race_stats : race_status_Access);

   type updater_Access is access updater;

end broker_publisher;
