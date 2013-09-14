with Ada.Text_IO;

package body event_bkt is

   -----------------------------------------------------------------------
   --------------------------- EVENT BUCKET ------------------------------
   -----------------------------------------------------------------------

   protected body event_bucket is
      procedure is_bucket_empty (is_empty : out Boolean) is
      begin
         if (bucket_size = 0)
         then
            is_empty := true;
         else
            is_empty := false;
         end if;
      end is_bucket_empty;
      entry get_event (event : out event_array_Access) when bucket_size > 0 is
      begin
         event := bucket.First_Element;
         bucket.Delete_First;
         bucket_size := bucket_size - 1;
      end get_event;
      procedure insert_event (event : in event_array_Access) is
         event_array_copy : event_array_Access := new event_array;
      begin
         event_array_copy.all := event.all;
         if bucket_size >= capacity
         then
            bucket.Delete_First;
            Ada.Text_IO.Put_Line ("*** bucket full *** ");
         else
            bucket_size := bucket_size + 1;
         end if;
         bucket.Append(event_array_copy);
      end insert_event;

      --we save here the rain status
      procedure set_raining (rain : in Boolean) is
      begin
         raining := rain;
      end set_raining;
      function isRaining return Boolean is
      begin
         return raining;
      end isRaining;

   end event_bucket;

end event_bkt;
