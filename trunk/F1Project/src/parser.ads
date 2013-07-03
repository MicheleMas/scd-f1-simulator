with custom_types;
use custom_types;
with car_p;
use car_p;
with referee_p;
use referee_p;

package parser is

   function readCircuit (Filename : in String) return Referee_Access;

   type arrayOfCars is array(1 .. custom_types.car_number) of Car_Status_Access;
   function readCars (Filename : in String) return arrayOfCars;

end parser;
