with broker_race_status;
use broker_race_status;
with Ada.Containers.Indefinite_Vectors;

package broker_publisher is

   package Snapshot_Vector is new Ada.Containers.Indefinite_Vectors(Natural, snapshot_array_Access);

   set_up_completed : boolean := false;
   race_over : boolean := false;
   cars_number : Integer;
   laps_number : Integer;
   -- TODO creare un bucket

   protected type condition (capacity : Positive) is
      procedure set_up (cars : Integer;
                        laps : Integer);
      procedure stop;
      procedure insert_snapshot(snapshot : in snapshot_array_Access);
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

   task type updater (snapshot : condition_Access);

end broker_publisher;
