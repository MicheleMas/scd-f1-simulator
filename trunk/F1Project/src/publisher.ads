with event_bkt;
use event_bkt;
with custom_types;
use custom_types;

package Publisher is

   -- Eventi:
   -- > Fine Segmento
   --   type = ES | car = (Pos)ID | seg = (Pos)Seg_ID | vel = (Int)speed
   --   beh = (Pos)behaviour | tire_s = (Int) tire_status
   --   tire_t = (bool)rain_tire
   -- > Rientro ai box
   --   type = EB
   -- > Uscita dai box
   --   type = LB | tire_t = (bool)rain_tire | lap = (Pos)giro terminato
   -- > Fine Giro
   --   type = EL | car = (Pos)ID
   --   sarebbe bello avere anche il tempo
   -- > Una macchina conclude la gara
   --   type = CE | car = (Pos)ID | tempo totale
   -- > La gara è finita
   --   type = ER
   -- > Una macchina fa un incidente
   --   type = CA | car = (Pos)ID | damage = (bool) | retired = (bool)
   -- > Cambio meteo
   --   type = WC | rain = (bool)

   task type Event_Handler (event_buffer : Event_Bucket_Access;
                            race_stat : race_status_Access);

   type Event_Handler_Access is access Event_Handler;

end Publisher;
