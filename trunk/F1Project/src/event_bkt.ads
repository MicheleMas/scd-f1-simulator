with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with Ada.Containers.Indefinite_Vectors;
with YAMI.Parameters; use YAMI.Parameters;
with global_custom_types; use global_custom_types;

package event_bkt is

   package String_Vector is new Ada.Containers.Indefinite_Vectors(Natural, event_array_Access);

   -----------------------------------------------------------------------
   --------------------------- EVENT BUCKET ------------------------------
   -----------------------------------------------------------------------

   protected type Event_Bucket (capacity : Positive) is
      procedure is_bucket_empty (is_empty : out Boolean);
      entry get_event (event : out event_array_Access);
      procedure insert_event (event : in event_array_Access);
      procedure set_raining (rain : in Boolean);
      function isRaining return Boolean;
   private
      bucket_size : Integer := 0;
      bucket : String_Vector.Vector;
      raining : Boolean;
   end Event_Bucket;

   type Event_Bucket_Access is access Event_Bucket;

end event_bkt;
