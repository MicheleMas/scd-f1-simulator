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

   private
      segmentOverridden : Boolean := false;
      seg : Segment_Access := C_seg;
   end Referee;


   task weather_forecast;

end Circuit;
