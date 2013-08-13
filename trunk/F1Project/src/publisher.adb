with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;
with YAMI.Agents;
with YAMI.Parameters;
with YAMI.Serializables;
with YAMI.Value_Publishers;

package body publisher is

   task body Event_Handler is
      event : Unbounded_String;
      raceOver : Boolean := false;
      bucket_empty : Boolean := false;
      Publisher_Address : constant String := "tcp://localhost:12345"; -- this should be passed
                                                                -- with constructor paramether
      Publisher_Agent : aliased YAMI.Agents.Agent := YAMI.Agents.Make_Agent;
      Resolved_Publisher_Address : String (1 .. YAMI.Agents.Max_Target_Length);
      Resolved_Publisher_Address_Last : Natural;

      Publisher : YAMI.Value_Publishers.Value_Publisher :=
        YAMI.Value_Publishers.Make_Value_Publisher;
      Content : YAMI.Parameters.Parameters_Collection :=
        YAMI.Parameters.Make_Parameters;

   begin

      race_stat.isOver(raceOver);
      Ada.Text_IO.Put_Line ("arrivo fino a qui!");
      Publisher_Agent.Add_Listener(Target               => Publisher_Address,
                                   Resolved_Target      => Resolved_Publisher_Address,
                                   Resolved_Target_Last => Resolved_Publisher_Address_Last);
      Publisher.Register_At(The_Agent   => Publisher_Agent'Unchecked_Access,
                            Object_Name => "event_publisher");

      while ((not raceOver) or else (not bucket_empty))
      loop
         event_buffer.get_event(event);

         Content.Set_String(Name  => "event",
                            Value => Ada.Strings.Unbounded.To_String(event));
         Publisher.Publish(Content);
         Ada.Text_IO.Put_Line ("Processed event " & Ada.Strings.Unbounded.To_String(event));

         race_stat.isOver(raceOver);
         event_buffer.is_bucket_empty(bucket_empty);
      end loop;
      Ada.Text_IO.Put_Line ("task eventi concluso");
   end Event_Handler;

end publisher;
