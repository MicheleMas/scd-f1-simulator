import javax.swing.*;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.util.*;

public class ControllerWindow extends JPanel implements Runnable {

	static JFrame frame;
	static boolean stop = false;
	static String[] names;
	static String[] colors;
	static ControllerCommunicator connection;
	static int WIDTH = 300;
	static int HEIGHT = 400;
	static int driverSelected = 0;
	static boolean driverSet = false;
	static JButton boxButton;
	static JButton behButton;
	static JFormattedTextField behInput;

	public ControllerWindow(ControllerCommunicator connection, JFrame frame, String[] names, String[] colors) {
		this.frame = frame;
		this.names = names;
		this.colors = colors;
		this.connection = connection;
	}

	public void stop() {
		stop = true;
	}

	public void setSelectedDriver(int driv) {
		driverSelected = driv;
		System.out.println("Selezionato pilota "+(driv+1));
		if (!driverSet) {
			driverSet = true;
			boxButton.setEnabled(true);
			behButton.setEnabled(true);
			behInput.setEnabled(true);
		}
	}

	public void setBoxSchedule() {
		connection.overrideBoxEntrance(driverSelected);
	}

	public void setBehaviour() {
		String reading = behInput.getText();
		try {
			int newBehaviour = Integer.parseInt(reading);
			if (newBehaviour < 1) {
				newBehaviour = 1;
				behInput.setText(""+newBehaviour);
			}
			if (newBehaviour > 10) {
				newBehaviour = 10;
				behInput.setText(""+newBehaviour);
			}
			connection.overrideBehaviour(driverSelected, newBehaviour);
		} catch (NumberFormatException e) {
			System.out.println("behaviour: not a number");
			behInput.setText(""+8);
		}
	}

	public void run() {
		frame.setSize(WIDTH, HEIGHT);
		JPanel panel = (JPanel) frame.getContentPane();
		panel.setLayout(null);

		JLabel title = new JLabel("<html><h2>Controller</h2></html>");
		title.setBounds(100, 5, 100, 20);
		JComboBox driversList = new JComboBox(names);
		driversList.setBounds(50, 40, 200, 30);
		JLabel infoLabel = new JLabel("");
		infoLabel.setBounds(60, 80, 240, 150);
		JLabel box = new JLabel("Schedule box entrance:");
		box.setBounds(20, 242, 260, 20);
		boxButton = new JButton("Schedule Box");
		boxButton.setBounds(60, 270, 180, 20);
		boxButton.setEnabled(false);
		JLabel behLabel = new JLabel("Set driver behaviour (1-10):");
		behLabel.setBounds(20, 300, 260, 20);
		behInput = new JFormattedTextField();
		behInput.setColumns(2);
		behInput.setBounds(60, 330, 40, 20);
		behInput.setEnabled(false);
		behButton = new JButton("Set");
		behButton.setBounds(160, 330, 80, 20);
		behButton.setEnabled(false);

		driversList.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e) {
				JComboBox cb = (JComboBox)e.getSource();
				String selected = (String)cb.getSelectedItem();
				int result = 0;
				for (int i=0; i<names.length; i++) {
					if (selected.equals(names[i])) {
						result = i;
						break;
					}
				}
				setSelectedDriver(result);
			}
		});
		boxButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				setBoxSchedule();
			}
		});
		behButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				setBehaviour();
			}
		});
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

		String text;
		Detail det;
		while(!stop) {
			try {
				if (driverSet) {
					det = connection.getDetails(driverSelected);
					text = "<html><table><tr><td><b>Speed</b></td><td>"+det.getSpeed()+"</td></tr>";
					text += "<tr><td><b>AVG Speed</b></td><td>"+det.getAvgSpeed()+"</td></tr>";
					int bestLap = det.getBestLap();
					String bestLapLabel = "";
					if (bestLap == 0) {
						bestLapLabel = "-";
					} else {
						float seconds = (((float)bestLap)/1000);
						int minutes = (int)Math.floor(seconds/60);
						bestLapLabel += ""+minutes+"m ";
						seconds -= 60*minutes;
						bestLapLabel += ""+((int)Math.floor(seconds))+"s";
					}
					text += "<tr><td><b>Best Lap</b></td><td>"+bestLapLabel+"</td></tr>";
					if (det.getTireStatus() == -1)
						text += "<tr><td><b>Tire Status</b></td><td>"+"BOX"+"</td></tr>";
					else
						text += "<tr><td><b>Tire Status</b></td><td>"+det.getTireStatus()+"</td></tr>";
					if (det.getRainTire())
						text += "<tr><td><b>Tire Type</b></td><td>"+"Rain"+"</td></tr>";
					else
						text += "<tr><td><b>Tire Type</b></td><td>"+"Dry"+"</td></tr>";
					if (det.getBehaviour() == -1) 
						text += "<tr><td><b>Behaviour</b></td><td>"+"BOX"+"</td></tr>";
					else
						text += "<tr><td><b>Behaviour</b></td><td>"+det.getBehaviour()+"/10</td></tr>";
					text += "<tr><td><b>Box Schedule</b></td><td>"+det.getRBox()+"</td></tr>";
					text += "</table></html>";
					infoLabel.setText(text);
				}
				Thread.currentThread().sleep(1000);
			} catch (Exception e) {
				//e.printStackTrace();
				System.out.println("Connection closed");
				stop = true;
				text = "<html><h2>Connection<br>Closed</h2></html>";
				infoLabel.setText(text);
				boxButton.setEnabled(false);
				behButton.setEnabled(false);
				driversList.setEnabled(false);
				behInput.setEnabled(false);
			}
		}
	}
}