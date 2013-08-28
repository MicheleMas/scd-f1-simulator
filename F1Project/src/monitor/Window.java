import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.BorderLayout;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.awt.Point;
import java.awt.Color;
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
	static BufferedImage track;
	static Drawer map;
	static final int HEIGHT = 650;
	static final int WIDTH = 960;
	static final int RACE_H = 400;
	static final int RACE_W = 780;
	static String[] names;
	static String[] colors;

	public Window (Communicator updater, JFrame frame, Drawer map, String[] names, String[] colors) {
		this.frame = frame;
		this.updater = updater;
		this.carNumber = updater.getCarNumber();
		this.names = names;
		this.colors = colors;
		this.map = map;
		this.track = map.getTrack(RACE_W, RACE_H);
		x = new int[carNumber];
		y = new int[carNumber];
	}

	public static void stop() {
		stop = true;
		updater.stop();
	}

	@Override
	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		g.drawImage(track, 0, 0, null);
		Graphics g2d = (Graphics2D) g;
		//g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
		if(ready) {
			for (int i=0; i<carNumber; i++) {
				g2d.setColor(Color.decode("0x"+colors[i]));
				g2d.fillOval(x[i], y[i], 10, 10);
			}
		}
	}

	public void run() {
		frame.setSize(WIDTH, HEIGHT);
		JPanel panel = (JPanel) frame.getContentPane();
		panel.setLayout(null);
		Box container = Box.createHorizontalBox();
		JLabel rankLabel = new JLabel();
		JLabel title = new JLabel("<html><h1>F1 Simulator</h1></html>");
		JPanel race = this;
		title.setBounds((WIDTH/2)-110, 10, (WIDTH/2), 30);
		race.setBounds(0,110, RACE_W, RACE_H+110);
		rankLabel.setBounds(RACE_W, 0, WIDTH, HEIGHT);
		panel.add(title);
		panel.add(race);
		panel.add(rankLabel);
		rankLabel.setText("prova");
		frame.setLocationRelativeTo(null);
		
		frame.setVisible(true);

		Status stat;
		Detail det;
		String text = "";
		List<Rank> ranking = new ArrayList<Rank>();

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
						int carRank = stat.getRank();
						if (carRank == 0) {
							carRank += carNumber;
						}
						ranking.add(new Rank(carRank, i));
					}
				}
				Collections.sort(ranking);
				Point p;
				int counter = 1;
				text = "<html><h2>Ranking:</h2><table border='1'><tr><td><b>Position</b></td><td><b>Pilot</b></td><td><b>Lap</b></td></tr>";
				while(!ranking.isEmpty()) {
					int carID = ranking.remove(0).carID;
					stat = updater.raceUpdate(carID);
					text += "<tr><td>";
					if(stat.getRet())
						text += " *RET*";
					else {
						if(stat.getSeg() == -1) {
							text += " *BOX*";
						} else {
							text += counter+"°";
							if(stat.getInci() && !stat.getDama()) {
								text += " <font color='orange'>*INC*</font>";
							} else {
								if (stat.getOver()) {
									text += " <font color='green'>*END*</font>";
								} else {
									if (stat.getDama()) {
										text += " <font color='red'>*DMG*</font>";
									}
								}
							}
						}
					}
					text += "</td><td><font color='"+colors[carID]+"'>"+names[carID]+"</font></td>"+"<td>"+stat.getLap()+"</td></tr>";
					counter++;
					if(!stat.getRet()) {
						p = map.getPosition(stat.getSeg(), stat.getProg());
						x[carID] = (int)p.getX();
						y[carID] = (int)p.getY();
					} else {
						x[carID] = -10;
						y[carID] = -10;
					}
				}

				text += "</table></html>";
				//race.validate();

				race.repaint();

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