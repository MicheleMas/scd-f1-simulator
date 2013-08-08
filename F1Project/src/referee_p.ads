--with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Real_Time;
with custom_types;
use custom_types;
with car_status;
use car_status;

package referee_p is

   type Referee;
   type Referee_Access is access Referee;

   -----------------------------------------------------------------------
   --------------------------- REFEREE -----------------------------------
   -----------------------------------------------------------------------

   protected type Referee (id : Positive;
                           C_next : Referee_Access;
                           First_Referee : Referee_Access) is
      function getSegment return Segment_Access;
      procedure setSegment (new_seg : in Segment_Access);
      procedure setStart;
      entry enterSegment (car_ID : in Positive;
                          c_status : in Car_Status_Access;
                          speed : in out Float;
                          toSleep : in out Ada.Real_Time.Time;
                          nextReferee : out Referee_Access;
                          box_stop : out Boolean;
                          isRaining : in Boolean;
                          incident : out Boolean;
                          last_lap : in Boolean);
      procedure leaveSegment (car_ID : in Positive;
                              box_stop : in Boolean);
      procedure setNext (nextReferee : in Referee_Access);
      function getNext return Referee_Access;
   private
      next : Referee_Access := C_next;
      isStarted : Boolean := false;
      seg : Segment_Access := null;
      carCounter : Natural := 0;
   end Referee;

end referee_p;
