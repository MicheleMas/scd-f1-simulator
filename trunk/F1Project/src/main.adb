with System;
with Ada.Text_IO;
with Ada.Calendar;
with Ada.Real_Time;

with Circuit;
use Circuit;

procedure Main is
   ref_array : array(1 .. 3) of Referee_Access;
   test_status : Car_Status_Access;
   test_speed : Positive := 1;
   test_towait : Positive := 1;
   test_next : Referee_Access := null;

   use type Ada.Real_Time.Time_Span;
   Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
   Period    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (1000);

begin
   ref_array(3) := new Referee(3,null,null);
   ref_array(2) := new Referee(2,null,ref_array(3));
   ref_array(1) := new Referee(1,null,ref_array(2));

   ref_array(3).setNext(ref_array(1)); -- chiude il ciclo

   test_status := new Car_Status(1,1);
   ref_array(1).enterSegment(1,1, test_speed, 1, test_towait, test_next);



   Ada.Text_IO.Put_Line ("--> " & Positive'image(test_towait));

   Ada.Text_IO.Put_Line ("Hello World!");
   --delay until Poll_Time + Period;
   --Ada.Text_IO.Put_Line ("new speed: " & Positive'image(speed) & ", after: " & Positive'Image(toWait));
   -- Segment.leave;
end Main;
