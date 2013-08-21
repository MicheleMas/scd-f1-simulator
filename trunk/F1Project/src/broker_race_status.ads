with custom_types;
use custom_types;

package broker_race_status is

   -------- Positions array ---------

   protected type enter_segment (time : Integer;
                                 segment : Integer;
                                 speed : Integer;
                                 behaviour : Integer;
                                 tire_status : Integer;
                                 rain_tire : Boolean) is
      function get_time return Integer;
      function get_segment return Integer;
      function get_speed return Integer;
      function get_behaviour return Integer;
      function get_tire_status return Integer;
      function get_rain_tire return Boolean;

   end enter_segment;

   type enter_segment_Access is access enter_segment;

   type positions is array (1 .. 100) of enter_segment_Access;

   type car_positions is array (1 .. car_number) of positions;

   type index_positions is array (1 .. car_number) of Positive;

   -------- Incident array ---------

   -- nell'array car_incident è salvato all'id corrispondente al numero della
   -- macchina una lista circolare contenente gli ultimi 20 incidenti che ha
   -- effettuato. L'indice della lista circolare è contenuto nell'array
   -- index_incident.

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
                         beh : out Integer;
                         speed : out Integer);
      procedure set_data(tire : in Integer;
                         rain : in Boolean;
                         avgspeed : in Float;
                         beh : in Integer;
                         speed : in Integer);
   private
      tire_status : Integer := 100;
      rain_tires : Boolean := false;
      average_speed : Float := 0.0;
      behaviour : Integer := 100;
      current_speed : Integer := 0;

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
                         inci : out boolean;
                         ret : out boolean;
                         over : out boolean);

      procedure set_data(lapc : in Integer;
                         seg : in Integer;
                         prog : in Float;
                         inci : in boolean;
                         ret : in boolean;
                         over : in boolean);
      procedure print_data;

   private

      lap : Integer := 0;
      segment : Integer := 1;
      progress : Float := 0.0;
      incident : boolean := false;
      retired : boolean := false;
      race_completed : boolean := false;

   end car_snapshot;

   type car_snapshot_Access is access car_snapshot;

   type snapshot_array is array (1 .. car_number) of car_snapshot_Access;

   type snapshot_array_Access is access snapshot_array;

   protected type race_status is

      procedure set_weather(new_weather : in boolean);
      procedure get_weather(current_weather : out boolean);

   private

      weather : boolean;

   end race_status;

   type race_status_Access is access race_status;

end broker_race_status;
