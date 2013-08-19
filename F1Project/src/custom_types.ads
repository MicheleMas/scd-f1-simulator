with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
package custom_types is

   -- constant
   car_number : Positive := 2; -- number of car
   laps_number : Positive := 4; -- number of laps

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

   protected type race_status is
      procedure isOver (over : out Boolean);
      procedure car_end_race;
   private
      cars_in_race : Natural := car_number;
   end race_status;

   type race_status_Access is access race_status;

   type event_array is array (1 .. 8) of Unbounded_String;

   type event_array_Access is access event_array;

end custom_types;
