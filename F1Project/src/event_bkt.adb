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
         event := bucket.First_Element;  -- bucket.First_Element;
         -- Ada.Text_IO.Put_Line ("ho mangiato l'evento " & Ada.Strings.Unbounded.To_String(event));
         bucket.Delete_First;
         bucket_size := bucket_size - 1;
      end get_event;
      procedure insert_event (event : in event_array_Access) is
      begin
         -- Ada.Text_IO.Put_Line ("inserisco evento " & Ada.Strings.Unbounded.To_String(event));
         if bucket_size >= capacity
         then
            bucket.Delete_First;
            Ada.Text_IO.Put_Line ("*** bucket pieno *** ");
         else
            bucket_size := bucket_size + 1;
         end if;
         bucket.Append(event);
         -- Ada.Text_IO.Put_Line ("size " & Positive'image(bucket_size));
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
