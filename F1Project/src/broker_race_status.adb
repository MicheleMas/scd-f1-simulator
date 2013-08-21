with Ada; use Ada;
with Ada.Text_IO;


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
      function get_behaviour return Integer is
      begin
         return behaviour;
      end get_behaviour;
      function get_tire_status return Integer is
      begin
         return tire_status;
      end get_tire_status;
      function get_rain_tire return Boolean is
      begin
         return rain_tire;
      end get_rain_tire;

   end enter_segment;

   protected body incident_event is
      function get_time return Integer is
      begin
         return time;
      end get_time;
      function get_segment return Integer is
      begin
         return segment;
      end get_segment;
      function is_damaged return boolean is
      begin
         return damaged;
      end is_damaged;
      function car_retired return boolean is
      begin
         return retired;
      end car_retired;

   end incident_event;

   protected body box_event is

      function get_time return Integer is
      begin
         return time;
      end get_time;

   end box_event;

   protected body end_race_event is

      function get_time return Integer is
      begin
         return time;
      end get_time;

   end end_race_event;

   protected body lap_event is

      function get_time return Integer is
      begin
         return time;
      end get_time;

      function get_laps return Integer is
      begin
         return laps;
      end get_laps;


   end lap_event;

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

   protected body detailed_status is
      procedure get_data(tire : out Integer;
                         rain : out Boolean;
                         avgspeed : out Float;
                         beh : out Integer;
                         speed : out Integer) is
      begin
         tire := tire_status;
         rain := rain_tires;
         avgspeed := average_speed;
         beh := behaviour;
         speed := current_speed;
      end get_data;

      procedure set_data(tire : in Integer;
                         rain : in Boolean;
                         avgspeed : in Float;
                         beh : in Integer;
                         speed : in Integer) is
      begin
         tire_status := tire;
         rain_tires := rain;
         average_speed := avgspeed;
         behaviour := beh;
         current_speed := speed;
      end set_data;

      procedure print_data is
      begin
         Ada.Text_IO.Put_Line("t_s: " & Integer'Image(tire_status) & " rain: " & Boolean'Image(rain_tires) & " Avg_Speed : " & Integer'Image(Integer(average_speed)) & " -  Beh: " & Integer'Image(behaviour) & " Speed: =" & Integer'Image(current_speed));
      end print_data;

   end detailed_status;

   protected body car_snapshot is

      procedure get_data(lapc : out Integer;
                         seg : out Integer;
                         prog : out Float;
                         inci : out boolean;
                         ret : out boolean;
                         over : out boolean) is
      begin
         lapc := lap;
         seg := segment;
         prog := progress;
         inci := incident;
         ret := retired;
         over := race_completed;
      end get_data;

      procedure set_data(lapc : in Integer;
                         seg : in Integer;
                         prog : in Float;
                         inci : in boolean;
                         ret : in boolean;
                         over : in boolean) is
      begin
         lap := lapc;
         segment := seg;
         progress := prog;
         incident := inci;
         retired := ret;
         race_completed := over;
      end set_data;

      procedure print_data is
      begin
         Ada.Text_IO.Put_Line(Integer'Image(lap) & " - " & Integer'Image(segment) & " " & Integer'Image(Integer(progress)) & " -  Incident=" & Boolean'Image(incident) & " Ret=" & Boolean'Image(retired) & " Completed=" & Boolean'Image(race_completed));
      end print_data;

   end car_snapshot;

end broker_race_status;
