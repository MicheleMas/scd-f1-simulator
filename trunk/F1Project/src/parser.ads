with custom_types;
use custom_types;
with referee_p;
use referee_p;

package parser is

   function readCircuit (Filename : in String) return Referee_Access;

end parser;
