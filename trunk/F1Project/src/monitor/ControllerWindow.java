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
	static int HEIGHT = 300;

	public ControllerWindow(ControllerCommunicator connection, JFrame frame, String[] names, String[] colors) {
		this.frame = frame;
		this.names = names;
		this.colors = colors;
		this.connection = connection;
	}

	public void stop() {
		this.stop = true;
	}

	public void run() {
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