package broker_race_status is

   protected type enter_segment (time : Integer;
                                 segment : Integer) is
      function get_time return Integer;
      function get_segment return Integer;

   end enter_segment;

   type enter_segment_Access is access enter_segment;

   type positions is array (1 .. 100) of enter_segment_Access;

   type car_status is array (1 .. 20) of positions; -- TODO cambiare 20

   protected type race_status is

      procedure set_weather(new_weather : in boolean);
      procedure get_weather(current_weather : out boolean);
      --function get_laps return Natural;
      --function get_car_number return Natural;

   private

      weather : boolean;

   end race_status;

   type race_status_Access is access race_status;

end broker_race_status;
