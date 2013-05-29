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
   test_car : Car_Access := null;
   test_car2 : Car_Access := null;
   test_car3 : Car_Access := null;

   use type Ada.Real_Time.Time_Span;
   Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
   Period    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (1000);

begin
   ref_array(3) := new Referee(3,null,null);
   ref_array(3).setSegment(null);
   ref_array(2) := new Referee(2,null,ref_array(3));
   ref_array(2).setSegment(null);
   ref_array(1) := new Referee(1,null,ref_array(2));
   ref_array(1).setSegment(null);

   ref_array(3).setNext(ref_array(1)); -- chiude il ciclo

   --   ref_array(1).enterSegment(1,1, test_speed, 1, test_towait, test_next);
   test_status := new Car_Status(1,1);

   test_car := new Car(1,ref_array(1),test_status);
   test_car2 := new Car(2,ref_array(2),test_status);
   test_car3 := new Car(3,ref_array(3),test_status);




   Ada.Text_IO.Put_Line ("--> " & Positive'image(test_next.id));

   Ada.Text_IO.Put_Line ("Hello World!");
   --delay until Poll_Time + Period;
   --Ada.Text_IO.Put_Line ("new speed: " & Positive'image(speed) & ", after: " & Positive'Image(toWait));
   -- Segment.leave;
end Main;
