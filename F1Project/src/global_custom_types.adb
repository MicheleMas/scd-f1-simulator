package body global_custom_types is

   protected body race_status is
      procedure set_starting_time ( start_time : in Ada.Real_Time.Time) is
      begin
	starting_time := start_time;
      end set_starting_time;

      function get_starting_time return Ada.Real_Time.Time is
      begin
	 return starting_time;
      end get_starting_time;

      procedure set_real_car_number ( number : in Integer) is
      begin
         registered_cars := number;
         set_up_completed := true;
      end set_real_car_number;

      procedure set_real_laps_number ( number : in Integer) is
      begin
         real_laps := number;
      end set_real_laps_number;

      entry real_car_number (cars : out Integer) when set_up_completed is
      begin
         cars := registered_cars;
      end real_car_number;

      function real_laps_number return Integer is
      begin
         return real_laps;
      end real_laps_number;

      procedure start_race is
      begin
         cars_racing := registered_cars;
      end start_race;

      procedure finish_race is
      begin
         cars_racing := 0;
      end finish_race;

      procedure isOver (over : out Boolean) is
      begin
         if (cars_racing = 0)
         then
            over := true;
         else
            over := false;
         end if;
      end isOver;

      procedure car_end_race is
      begin
         cars_racing := cars_racing - 1;
      end car_end_race;
   end race_status;

end global_custom_types;
