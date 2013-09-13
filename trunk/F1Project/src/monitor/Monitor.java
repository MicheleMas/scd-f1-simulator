import com.inspirel.yami.Agent;
import com.inspirel.yami.OutgoingMessage;
import com.inspirel.yami.Parameters;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.*;

public class Monitor {

	static String publishAddress;
	static String pullAddress;

	static int carNumber;
	static int lapNumber;

	static Communicator connection;
	static Window GUI;

	public static void main(String[] args) {
		if (args.length != 2) {
			System.out.println("Expecting 2 parameters, publish server, pull server");
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

					System.out.println("Connection completed, cars = " + carNumber);

					// leggere la pista
					Drawer map = new Drawer();

					// inizializzare la classe che legge da remoto
				    connection = new Communicator(publishAddress, carNumber, lapNumber, map.getSegmentNumber());
					Thread updater = new Thread(connection);
					updater.start();

					// leggere le info sui piloti
					String[] names, colors;
					Drivers driv = new Drivers(carNumber);
					names = driv.getNames();
					colors = driv.getColors();

					// inizializzazione finestra
					final JFrame frame = new JFrame("Monitor");
					GUI = new Window(connection, frame, map, names, colors);
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
