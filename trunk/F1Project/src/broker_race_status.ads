with custom_types;
use custom_types;

package broker_race_status is

   -------- Positions array ---------

   protected type enter_segment (time : Integer;
                                 segment : Integer;
                                 speed : Integer) is
      function get_time return Integer;
      function get_segment return Integer;
      function get_speed return Integer;

   end enter_segment;

   type enter_segment_Access is access enter_segment;

   type positions is array (1 .. 100) of enter_segment_Access;

   type car_positions is array (1 .. car_number) of positions;

   type index_positions is array (1 .. car_number) of Positive;

   --------- End Positions Array ----------

   type sub_cars_distances is array (1 .. car_number) of Integer;

   type cars_distances is array (1 .. car_number) of sub_cars_distances;

   protected type car_snapshot is

      procedure get_segment(seg : out Integer);
      procedure get_progress(prog : out Float);
      procedure is_retired(ret : out boolean);
      procedure is_over(over : out boolean);

      procedure set_segment(seg : in Integer);
      procedure set_progress(prog : in Float);
      procedure car_retired;
      procedure set_over;

   private

      segment : Integer := 1;
      progress : Float := 0.0;
      retired : boolean := false;
      race_completed : boolean := false;

   end car_snapshot;

   type snapshot is array (1 .. car_number) of car_snapshot;

   protected type race_status is

      procedure set_weather(new_weather : in boolean);
      procedure get_weather(current_weather : out boolean);

   private

      weather : boolean;

   end race_status;

   type race_status_Access is access race_status;

end broker_race_status;
