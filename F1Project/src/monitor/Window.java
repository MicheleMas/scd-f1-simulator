import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.*;
import java.util.*;

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
		List<Rank> ranking = new ArrayList<Rank>();

		/*boolean wait = true; // wait for car data
		while(!stop && wait) {
			det = updater.raceUpdate(carNumber-1);
			if(det != null){
				wait = false;
			} else {
				try {
					Thread.currentThread().sleep(1000);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}*/

		while(!stop) {
			try {				
				// create ranking
				for (int i=0; i<carNumber; i++) {
					det = updater.raceUpdate(i);
					if(det != null) {
						ranking.add(new Rank(det.getRank(), i));
					}
				}
				Collections.sort(ranking);
				text = "<html>";
				while(!ranking.isEmpty()) {
					int carID = ranking.remove(0).carID;
					det = updater.raceUpdate(carID);
					text += "macchina:" + (carID+1) + " giro:" + det.getLap() + " segmento:" + det.getSeg()
					    + " progress:" + det.getProg() + " incidente:" + det.getInci() 
					    + " ritirato:" + det.getRet() + " concluso:" + det.getOver() + "<br>";
				}
				text += "</html>";

				/*text = "<html>";
				for (int i=0; i<carNumber; i++) {
					det = updater.raceUpdate(i);
					if(det != null) {
						text += "macchina " + (i+1) + " " + det.getLap() + " " + det.getSeg() + " " + det.getProg() + " " 
						+ det.getInci() + " " + det.getRet() + " " + det.getOver() + "<br>";
					}
				}
				text += "</html>";*/


				label.setText(text);
				frame.pack();
				Thread.currentThread().sleep(500);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private class Rank implements Comparable<Rank> {
		int rank;
		int carID;

		public Rank(int rank, int carID) {
			this.rank = rank;
			this.carID = carID;
		}

		@Override
		public int compareTo(Rank o) {
			return rank < o.rank ? -1 : rank > o.rank ? 1 : 0;
		}
	}
}