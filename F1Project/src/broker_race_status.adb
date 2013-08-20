

package body broker_race_status is

   protected body enter_segment is

      function get_time return Integer is
      begin
         return time;
      end get_time;
      function get_segment return Integer is
      begin
         return segment;
      end get_segment;
      function get_speed return Integer is
      begin
         return speed;
      end get_speed;

   end enter_segment;

   protected body race_status is

      procedure set_weather(new_weather : in boolean) is
      begin
         weather := new_weather;
      end set_weather;
      procedure get_weather(current_weather : out boolean) is
      begin
         current_weather := weather;
      end get_weather;
      --function get_laps return Natural is
      --begin
      --   return laps;
      --end get_laps;
      --function get_car_number return Natural is
      --begin
      --   return car_number;
      --end get_car_number;

   end race_status;

   protected body car_snapshot is

      procedure get_segment(seg : out Integer) is
      begin
         seg := segment;
      end get_segment;
      procedure get_progress(prog : out Integer) is
      begin
         prog := progress;
      end get_progress;
      procedure is_retired(ret : out boolean) is
      begin
         ret := retired;
      end is_retired;
      procedure is_over(over : out boolean) is
      begin
         over := race_completed;
      end is_over;

      procedure set_segment(seg : in Integer) is
      begin
         segment := seg;
      end set_segment;
      procedure set_progress(prog : in Integer) is
      begin
         progress := prog;
      end set_progress;
      procedure car_retired is
      begin
         retired := true;
      end car_retired;
      procedure set_over is
      begin
         race_completed := true;
      end set_over;

   end car_snapshot;

end broker_race_status;
