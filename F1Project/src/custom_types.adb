package body custom_types is

   protected body race_status is
      procedure isOver (over : out Boolean) is
      begin
         if (cars_in_race = 0) -- can be added more conditions here
         then
            over := true;
         else
            over := false;
         end if;
      end isOver;
      procedure car_end_race is
      begin
         cars_in_race := cars_in_race - 1;
      end car_end_race;
   end race_status;

end custom_types;
