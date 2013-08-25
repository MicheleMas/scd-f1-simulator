import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.BorderLayout;
import java.awt.RenderingHints;
//import java.awt.GridBagLayout;
//import java.awt.GridBagConstraints;
import java.awt.GridLayout;
import javax.swing.*;
import java.util.*;

public class Window extends JPanel implements Runnable {

	static JFrame frame;
	static Communicator updater;
	static boolean stop = false;
	static int carNumber;
	static int[] x;
	static int[] y;
	static boolean ready = false;

	public Window (Communicator updater, JFrame frame) {
		this.frame = frame;
		this.updater = updater;
		this.carNumber = updater.getCarNumber();
		x = new int[carNumber];
		y = new int[carNumber];
	}

	public static void stop() {
		stop = true;
		updater.stop();
	}

	@Override
	public void paint(Graphics g) {
		super.paint(g);
		Graphics g2d = (Graphics2D) g;
		//g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
		if(ready) {
			for (int i=0; i<carNumber; i++) {
				g2d.fillOval(x[i], y[i], 10, 10);
			}
		}
	}

	public void run() {

		JPanel panel = (JPanel) frame.getContentPane();
		Box container = Box.createHorizontalBox();
		//container.setLayout(new GridLayout(1, 2));
		//JPanel buttonContainer = new JPanel();
		Box buttonContainer = Box.createVerticalBox();

		// create buttons
		JButton[] buttonArray = new JButton[carNumber];
		//buttonContainer.setLayout(new GridLayout(carNumber, 1));
		//GridBagConstraints gbc = new GridBagConstraints();
		for (int i=0; i<carNumber; i++) {
			buttonArray[i] = new JButton("Car " + (i+1));
			buttonContainer.add(buttonArray[i]);
		}
		container.add(buttonContainer, BorderLayout.WEST);
		JLabel rankLabel = new JLabel();
		container.add(rankLabel, BorderLayout.EAST);
		panel.add(container, BorderLayout.SOUTH);
		JPanel race = this;
		panel.add(race, BorderLayout.CENTER);
		rankLabel.setText("prova");
		frame.setLocationRelativeTo(null);
		frame.setSize(750, 560);
		frame.setVisible(true);

		Status stat;
		Detail det;
		String text = "";
		List<Rank> ranking = new ArrayList<Rank>();

		/*boolean wait = true; // wait for car data
		while(!stop && wait) {
			stat = updater.raceUpdate(carNumber-1);
			if(stat != null){
				wait = false;
			} else {
				try {
					Thread.currentThread().sleep(1000);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}*/

		// setup
		for (int i=0; i<carNumber; i++) {
			x[i] = 0;
			y[i] = i*10;
		}

		ready = true;

		while(!stop) {
			try {				
				// create ranking
				for (int i=0; i<carNumber; i++) {
					stat = updater.raceUpdate(i);
					if(stat != null) {
						ranking.add(new Rank(stat.getRank(), i));
					}
				}
				Collections.sort(ranking);
				int counter = 1;
				text = "<html>Classifica<br>";
				while(!ranking.isEmpty()) {
					int carID = ranking.remove(0).carID;
					stat = updater.raceUpdate(carID);
					text += counter + "° " + "macchina:" + (carID+1) + " giro:" + stat.getLap() + " segmento:" 
					    + stat.getSeg() + " progress:" + stat.getProg() + " incidente:" + stat.getInci() 
					    + " ritirato:" + stat.getRet() + " concluso:" + stat.getOver() + "<br>";
					counter++;
					// update position
					x[carID] = (100 * (stat.getLap()-1)) + (10 * (stat.getSeg()-1)) + (stat.getProg() / 10);
				}
				//stampa i dettagli della prima macchina per testare il pull
				//det = updater.getDetails(0);
				//if(det != null) {
					//text += "TEST dettagli macchina 1: velocità: " + det.getSpeed();
				//}

				text += "</html>";
				race.validate();
				race.repaint();
				/*text = "<html>";
				for (int i=0; i<carNumber; i++) {
					det = updater.raceUpdate(i);
					if(det != null) {
						text += "macchina " + (i+1) + " " + det.getLap() + " " + det.getSeg() + " " + det.getProg() + " " 
						+ det.getInci() + " " + det.getRet() + " " + det.getOver() + "<br>";
					}
				}
				text += "</html>";*/


				rankLabel.setText(text);
				//frame.pack();
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