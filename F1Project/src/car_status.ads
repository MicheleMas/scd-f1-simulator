package car_status is

   -----------------------------------------------------------------------
   --------------------------- CAR STATUS --------------------------------
   -----------------------------------------------------------------------

   protected type Car_Status (name : Positive;
                              C_behaviour : Positive;
                              max_speed : Positive;
                              acceleration : Positive) is
      -- override procedures
      procedure Change_Tires (order : in Boolean);
      procedure Change_Behaviour (bv : in Positive);

      -- setter procedures
      procedure set_tires_status (newState : in Integer);
      procedure set_rain_tires (newTires : in Boolean);
      procedure set_currentSpeed (newSpeed : in Float);
      procedure set_damage (status : in Boolean);

      -- getter functions
      function get_name return Positive;
      function get_tires_state return Integer;
      function get_rain_tires return Boolean;
      function get_currentSpeed return Float;
      function get_currentBehaviour return Positive;
      function is_damaged return Boolean;
      function pitStop4tires return Boolean;
   private
      change_tires_required : Boolean := false;
      tires_status : Integer := 10000; --  correct value is between 1 to 10000
      rain_tires : Boolean := false;
      behaviour : Positive := C_behaviour; -- from 1 to 10
      currentSpeed : Float := 0.0;
      damaged : Boolean := false;
   end Car_Status;

   type Car_Status_Access is access Car_Status;

end car_status;
