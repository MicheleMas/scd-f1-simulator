with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with Ada.Real_Time;
use Ada.Real_Time;
with Ada.Text_IO;
with custom_types;
use custom_types;
with event_bkt;
use event_bkt;
with referee_p;
use referee_p;


package car_p is

   -----------------------------------------------------------------------
   --------------------------- CAR STATUS --------------------------------
   -----------------------------------------------------------------------

   protected type Car_Status (name : Positive;
                              C_behaviour : Positive;
                              max_speed : Positive;
                              acceleration : Positive) is
      -- override procedure
      procedure Take_Fuel (order : in Boolean);
      procedure Change_Tires (order : in Boolean);
      procedure Change_Behaviour (bv : in Positive);

      -- setter procedure
      procedure set_tires_status (newState : in Positive);
      procedure set_rain_tires (newTires : in Boolean );
      procedure set_currentSegment (currentSeg : in Segment_Access);
      procedure set_currentSpeed (newSpeed : in Float);
      procedure set_currentFuelLevel (newLevel : in Positive);
      procedure set_damage (status : in Boolean);

      -- getter function
      function get_name return Positive;
      function get_tires_state return Positive;
      function get_rain_tires return Boolean;
      function get_currentSegment return Segment_Access;
      function get_currentSpeed return Float;
      function get_currentBehaviour return Positive;
      function get_currentFuelLevel return Positive;
      function is_damaged return Boolean;
   private
      change_tires_required : Boolean := false;
      refuel_required : Boolean := false;
      tires_status : Positive := 100;
      rain_tires : Boolean := false;
      fuel_level : Positive := 100;
      behaviour : Positive := C_behaviour;
      currentSegment : Segment_Access;
      currentSpeed : Float := 1.0; -- to change
      toWait : Positive;
      damaged : Boolean;
   end Car_Status;

   type Car_Status_Access is access Car_Status;

   -----------------------------------------------------------------------
   --------------------------- CAR ---------------------------------------
   -----------------------------------------------------------------------

   task type Car (id : Positive;
                  initialReferee : Referee_Access;
                  status : Car_Status_Access;
                  event_buffer : Event_Bucket_Access);

   type Car_Access is access Car;

end car_p;
