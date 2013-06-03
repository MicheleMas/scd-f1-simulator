with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;

package Circuit is

   package String_Vector is new Ada.Containers.Indefinite_Vectors(Natural, Unbounded_String);

   -- constant
   car_number : Positive := 3; -- number of car

   type Segment (id : Positive;
                 length : Positive;
                 multiplicity : Positive;
                 difficulty : Positive;
                 isBoxEntrance : Boolean) is record
      test : Positive;
   end record;

   type Segment_Access is access Segment;

   type Referee;
   type Referee_Access is access Referee;

   protected type Referee (id : Positive;
                           C_seg : Segment_Access; -- pretty stupid, need to change
                           C_next : Referee_Access ) is
      function getSegment return Segment_Access;
      procedure setSegment (new_seg : in Segment_Access);
      entry enterSegment (car_ID : in Positive;
                          car_behaviour : in Positive;
                          speed : in out Positive;
                          acceleration : in Positive;
                          toWait : out Positive;
                          nextReferee : out Referee_Access);
      procedure leaveSegment (car_ID : in Positive);
      procedure setNext (nextReferee : in Referee_Access);
   private
      next : Referee_Access := C_next;
      segmentOverridden : Boolean := false;
      seg : Segment_Access := C_seg;

   end Referee;

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
      procedure set_currentSegment (currentSeg : in Segment_Access);
      procedure set_currentSpeed (newSpeed : in Positive);
      procedure set_currentFuelLevel (newLevel : in Positive);
      procedure set_damage (status : in Boolean);

      -- getter function
      function get_tires_state return Positive;
      function get_currentSegment return Segment_Access;
      function get_currentSpeed return Positive;
      function get_currentBehaviour return Positive;
      function get_currentFuelLevel return Positive;
      function is_damaged return Boolean;
   private
      change_tires_required : Boolean := false;
      refuel_required : Boolean := false;
      tires_status : Positive := 100;
      fuel_level : Positive := 100;
      behaviour : Positive := C_behaviour;
      currentSegment : Segment_Access;
      currentSpeed : Positive := 100; -- to change
      toWait : Positive;
      damaged : Boolean;
   end Car_Status;

   type Car_Status_Access is access Car_Status;

   task type Car (id : Positive;
                  initialReferee : Referee_Access;
                  status : Car_Status_Access);

   type Car_Access is access Car;

   task weather_forecast;

   protected type Event_Bucket (capacity : Positive) is
      entry get_event (event : out Unbounded_String);
      procedure insert_event (event : in Unbounded_String);
   private
      bucket_size : Integer := 0;
      bucket : String_Vector.Vector;
   end Event_Bucket;

   type Event_Bucket_Access is access Event_Bucket;

   task Event_Handler;

end Circuit;