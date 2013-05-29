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
                           next : Referee_Access ) is
      function getSegment return Segment_Access;
      procedure setSegment (new_seg : in Segment_Access);
      entry enterSegment (car_ID : in Positive;
                          car_behaviour : in Positive;
                          speed : in out Positive;
                          acceleration : in Positive;
                          toWait : out Positive;
                          nextReferee : out Referee_Access);
      -- TODO add setNext procedure
   private
      segmentOverridden : Boolean := false;
      seg : Segment_Access := C_seg;
   end Referee;

   protected type Car_Status (name : String) is
      procedure Take_Fuel (order : in Boolean);
      procedure Change_Tires (order : in Boolean);
      procedure Change_Behaviour (bv : in Positive);
   private
      tires_status : Positive;
   end Car_Status;


   task type Car (id : Positive;
                  initialreferee : Referee_Access);

   type Car_Access is access Car;

   task weather_forecast;

end Circuit;
