import com.inspirel.yami.Agent;
import com.inspirel.yami.OutgoingMessage;
import com.inspirel.yami.Parameters;

public class Monitor {

	static String publishAddress;
	static String pullAddress;

	static int carNumber;
	static int lapNumber;

	public static void main(String[] args) {
		if (args.length != 2) {
			System.out.println("Expecting 2 parameters, publish server and pull server");
			System.out.println("Using default tcp://localhost:12346 / tcp://localhost:12347");
			publishAddress = "tcp://localhost:12346";
			pullAddress = "tcp://localhost:12347";
		} else {
			publishAddress = args[0];
			pullAddress = args[1];
		}

		// setup
		String request = "S";
		System.out.println("Waiting for the connection");
		boolean setupCompleted = false;
		while(!setupCompleted) {
			try {
				Agent clientAgent = new Agent();

				Parameters params = new Parameters();
				params.setString("type", request);
				OutgoingMessage message = clientAgent.send(pullAddress, "warehouse", "setup", params);

				message.waitForCompletion();
				OutgoingMessage.MessageState state = message.getState();

				if (state == OutgoingMessage.MessageState.REPLIED) {
					setupCompleted = true;
					Parameters reply = message.getReply();

					carNumber = reply.getInteger("cars");
					lapNumber = reply.getInteger("laps");

					System.out.println("Connection completed");
				} else {
					Thread.sleep(2000);
				}
			

				// dovrà farlo il thread client del pull server, non il main
				message.close();
				clientAgent.close();

			} catch (Exception e) {
				//System.out.println("error " + e.getMessage());
				try {
					Thread.sleep(2000);
				} catch (Exception e1) {
					System.out.println("error " + e.getMessage());
				}
			}
		}
	}
}