package Circuit is

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
                           C_seg : Segment_Access;
                           C_next : Referee_Access ) is
      function getSegment return Segment_Access;
      procedure setSegment (new_seg : in Segment_Access);
      entry enterSegment (car_ID : in Positive;
                          car_behaviour : in Positive;
                          speed : in out Positive;
                          acceleration : in Positive;
                          toWait : out Positive;
                          nextReferee : out Referee_Access);
      procedure setNext (nextReferee : in Referee_Access);
   private
      next : Referee_Access := C_next;
      segmentOverridden : Boolean := false;
      seg : Segment_Access := C_seg;
   end Referee;

   protected type Car_Status (name : Positive;
                              C_behaviour : Positive) is
      --procedure Take_Fuel (order : in Boolean);
      --procedure Change_Tires (order : in Boolean);
      --procedure Change_Behaviour (bv : in Positive);
      function get_tires_state return Positive;
      function get_currentSegment return Positive;
      function get_currentSpeed return Positive;
      function get_currentBehaviour return Positive;
   private
      tires_status : Positive := 100;
      fuel_level : Positive := 100;
      behaviour : Positive := C_behaviour;
      currentSegment : Positive := 1;
      currentSpeed : Positive := 100; -- to change
      toWait : Positive;
   end Car_Status;

   type Car_Status_Access is access Car_Status;

   task type Car (id : Positive;
                  initialReferee : Referee_Access;
                  status : Car_Status_Access);

   type Car_Access is access Car;

   task weather_forecast;

end Circuit;
