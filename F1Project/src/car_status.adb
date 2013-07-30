package body car_status is

   -----------------------------------------------------------------------
   --------------------------- CAR STATUS --------------------------------
   -----------------------------------------------------------------------

   protected body Car_Status is
      -- override procedure
      procedure Change_Tires (order : in Boolean) is
      begin
         change_tires_required := order;
      end Change_Tires;
      procedure Change_Behaviour (bv : in Positive) is
      begin
         behaviour := bv;
      end Change_Behaviour;

      -- setter procedure
      procedure set_tires_status (newState : in Positive) is
      begin
         tires_status := newState;
      end set_tires_status;
      procedure set_rain_tires (newTires : in Boolean) is
      begin
         rain_tires := newTires;
      end set_rain_tires;
      --procedure set_currentSegment (currentSeg : in Segment_Access) is
      --begin
      --   currentSegment := currentSeg;
      --end set_currentSegment;
      procedure set_currentSpeed (newSpeed : in Float) is
      begin
         currentSpeed := newSpeed;
      end set_currentSpeed;
      procedure set_damage (status : in Boolean) is
      begin
         damaged := status;
      end set_damage;

      -- getter function
      function get_name return Positive is
      begin
         return name;
      end get_name;
      function get_tires_state return Positive is
      begin
         return tires_status;
      end get_tires_state;
      function get_rain_tires return Boolean is
      begin
         return rain_tires;
      end get_rain_tires;
      --function get_currentSegment return Segment_Access is
      --begin
      --   return currentSegment;
      --end get_currentSegment;
      function get_currentSpeed return Float is
      begin
         return currentSpeed;
      end get_currentSpeed;
      function get_currentBehaviour return Positive is
      begin
         return behaviour;
      end get_currentBehaviour;
      function is_damaged return Boolean is
      begin
         return damaged;
      end is_damaged;
      function pitStop4tires return Boolean is
      begin
           return change_tires_required;
      end pitStop4tires;
   end Car_Status;

end car_status;
