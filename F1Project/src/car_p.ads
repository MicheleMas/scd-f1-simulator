with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with Ada.Real_Time;
use Ada.Real_Time;
with Ada.Text_IO;
with global_custom_types;
use global_custom_types;
with event_bkt;
use event_bkt;
with referee_p;
use referee_p;
with car_status;
use car_status;

package car_p is

   -----------------------------------------------------------------------
   --------------------------- CAR ---------------------------------------
   -----------------------------------------------------------------------

   task type Car (id : Positive;
                  initialReferee : Referee_Access;
                  status : Car_Status_Access;
                  event_buffer : Event_Bucket_Access;
                  race_stat : race_status_Access;
		  Poll_Time_Access : Time_Access);

   type Car_Access is access Car;

end car_p;
