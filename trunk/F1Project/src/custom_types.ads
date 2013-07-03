package custom_types is

   -- constant
   car_number : Positive := 5; -- number of car

   -----------------------------------------------------------------------
   --------------------------- SEGMENT -----------------------------------
   -----------------------------------------------------------------------

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

   -----------------------------------------------------------------------
   --------------------------- REFEREE -----------------------------------
   -----------------------------------------------------------------------

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

end custom_types;
