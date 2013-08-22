with broker_race_status;
use broker_race_status;

with global_custom_types; use global_custom_types;

package broker_warehouse is

   race_status : race_status_Access;
   detail : detailed_array_Access;

   task type pull_server(status : race_status_Access;
                         Cdetail : detailed_array_Access);

   type pull_server_Access is access pull_server;

end broker_warehouse;
