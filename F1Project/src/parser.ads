with global_custom_types; use global_custom_types;
with car_status; use car_status;
with car_p; use car_p;
with referee_p; use referee_p;

package parser is

   function readCircuit (Filename : in String) return Referee_Access;

   type arrayOfCars is array(1 .. car_number) of Car_Status_Access;
   type arrayOfCarsAccess is access arrayOfCars;
   function readCars (Filename : in String) return arrayOfCarsAccess;
   procedure readProperties(Filename : in String;
                            cnumber : out Integer;
                            lnumber : out Integer);

end parser;
