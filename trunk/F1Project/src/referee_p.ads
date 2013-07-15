--with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Real_Time;
with custom_types;
use custom_types;

package referee_p is

   type Referee;
   type Referee_Access is access Referee;

   -----------------------------------------------------------------------
   --------------------------- REFEREE -----------------------------------
   -----------------------------------------------------------------------

   protected type Referee (id : Positive;
                           C_next : Referee_Access ) is
      function getSegment return Segment_Access;
      procedure setSegment (new_seg : in Segment_Access);
      entry enterSegment (car_ID : in Positive;
                          car_behaviour : in Positive;
                          speed : in out Float;
                          maxSpeed : in Positive;
                          acceleration : in Positive;
                          toSleep : in out Ada.Real_Time.Time;
                          nextReferee : out Referee_Access);
      procedure leaveSegment (car_ID : in Positive);
      procedure setNext (nextReferee : in Referee_Access);
   private
      next : Referee_Access := C_next;
      segmentOverridden : Boolean := false;
      seg : Segment_Access := null;
      carCounter : Natural := 0;
   end Referee;

end referee_p;
