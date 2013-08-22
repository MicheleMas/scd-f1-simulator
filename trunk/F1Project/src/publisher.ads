with event_bkt; use event_bkt;
with global_custom_types; use global_custom_types;

package Publisher is

   -- Eventi:
   -- > Fine Segmento
   --   type = ES | car = (Pos)ID | seg = (Pos)Seg_ID | vel = (Int)speed |
   --   beh = (Pos)behaviour | tire_s = (Int) tire_status |
   --   tire_t = (bool)rain_tire | time = (time_span)

   -- > Rientro ai box
   --   type = EB | car = (Pos)ID | time = (time_span)

   -- > Uscita dai box
   --   type = LB | car = (Pos)ID | tire_t = (bool)rain_tire |
   --   lap = (Pos)giro terminato | time = (time_span)

   -- > Fine Giro
   --   type = EL | car = (Pos)ID | lap = (Pos)giro terminato |
   --   time = (time_span)
   --   sarebbe bello avere anche il tempo totale del giro

   -- > Una macchina conclude la gara
   --   type = CE | car = (Pos)ID | time = (time_span)

   -- > La gara è finita
   --   type = ER

   -- > Una macchina fa un incidente
   --   type = CA | car = (Pos)ID | damage = (bool) | retired = (bool) |
   --   seg = (Pos)segmento | time = (time_span)

   -- > Cambio meteo
   --   type = WC | rain = (bool)

   -- > SETUP
   --   type = SE | ncar = (Int)real_car_number | nlap = (int)real_laps_number

   task type Event_Handler (event_buffer : Event_Bucket_Access;
                            race_stat : race_status_Access);

   type Event_Handler_Access is access Event_Handler;

end Publisher;
