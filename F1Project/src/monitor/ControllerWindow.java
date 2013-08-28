import javax.swing.*;
import java.util.*;

public class ControllerWindow extends JPanel implements Runnable {

	static JFrame frame;
	static boolean stop = false;
	static int carNumber;
	static String[] names;
	static String[] colors;
	static int WIDTH = 300;
	static int HEIGHT = 300;

	public ControllerWindow(JFrame frame, String[] names, String[] colors) {
		this.frame = frame;
		this.names = names;
		this.colors = colors;
	}

	public void run() {
		
	}
}