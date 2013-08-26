with global_custom_types;
use global_custom_types;
with parser;
use parser;

package controller_server is

   task type controller_listener(race_status : race_status_Access;
                                 car_status : arrayOfCarsAccess);

end controller_server;
