with Ada.Text_IO;
with global_custom_types;
use global_custom_types;
with GNAT.String_Split;
with car_status;
use car_status;

package body parser is

   function readCircuit (Filename : in String) return Referee_Access is
      File       : Ada.Text_IO.File_Type;
      Line_Count : Natural := 0;
      First_Ref  : Referee_Access := null;
      Current_Ref : Referee_Access := null;
      Subs : GNAT.String_Split.Slice_Set;
      Seps : String := " " & ASCII.HT;
      firstSegment : Boolean := true;
      firstread : Boolean := true;
   begin
      Ada.Text_IO.Open (File => File,
                        Mode => Ada.Text_IO.In_File,
                        Name => Filename);
      while not Ada.Text_IO.End_Of_File (File) loop
         declare
            Line : String := Ada.Text_IO.Get_Line (File);
            seg : Segment_Access := null;
            box : Boolean;
            Working_Ref : Referee_Access := null;
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
                                  Natural'Value(GNAT.String_Split.Slice (Subs, 4)),
                                  box);
               if (firstSegment)
               then
                  -- creare il primo referee
                  First_Ref := new Referee(seg.id, null, null);
                  First_Ref.setSegment(seg);
                  Current_Ref := First_Ref;
                  firstSegment := false;
               else
                  -- creare un referee linkato
                  Working_Ref := new Referee(seg.id, null, First_Ref);
                  Working_Ref.setSegment(seg);
                  -- we mark as started all segments except first
                  Working_Ref.setStart;
                  Current_Ref.setNext(Working_Ref);
                  Current_Ref := Working_Ref;
               end if;
            end if;

		--- costruzione del circuito a partire dai dati di ogni linea
		--- ogni riga del file contiene i dati di un segmento
		--- il segmento successivo sarà quello che viene dopo
		--- quando la riga dopo è vuota collego al primo
		--- dopo aver creato il segmento, crea il referee associato
		--- ritorna il puntatore al primo referee
         end;
      end loop;
      Current_Ref.setNext(First_Ref);
      Ada.Text_IO.Close (File);
      return First_Ref;
   end readCircuit;

   --- funzione che legge le macchine
   function readCars (Filename : in String) return arrayOfCars is
      File       : Ada.Text_IO.File_Type;
      Line_Count : Natural := 0;
      Cars_Array : arrayOfCars;
      Subs : GNAT.String_Split.Slice_Set;
      Seps : String := " " & ASCII.HT;
      car  : Car_Status_Access := null;
      carnumber: Integer := 0;
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
 	    if (not (Line(Line'First) = '#'))
            then
               GNAT.String_Split.Create (Subs, Line, Seps, Mode => GNAT.String_Split.Multiple);
               -- la riga successiva riempie i campi del Car_Status dichiarato di car_p.ads
               car := new car_status.Car_Status(Positive'Value(GNAT.String_Split.Slice (Subs, 1)),
                                                Positive'Value(GNAT.String_Split.Slice (Subs, 2)),
                                                Positive'Value(GNAT.String_Split.Slice (Subs, 3)),
                                                Positive'Value(GNAT.String_Split.Slice (Subs, 4)));
               carNumber := carNumber + 1;
               Cars_Array(carNumber):= car;
            end if;

            --- in ogni riga ci sono i dati di una macchina
            --- crea l'array con i dati di ogni macchina
         end;
      end loop;
      Ada.Text_IO.Close (File);
      return Cars_Array;
   end readCars;

   procedure readProperties(Filename : in String;
                            cnumber : out Integer;
                            lnumber : out Integer) is
      File       : Ada.Text_IO.File_Type;
      Line_Count : Natural := 0;
      Subs : GNAT.String_Split.Slice_Set;
      Seps : String := " " & ASCII.HT;
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
 	    if (not (Line(Line'First) = '#'))
            then
               GNAT.String_Split.Create (Subs, Line, Seps, Mode => GNAT.String_Split.Multiple);
               -- la riga successiva riempie i campi del Car_Status dichiarato di car_p.ads
               cnumber := Integer'Value(GNAT.String_Split.Slice (Subs, 1));
               lnumber := Integer'Value(GNAT.String_Split.Slice (Subs, 2));
            end if;
         end;
      end loop;
      Ada.Text_IO.Close (File);
   end readProperties;


end parser;
