with event_bkt;
use event_bkt;
with custom_types;
use custom_types;

package Publisher is

   task type Event_Handler (event_buffer : Event_Bucket_Access;
                            race_stat : race_status_Access);

   type Event_Handler_Access is access Event_Handler;

end Publisher;
