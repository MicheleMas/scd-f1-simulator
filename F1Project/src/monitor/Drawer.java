import java.io.*;
import java.awt.Point;
import java.awt.Color;
import java.awt.image.BufferedImage;
import java.awt.Graphics2D;

public class Drawer {

	private String fileName = "circuitMap.txt";
	private Segment[] circuit;
	private int segmentNumber;

	// The first line must contains the number of segments
	public Drawer() throws IOException {
		FileInputStream fstream = new FileInputStream(fileName);
		DataInputStream in = new DataInputStream(fstream);
		BufferedReader br = new BufferedReader(new InputStreamReader(in));
		String strLine;
		boolean firstRun = true;
		int counter = 0;
		while((strLine = br.readLine()) != null) {
			if(firstRun) {
				// read the number of segments and initialize the circuit
				segmentNumber = Integer.parseInt(strLine);
				circuit = new Segment[segmentNumber];
				firstRun = false;
			} else {
				String[] splits = strLine.split(" ");
				if(splits[0].equals("S")) {
					circuit[counter] = new StraightSegment(Integer.parseInt(splits[1]), Integer.parseInt(splits[2]), Integer.parseInt(splits[3]), Integer.parseInt(splits[4]));
				} else if (splits[0].equals("T")) {
					circuit[counter] = new TurnSegment(Integer.parseInt(splits[1]), Integer.parseInt(splits[2]), Integer.parseInt(splits[3]), Integer.parseInt(splits[4]), Integer.parseInt(splits[5]), Integer.parseInt(splits[6]), Integer.parseInt(splits[7]), Integer.parseInt(splits[8]));
				} else if (splits[0].equals("B")) {
					circuit[segmentNumber-1] = new TurnSegment(Integer.parseInt(splits[1]), Integer.parseInt(splits[2]), Integer.parseInt(splits[3]), Integer.parseInt(splits[4]), Integer.parseInt(splits[5]), Integer.parseInt(splits[6]), Integer.parseInt(splits[7]), Integer.parseInt(splits[8]));
				}
				counter++;
			}
		}
		in.close();
	}

	public int getSegmentNumber() {
		return segmentNumber-1;
	}

	public Point getPosition(int segment, int progress) {
		if (segment == -1) {
			// box
			return circuit[segmentNumber-1].getPosition(progress);
		} else if(segment > 0) {
			return circuit[segment-1].getPosition(progress);
		} else {
			return new Point(-10,-10);
		}
	}

	public BufferedImage getTrack(int resX, int resY) {
		BufferedImage track = new BufferedImage(resX, resY, BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = track.createGraphics();
		g2d.setColor(Color.gray);
		Point p;
		for (int i=0; i<segmentNumber; i++) {
			for (int j=0; j<100; j++) {
				p = circuit[i].getPosition(j);
				g2d.fillOval((int)p.getX(), (int)p.getY(), 10, 10);
			}
		}
		return track;
	}
}