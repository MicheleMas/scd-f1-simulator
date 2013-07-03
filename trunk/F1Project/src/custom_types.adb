package body custom_types is
   -----------------------------------------------------------------------
   --------------------------- REFEREE -----------------------------------
   -----------------------------------------------------------------------

   protected body Referee is
      function getSegment return Segment_Access is
      begin
         return seg;
      end getSegment;
      procedure setSegment (new_seg : in Segment_Access) is
      begin
         seg := new_seg;
         segmentOverridden := true;
      end setSegment;
      entry enterSegment (car_ID : in Positive;
                          car_behaviour : in Positive;
                          speed : in out Positive;
                          acceleration : in Positive;
                          toWait : out Positive;
                          nextReferee : out Referee_Access) when segmentOverridden is
      begin
         -- TEST
         -- Ada.Text_IO.Put_Line ("Initial speed = " & Positive'Image(speed));
         speed := speed + 1;
         toWait := 1000; -- TODO calculate toWait
         nextReferee := next;
      end enterSegment;
      procedure leaveSegment (car_ID : in Positive) is
      begin
         -- TODO remove car from current car list
         car_number := car_number; -- DEBUG
      end leaveSegment;
      procedure setNext (nextReferee : in Referee_Access) is
      begin
         next := nextReferee;
      end setNext;
   end Referee;

end custom_types;
