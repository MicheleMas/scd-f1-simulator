with Ada.Text_IO;

package parser is

   function Line_By_Line (Filename : in String) return Segment_Access is
      File       : Ada.Text_IO.File_Type;
      Line_Count : Natural := 0;
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
         end;
      end loop;
      Ada.Text_IO.Close (File);
   end Line_By_Line;


end parser;
