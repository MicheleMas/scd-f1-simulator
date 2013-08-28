import com.inspirel.yami.Agent;
import com.inspirel.yami.OutgoingMessage;
import com.inspirel.yami.Parameters;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.*;

public class Controller {

	static String pullAddress;
	static String overrideAddress;

	static int carNumber;

	public static void main(String[] args) {
		if (args.length != 2) {
			System.out.println("Expecting 2 parameters, override address and broker(pull) address");
			System.out.println("Using default tcp://localhost:12348 / tcp://localhost:12347");
			pullAddress = "tcp://localhost:12347";
			overrideAddress = "tcp://localhost:12348";
		} else {
			pullAddress = args[1];
			overrideAddress = args[0];
		}

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

					System.out.println("Connection completed, cars = " + carNumber);
				} else {
					Thread.sleep(2000);
				}

				message.close();
				clientAgent.close();

				// get drivers informations
				String[] names, colors;
				Drivers driv = new Drivers(carNumber);
				names = driv.getNames();
				colors = driv.getColors();

				final JFrame frame = new JFrame("Controller");
				// TODO dai frame alla classe che la gestisce
				frame.addWindowListener(new WindowAdapter() {
					@Override
					public void windowClosing(WindowEvent e) {
						// TODO stop the panel thread
						frame.setVisible(false);
						try {
							Thread.currentThread().sleep(2000);
						} catch (Exception ex) {
							ex.printStackTrace();
						}
					}
				});
				// TODO far partire il thread del panel

			} catch (Exception e) {
				try {
					Thread.sleep(2000);
				} catch (Exception e1) {
					e1.printStackTrace();
				}
			}
		}
	}
}