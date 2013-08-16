package broker_race_status is

   protected type race_status (laps : Natural;
                               car_number : Natural) is

      procedure set_weather(new_weather : in boolean);
      procedure get_weather(current_weather : out boolean);
      function get_laps return Natural;
      function get_car_number return Natural;

   private

      weather : boolean;

   end race_status;

   type race_status_Access is access race_status;

end broker_race_status;
