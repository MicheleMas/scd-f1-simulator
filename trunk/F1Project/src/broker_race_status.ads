package broker_race_status is

   protected type race_status is

      procedure set_weather(weather : in boolean);
      procedure get_weather(weather : out boolean);

   private

      weather : boolean;

   end race_status;

end broker_race_status;
