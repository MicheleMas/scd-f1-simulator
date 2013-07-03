with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with Ada.Containers.Indefinite_Vectors;

package event_bkt is

   package String_Vector is new Ada.Containers.Indefinite_Vectors(Natural, Unbounded_String);

   -----------------------------------------------------------------------
   --------------------------- EVENT BUCKET ------------------------------
   -----------------------------------------------------------------------

   protected type Event_Bucket (capacity : Positive) is
      entry get_event (event : out Unbounded_String);
      procedure insert_event (event : in Unbounded_String);
   private
      bucket_size : Integer := 0;
      bucket : String_Vector.Vector;
   end Event_Bucket;

   type Event_Bucket_Access is access Event_Bucket;

end event_bkt;
