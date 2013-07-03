with Ada.Text_IO;
with custom_types;
use custom_types;

package body parser is

   function readCircuit (Filename : in String) return Referee_Access is
      File       : Ada.Text_IO.File_Type;
      Line_Count : Natural := 0;
      First_Ref  : Referee_Access := null;
   begin
      Ada.Text_IO.Open (File => File,
                        Mode => Ada.Text_IO.In_File,
                        Name => Filename);
      while not Ada.Text_IO.End_Of_File (File) loop
         declare
            Line : String := Ada.Text_IO.Get_Line (File);
         begin
            Line_Count := Line_Count + 1;
            Ada.Text_IO.Put_Line (Natural'Image (Line_Count) & ": " & Line);
		--- costruzione del circuito a partire dai dati di ogni linea
		--- ogni riga del file contiene i dati di un segmento
		--- il segmento successivo sar� quello che viene dopo
		--- quando la riga dopo � vuota collego al primo
		--- dopo aver creato il segmento, crea il referee associato
		--- ritorna il puntatore al primo referee
         end;
      end loop;
      Ada.Text_IO.Close (File);
      return First_Ref;
   end readCircuit;


end parser;