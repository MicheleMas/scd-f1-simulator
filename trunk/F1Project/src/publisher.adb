with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;
with YAMI.Agents;
with YAMI.Parameters;
use YAMI.Parameters;
with YAMI.Serializables;
with YAMI.Value_Publishers;
with Ada.Command_Line;
with Ada.Command_Line;

package body publisher is

   task body Event_Handler is
      event : event_array_Access;
      raceOver : Boolean := false;
      bucket_empty : Boolean := false;

      Content : YAMI.Parameters.Parameters_Collection :=
        YAMI.Parameters.Make_Parameters;
      Client_Agent : YAMI.Agents.Agent := YAMI.Agents.Make_Agent;
      local : boolean := false;
   begin

      race_stat.isOver(raceOver);

      if Ada.Command_Line.Argument_Count /= 1 then
         Ada.Text_IO.Put_Line
           ("No endpoint specified, running locally");
         local := true;
      end if;

      -- send setup information
      Content.Set_String("type", "SP");
      Content.Set_Integer("car_number", YAMI_Integer(custom_types.car_number));
      Content.Set_Integer("laps", YAMI_Integer(custom_types.car_number));
      if(not local)
         then
            Client_Agent.Send_One_Way(Ada.Command_Line.Argument (1),
                                      "Event_Dispatcher",
                                      "event",
                                      Content);
      end if;

      while ((not raceOver) or else (not bucket_empty))
      loop
         event_buffer.get_event(event);

         -- check the kind of the message
         if (event(1) = "ES")
         then
            -- End Segment
            Ada.Text_IO.Put_Line ("Processing event: car " & Ada.Strings.Unbounded.To_String(event(2)) &
                                  " ended segment " & Ada.Strings.Unbounded.To_String(event(3)));
            Content.Set_String("type", Ada.Strings.Unbounded.To_String(event(1)));
            Content.Set_Integer("car", YAMI_Integer(Integer'Value(Ada.Strings.Unbounded.To_String(event(2)))));
            Content.Set_Integer("seg", YAMI_Integer(Integer'Value(Ada.Strings.Unbounded.To_String(event(3)))));
            Content.Set_Integer("vel", YAMI_Integer(Integer'Value(Ada.Strings.Unbounded.To_String(event(4)))));
            Content.Set_Integer("beh", YAMI_Integer(Integer'Value(Ada.Strings.Unbounded.To_String(event(5)))));
            Content.Set_Integer("tire_s", YAMI_Integer(Integer'Value(Ada.Strings.Unbounded.To_String(event(6)))));
            if(event(7) = "T")
            then
               Content.Set_Boolean("tire_t", true);
            else
               Content.Set_Boolean("tire_t", false);
            end if;
         else
            if (event(1) = "EB")
            then
               -- Enter Box
               Ada.Text_IO.Put_Line ("Processing event: car " & Ada.Strings.Unbounded.To_String(event(2)) &
                                     " enter the box");
               Content.Set_String("type", Ada.Strings.Unbounded.To_String(event(1)));
               Content.Set_Integer("car", YAMI_Integer(Integer'Value(Ada.Strings.Unbounded.To_String(event(2)))));
            else
               if (event(1) = "LB")
               then
                  -- Leave Box
                  Ada.Text_IO.Put_Line ("Processing event: car " & Ada.Strings.Unbounded.To_String(event(2)) &
                                        " left the box");
                  Content.Set_String("type", Ada.Strings.Unbounded.To_String(event(1)));
                  Content.Set_Integer("car", YAMI_Integer(Integer'Value(Ada.Strings.Unbounded.To_String(event(2)))));
                  if(event(3) = "T")
                  then
                     Content.Set_Boolean("tire_t", true);
                  else
                     Content.Set_Boolean("tire_t", false);
                  end if;
                  Content.Set_Integer("lap", YAMI_Integer(Integer'Value(Ada.Strings.Unbounded.To_String(event(4)))));
               else
                  if (event(1) = "EL")
                  then
                     -- End Lap
                     Ada.Text_IO.Put_Line ("Processing event: car " & Ada.Strings.Unbounded.To_String(event(2)) &
                                           " end lap " & Ada.Strings.Unbounded.To_String(event(3)));
                     Content.Set_String("type", Ada.Strings.Unbounded.To_String(event(1)));
                     Content.Set_Integer("car", YAMI_Integer(Integer'Value(Ada.Strings.Unbounded.To_String(event(2)))));
                  else
                     if (event(1) = "CE")
                     then
                        -- Car End
                        Ada.Text_IO.Put_Line ("Processing event: car " & Ada.Strings.Unbounded.To_String(event(2)) &
                                              " end the race");
                        Content.Set_String("type", Ada.Strings.Unbounded.To_String(event(1)));
                        Content.Set_Integer("car", YAMI_Integer(Integer'Value(Ada.Strings.Unbounded.To_String(event(2)))));
                     else
                        if (event(1) = "ER")
                        then
                           -- End Race
                           Ada.Text_IO.Put_Line ("Processing event: end race");
                           Content.Set_String("type", Ada.Strings.Unbounded.To_String(event(1)));
                        else
                           if (event(1) = "CA")
                           then
                              -- Car Accident
                              Ada.Text_IO.Put_Line ("Processing event car " & Ada.Strings.Unbounded.To_String(event(2)) &
                                                    " car incident occurs, " & Ada.Strings.Unbounded.To_String(event(3)) &
                                                    " " & Ada.Strings.Unbounded.To_String(event(4)));
                              Content.Set_String("type", Ada.Strings.Unbounded.To_String(event(1)));
                              Content.Set_Integer("car", YAMI_Integer(Integer'Value(Ada.Strings.Unbounded.To_String(event(2)))));
                              if(event(3) = "T")
                              then
                                 Content.Set_Boolean("damage", true);
                              else
                                 Content.Set_Boolean("damage", false);
                              end if;
                              if(event(4) = "T")
                              then
                                 Content.Set_Boolean("retired", true);
                              else
                                 Content.Set_Boolean("retired", false);
                              end if;
                           else
                              if (event(1) = "WC")
                              then
                                 -- Weather Change
                                 Ada.Text_IO.Put_Line ("Processing event: Weather Change, rain: " &
                                                       Ada.Strings.Unbounded.To_String(event(2)));
                                 Content.Set_String("type", Ada.Strings.Unbounded.To_String(event(1)));
                                 if(event(2) = "T")
                                 then
                                    Content.Set_Boolean("rain", true);
                                 else
                                    Content.Set_Boolean("rain", false);
                                 end if;
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;

         if(not local)
         then
            Client_Agent.Send_One_Way(Ada.Command_Line.Argument (1),
                                      "Event_Dispatcher",
                                      "event",
                                      Content);
         end if;

         --Publisher.Publish(Content);
         race_stat.isOver(raceOver);
         event_buffer.is_bucket_empty(bucket_empty);
      end loop;

      -- race is over
      Ada.Text_IO.Put_Line ("Processing event: Race Over");
      Content.Set_String("type", "ER");
      if(not local)
         then
            Client_Agent.Send_One_Way(Ada.Command_Line.Argument (1),
                                      "Event_Dispatcher",
                                      "event",
                                      Content);
         end if;
      --Publisher.Publish(Content);

      delay(3.0);
      Ada.Text_IO.Put_Line ("task eventi concluso");
   end Event_Handler;

end publisher;
