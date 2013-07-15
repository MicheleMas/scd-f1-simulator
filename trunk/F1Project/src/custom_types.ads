package custom_types is

   -- constant
   car_number : Positive := 2; -- number of car

   -----------------------------------------------------------------------
   --------------------------- SEGMENT -----------------------------------
   -----------------------------------------------------------------------

   -- length: lunghezza in metri del segmento
   -- multiplicity: numero di macchine che possono essere presenti contemporaneamente
   -- difficulty: indice di difficolta' del segmento. Varia da 0 a 10, dove 10 indica
   -- 		  un segmento particolarmente difficile, come una chicane.
   -- isBoxEntrance: indica che nel segmento e' presente un ingresso ai box.
   type Segment (id : Positive;
                 length : Positive;
                 multiplicity : Positive;
                 difficulty : Natural;
                 isBoxEntrance : Boolean) is record
      test : Positive;
   end record;

   type Segment_Access is access Segment;


end custom_types;
