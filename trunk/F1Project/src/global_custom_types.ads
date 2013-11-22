with Ada.Real_Time;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Real_Time;
use Ada.Real_Time;
package global_custom_types is

   -- constants
   car_number : Positive := 20; -- max number of cars
   laps_number : Positive := 90; -- max number of laps
   epsilon : Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (1); --a very short time span

   type Segment (id : Positive;
                 length : Positive;
                 multiplicity : Positive;
                 difficulty : Natural;
                 isBoxEntrance : Boolean) is record
      test : Positive;
   end record;

   type Segment_Access is access Segment;

   protected type race_status is
      procedure set_starting_time( start_time : in Ada.Real_Time.Time);
      function get_starting_time return Ada.Real_Time.Time ;
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
      starting_time : Ada.Real_Time.Time;

   end race_status;

   type race_status_Access is access race_status;

   type event_array is array (1 .. 9) of Unbounded_String;

   type event_array_Access is access event_array;

   use type Ada.Real_Time.Time_Span;
   type Time_Access is access Ada.Real_Time.Time;

end global_custom_types;
