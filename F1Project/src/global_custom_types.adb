package body global_custom_types is

   protected body race_status is
      procedure set_real_car_number ( number : in Integer) is
      begin
         registered_cars := number;
      end set_real_car_number;

      procedure set_real_laps_number ( number : in Integer) is
      begin
         real_laps := number;
      end set_real_laps_number;

      function real_car_number return Integer is
      begin
         return registered_cars;
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
         if (cars_racing = 0) -- can be added more conditions here
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
