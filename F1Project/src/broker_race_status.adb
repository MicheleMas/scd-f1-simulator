

package body broker_race_status is

   protected body race_status is

      procedure set_weather(new_weather : in boolean) is
      begin
         weather := new_weather;
      end set_weather;
      procedure get_weather(current_weather : out boolean) is
      begin
         current_weather := weather;
      end get_weather;
      function get_laps return Natural is
      begin
         return laps;
      end get_laps;
      function get_car_number return Natural is
      begin
         return car_number;
      end get_car_number;

   end race_status;

end broker_race_status;
