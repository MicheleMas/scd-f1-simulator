
package broker_warehouse is

   protected type storage is
      procedure set_data(Navg_speed : in Float;
                         Ntire_status : in Integer;
                         Nbehaviour : in Integer;
                         Nspeed : in Integer);
      procedure get_data(Navg_speed : out Float;
                         Ntire_status : out Integer;
                         Nbehaviour : out Integer;
                         Nspeed : out Integer);
   private
      avg_speed : Float := 0.0;
      tire_status : Integer := 0;
      behaviour : Integer := 0;
      speed : Integer := 0;
   end storage;

   type storage_Access is access storage;

   task type pull_server(data : storage_Access;
                         laps : Integer;
                         cars : Integer);

end broker_warehouse;
