import com.inspirel.yami.Agent;
import com.inspirel.yami.OutgoingMessage;
import com.inspirel.yami.Parameters;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.*;

public class Controller {

	static String pullAddress;
	static String overrideAddress;
	static ControllerWindow GUI;
	static int carNumber;

	public static void main(String[] args) {
		if (args.length != 2) {
			System.out.println("Expecting 2 parameters, override address and broker(pull) address");
			System.out.println("Using default tcp://localhost:12348 / tcp://localhost:12347");
			pullAddress = "tcp://localhost:12347";
			overrideAddress = "tcp://localhost:12348";
		} else {
			pullAddress = args[0];
			overrideAddress = args[1];
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

					// get drivers informations
					String[] names, colors;
					Drivers driv = new Drivers(carNumber);
					names = driv.getNames();
					colors = driv.getColors();

					// inizializzare la classe che comunica con le altre parti
					ControllerCommunicator connection = new ControllerCommunicator(pullAddress, overrideAddress);

					// inizializzare finestra
					final JFrame frame = new JFrame("Controller");
					GUI = new ControllerWindow(connection, frame, names, colors);
					frame.addWindowListener(new WindowAdapter() {
					@Override
					public void windowClosing(WindowEvent e) {
						GUI.stop();
						frame.setVisible(false);
						try {
							Thread.currentThread().sleep(2000);
						} catch (Exception ex) {
							ex.printStackTrace();
						}
						System.exit(0);
					}
					});
					Thread window = new Thread(GUI);
					window.start();
				} else {
					Thread.sleep(2000);
				}

				message.close();
				clientAgent.close();

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
