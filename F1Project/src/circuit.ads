with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with global_custom_types;
use global_custom_types;
with parser;
use parser;
with car_p;
use car_p;
with event_bkt;
use event_bkt;
with referee_p;
use referee_p;


package Circuit is

   event_buffer : Event_Bucket_Access := new Event_Bucket(200); -- maybe too little?
   race_stat : race_status_Access := new race_status;
   isRaining : Boolean := false;

   task bootstrap;

   task weather_forecast;

end Circuit;
