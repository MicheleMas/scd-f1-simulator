with System;
with Ada.Text_IO;
with Ada.Calendar;
with Ada.Real_Time;


with Circuit;
use Circuit;

procedure Main is
   lag : constant Duration := 5.0;
   --nome : array(0 .. 5) of Segment;
   -- arbitro : array(1 .. 3) of Referee;
   culo : Segment_Access;
   --camicia : Referee;

   ref_array : array(1 .. 3) of Referee_Access;
   speed : Positive := 230;
   toWait : Positive;
   nextR : Referee_Access;

   use type Ada.Real_Time.Time_Span;
   Poll_Time :          Ada.Real_Time.Time := Ada.Real_Time.Clock; -- time to start polling
   Period    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (1000);

begin
   -- override
   culo := new Segment(1,2,3,4,false);
   ref_array(1) := new Referee(1,null,null);
   ref_array(1).setSegment(culo);

   ref_array(1).enterSegment(1, 1, speed, 1, toWait, nextR);


   Ada.Text_IO.Put_Line ("Hello World!");
   delay until Poll_Time + Period;
   Ada.Text_IO.Put_Line ("new speed: " & Positive'image(speed) & ", after: " & Positive'Image(toWait));
   -- Segment.leave;
end Main;
