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
            -- Ada.Text_IO.Put_Line (Natural'Image (Line_Count) & ": " & Line);
            if (Line(Line'First + 1) = '#')
            then
               Ada.Text_IO.Put_Line ("da leggere");
            else
               Ada.Text_IO.Put_Line ("commento");
            end if;

		--- costruzione del circuito a partire dai dati di ogni linea
		--- ogni riga del file contiene i dati di un segmento
		--- il segmento successivo sarà quello che viene dopo
		--- quando la riga dopo è vuota collego al primo
		--- dopo aver creato il segmento, crea il referee associato
		--- ritorna il puntatore al primo referee
         end;
      end loop;
      Ada.Text_IO.Close (File);
      return First_Ref;
   end readCircuit;

   --- funzione che legge le macchine
   function readCars (Filename : in String) return arrayOfCars is
      File       : Ada.Text_IO.File_Type;
      Line_Count : Natural := 0;
      Cars_Array : arrayOfCars;
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
            --- in ogni riga ci sono i dati di una macchina
            --- crea l'array con i dati di ogni macchina

         end;
      end loop;
      Ada.Text_IO.Close (File);
      return Cars_Array;
   end readCars;


end parser;
