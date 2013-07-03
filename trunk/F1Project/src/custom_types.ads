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


end custom_types;
