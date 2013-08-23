import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.*;

public class Window implements Runnable {

	static JFrame frame;
	static Communicator updater;
	static boolean stop = false;
	static int carNumber;

	public Window (Communicator updater, JFrame frame) {
		this.frame = frame;
		this.updater = updater;
		this.carNumber = updater.getCarNumber();
	}

	public static void stop() {
		stop = true;
		updater.stop();
	}

	public void run() {

		JPanel panel = (JPanel) frame.getContentPane();
		JLabel label = new JLabel();
		panel.add(label);
		label.setText("prova");
		frame.setLocationRelativeTo(null);
		frame.pack();
		frame.setVisible(true);

		Detail det;
		String text = "";

		while(!stop) {
			try {
				text = "<html>";
				for (int i=0; i<carNumber; i++) {
					det = updater.raceUpdate(i);
					if(det != null) {
						text += "macchina " + (i+1) + " " + det.getLap() + " " + det.getSeg() + " " + det.getProg() + " " 
						+ det.getInci() + " " + det.getRet() + " " + det.getOver() + "<br>";
					}
				}
				text += "</html>";
				label.setText(text);
				frame.pack();
				Thread.currentThread().sleep(500);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}