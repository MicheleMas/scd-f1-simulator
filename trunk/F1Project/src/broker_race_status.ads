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

   type incident is array (1 .. 20) of incident_event_Access;

   type car_incident is array (1 .. car_number) of incident;

   type index_incident is array (1 .. car_number) of Positive;

   -------- Box array ---------

   protected type box_event (time : Integer) is

      function get_time return Integer;

   end box_event;

   type box_event_Access is access box_event;

   type box is array (1 .. 100) of box_event_Access;

   type car_box is array (1 .. car_number) of box;

   type index_box is array (1 .. car_number) of Positive;


   ---------

   type sub_cars_distances is array (1 .. car_number) of Integer;

   type cars_distances is array (1 .. car_number) of sub_cars_distances;

   protected type car_snapshot is

      procedure get_data(seg : out Integer;
                         prog : out Float;
                         ret : out boolean;
                         over : out boolean);

      procedure set_data(seg : in Integer;
                         prog : in Float;
                         ret : in boolean;
                         over : in boolean);
      procedure print_data;

   private

      segment : Integer := 1;
      progress : Float := 0.0;
      retired : boolean := false;
      race_completed : boolean := false;

   end car_snapshot;

   type snapshot_array is array (1 .. car_number) of car_snapshot;

   protected type race_status is

      procedure set_weather(new_weather : in boolean);
      procedure get_weather(current_weather : out boolean);

   private

      weather : boolean;

   end race_status;

   type race_status_Access is access race_status;

end broker_race_status;
