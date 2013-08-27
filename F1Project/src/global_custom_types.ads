with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
package global_custom_types is

   -- constant
   car_number : Positive := 20; -- max number of car
   laps_number : Positive := 4; -- number of laps ???

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
      procedure set_real_car_number ( number : in Integer);
      procedure set_real_laps_number ( number : in Integer);
      entry real_car_number (cars : out Integer);
      function real_laps_number return Integer;
      procedure start_race;
      procedure finish_race;
      procedure isOver (over : out Boolean);
      procedure car_end_race;
   private
      set_up_completed : boolean := false;
      real_laps : Integer := laps_number;
      registered_cars : Integer;
      cars_racing : Natural := car_number;

   end race_status;

   type race_status_Access is access race_status;

   type event_array is array (1 .. 9) of Unbounded_String;

   type event_array_Access is access event_array;

end global_custom_types;
