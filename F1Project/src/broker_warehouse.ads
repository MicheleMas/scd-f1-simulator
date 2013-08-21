with broker_race_status;
use broker_race_status;

package broker_warehouse is

   task type pull_server(status : race_status_Access);

   type pull_server_Access is access pull_server;

end broker_warehouse;
