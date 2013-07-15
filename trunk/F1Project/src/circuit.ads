with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with custom_types;
use custom_types;
with parser;
use parser;
with car_p;
use car_p;
with event_bkt;
use event_bkt;
with referee_p;
use referee_p;


package Circuit is

   event_buffer : Event_Bucket_Access := new Event_Bucket(10);
   isRaining : Boolean := false;

   task bootstrap;

   task weather_forecast;

   task Event_Handler;

end Circuit;
