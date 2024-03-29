with global_custom_types;
use global_custom_types;

package broker_race_status is

   -------- Positions array ---------

   protected type enter_segment (time : Integer;
				 lap : Integer;
                                 segment : Integer;
                                 speed : Integer;
                                 behaviour : Integer;
                                 tire_status : Integer;
                                 rain_tire : Boolean;
                                 require_box : Boolean) is
      function get_time return Integer;
      function get_lap return Integer;
      function get_segment return Integer;
      function get_speed return Integer;
      function get_behaviour return Integer;
      function get_tire_status return Integer;
      function get_rain_tire return Boolean;
      function get_require_box return Boolean;

   end enter_segment;

   type enter_segment_Access is access enter_segment;

   type positions is array (1 .. 100) of enter_segment_Access;

   type car_positions is array (1 .. car_number) of positions;

   type index_positions is array (1 .. car_number) of Positive;

   protected type incident_event (time : Integer;
                                  segment : Integer;
                                  damaged : boolean;
                                  retired : boolean) is
      function get_time return Integer;
      function get_segment return Integer;
      function is_damaged return boolean;
      function car_retired return boolean;

   end incident_event;

   type incident_event_Access is access incident_event;


   -------- Box array ---------

   protected type box_event (time : Integer) is

      function get_time return Integer;

   end box_event;

   type box_event_Access is access box_event;


   ---------

   protected type end_race_event (time : Integer) is

      function get_time return Integer;

   end end_race_event;

   type end_race_event_Access is access end_race_event;


   ---------

   protected type lap_event (time : Integer;
                             laps : Integer) is

      function get_time return Integer;
      function get_laps return Integer;

   end lap_event;

   type lap_event_Access is access lap_event;


   ---------

   protected type detailed_status is

      procedure get_data(tire : out Integer;
                         rain : out Boolean;
                         avgspeed : out Float;
                         best_lap : out Integer;
                         beh : out Integer;
                         speed : out Integer;
                         r_box : out Boolean);
      procedure set_data(tire : in Integer;
                         rain : in Boolean;
                         avgspeed : in Float;
                         best_lap : in Integer;
                         beh : in Integer;
                         speed : in Integer;
                         r_box : in Boolean);
      procedure print_data;
   private
      tire_status : Integer := 0;
      rain_tires : Boolean := false;
      average_speed : Float := 0.0;
      best_lap_time : Integer := 0;
      behaviour : Integer := 0;
      current_speed : Integer := 0;
      require_box : Boolean := false;

   end detailed_status;

   type detailed_status_Access is access detailed_status;

   type detailed_array is array (1 .. car_number) of detailed_status_Access;

   type detailed_array_Access is access detailed_array;
   ---------

   type sub_cars_distances is array (1 .. car_number) of Integer;

   type cars_distances is array (1 .. car_number) of sub_cars_distances;

   protected type car_snapshot is

      procedure get_data(lapc : out Integer;
                         seg : out Integer;
                         prog : out Float;
                         inci : out Boolean;
                         dama : out Boolean;
                         ret : out Boolean;
                         over : out Boolean;
                         rank : out Integer;
			 dist : out Integer);

      procedure set_data(lapc : in Integer;
                         seg : in Integer;
                         prog : in Float;
                         inci : in Boolean;
                         dama : in Boolean;
                         ret : in Boolean;
                         over : in Boolean);
      function getLap return Integer;
      function getSeg return Integer;
      function getProg return Float;
      procedure setRank (rank: in Integer);
      procedure setDistance (dist: in Integer);
      procedure print_data;

   private

      lap : Integer := 0;
      segment : Integer := 1;
      progress : Float := 0.0;
      incident : boolean := false;
      damaged : boolean := false;
      retired : boolean := false;
      race_completed : boolean := false;
      ranking : Integer := 0;
      distance : Integer := 0;

   end car_snapshot;

   type car_snapshot_Access is access car_snapshot;

   type snapshot_array is array (1 .. car_number) of car_snapshot_Access;

   type snapshot_array_Access is access snapshot_array;

   ----

   protected type snapshot_vault is
      procedure get_data( snap : out snapshot_array_Access);
      procedure set_data( snap : in snapshot_array_Access);
   private

      data_available : Boolean := false;
      snapshot: snapshot_array_Access := new snapshot_array;

   end snapshot_vault;

   type snapshot_vault_Access is access snapshot_vault;

   ----

   protected type detailed_snapshot_vault is
      procedure get_data(detailed_snap : out detailed_array_Access);
      procedure set_data(detailed_snap : in detailed_array_Access);
   private

      data_available : Boolean := false;
      detailed_snapshot : detailed_array_Access := new detailed_array;

   end detailed_snapshot_vault;

   type detailed_snapshot_vault_Access is access detailed_snapshot_vault;


end broker_race_status;
