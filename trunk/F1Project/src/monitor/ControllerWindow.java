import javax.swing.*;
import java.util.*;

public class ControllerWindow extends JPanel implements Runnable {

	static JFrame frame;
	static boolean stop = false;
	static int carNumber;
	static String[] names;
	static String[] colors;
	static ControllerCommunicator connection;
	static int WIDTH = 300;
	static int HEIGHT = 400;
	static int driverSelected = 0;
	static boolean selected = false;

	public ControllerWindow(ControllerCommunicator connection, JFrame frame, String[] names, String[] colors) {
		this.frame = frame;
		this.names = names;
		this.colors = colors;
		this.connection = connection;
	}

	public void stop() {
		stop = true;
	}

	public void run() {
		frame.setSize(WIDTH, HEIGHT);
		JPanel panel = (JPanel) frame.getContentPane();
		panel.setLayout(null);

		JLabel title = new JLabel("<html><h2>Controller</h2></html>");
		title.setBounds(100, 5, 100, 20);
		JComboBox driversList = new JComboBox(names);
		driversList.setBounds(50, 40, 200, 30);
		JLabel infoLabel = new JLabel("<html>Speed = 200<br>AVG Speed = 200<br>Tire Status = 10000<br>Tyre type = rain<br>Behaviour = 10</html>");
		//JLabel infoLabel = new JLabel("");
		infoLabel.setBounds(30, 80, 240, 130);
		JLabel box = new JLabel("Schedule box entrance:");
		box.setBounds(20, 222, 260, 20);
		JButton boxButton = new JButton("Schedule Box");
		boxButton.setBounds(60, 250, 180, 20);
		JLabel behLabel = new JLabel("Set driver behaviour (1-10):");
		behLabel.setBounds(20, 280, 260, 20);
		JFormattedTextField behInput = new JFormattedTextField();
		behInput.setColumns(2);
		behInput.setBounds(60, 310, 40, 20);
		JButton behButton = new JButton("Set");
		behButton.setBounds(160, 310, 80, 20);

		// TODO aggiungere il listener della lista
		panel.add(title);
		panel.add(driversList);
		panel.add(infoLabel);
		panel.add(box);
		panel.add(boxButton);
		panel.add(behLabel);
		panel.add(behInput);
		panel.add(behButton);
		frame.setLocationRelativeTo(null);
		frame.setVisible(true);

		while(!stop) {
			try {
				Thread.currentThread().sleep(2000);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}