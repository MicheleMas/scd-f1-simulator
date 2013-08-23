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
                         over : out boolean;
                         rank : out Integer) is
      begin
         lapc := lap;
         seg := segment;
         prog := progress;
         inci := incident;
         ret := retired;
         over := race_completed;
         rank := ranking;
      end get_data;

      procedure setRank(rank : in Integer) is
      begin
         ranking := rank;
      end setRank;

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

      function getLap return Integer is
      begin
         return lap;
      end getLap;
      function getSeg return Integer is
      begin
         return segment;
      end getSeg;
      function getProg return Float is
      begin
         return progress;
      end getProg;

      procedure print_data is
      begin
         Ada.Text_IO.Put_Line(Integer'Image(lap) & " - " & Integer'Image(segment) & " " & Integer'Image(Integer(progress)) & " -  Incident=" & Boolean'Image(incident) & " Ret=" & Boolean'Image(retired) & " Completed=" & Boolean'Image(race_completed) & " Rank =" &Integer'Image(ranking));
      end print_data;

   end car_snapshot;

   protected body snapshot_vault is
      procedure get_data( snap : out snapshot_array_Access) is
      begin
         snap := snapshot;
      end get_data;

      procedure set_data( snap : in snapshot_array_Access) is
      begin
         data_available := true;
         snapshot.all := snap.all;
      end set_data;
   end snapshot_vault;

   protected body detailed_snapshot_vault is
      procedure get_data(detailed_snap : out detailed_array_Access) is
      begin
         detailed_snap := detailed_snapshot;
      end get_data;

      procedure set_data(detailed_snap : in detailed_array_Access) is
      begin
         data_available := true;
         detailed_snapshot.all := detailed_snap.all;
      end set_data;
   end detailed_snapshot_vault;

end broker_race_status;
