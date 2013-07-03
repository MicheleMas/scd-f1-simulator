with Ada.Text_IO;
with custom_types;
use custom_types;
with GNAT.String_Split;

package body parser is

   function readCircuit (Filename : in String) return Referee_Access is
      File       : Ada.Text_IO.File_Type;
      Line_Count : Natural := 0;
      First_Ref  : Referee_Access := null;
      Current_Ref : Referee_Access := null;
      Subs : GNAT.String_Split.Slice_Set;
      Seps : String := " " & ASCII.HT;
      firstSegment : Boolean := true;
   begin
      Ada.Text_IO.Open (File => File,
                        Mode => Ada.Text_IO.In_File,
                        Name => Filename);
      while not Ada.Text_IO.End_Of_File (File) loop
         declare
            Line : String := Ada.Text_IO.Get_Line (File);
            seg : Segment_Access := null;
            box : Boolean;
         begin
            Line_Count := Line_Count + 1;
            -- Ada.Text_IO.Put_Line (Natural'Image (Line_Count) & ": " & Line);
            if (not (Line(Line'First) = '#'))
            then
               -- Ada.Text_IO.Put_Line ("da leggere : " & Line);
               -- crea un subset di sotto-stringhe separate dallo spazio o tab
               GNAT.String_Split.Create (Subs, Line, Seps, Mode => GNAT.String_Split.Multiple);
               -- GNAT.String_Split.Slice (Subs, i); -- i-esimo elemento del subset
               if (GNAT.String_Split.Slice (Subs, 5) = "t")
               then
                  box := true;
               else
                  box := false;
               end if;

               seg := new Segment(Positive'Value(GNAT.String_Split.Slice (Subs, 1)),
                                  Positive'Value(GNAT.String_Split.Slice (Subs, 2)),
                                  Positive'Value(GNAT.String_Split.Slice (Subs, 3)),
                                  Positive'Value(GNAT.String_Split.Slice (Subs, 4)),
                                  box);
               if (firstSegment)
               then
                  -- creare il primo referee

                  firstSegment := false;
               else
                  null;
                  -- creare un referee linkato
               end if;
            else
               Ada.Text_IO.Put_Line ("commento : " & Line);
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
