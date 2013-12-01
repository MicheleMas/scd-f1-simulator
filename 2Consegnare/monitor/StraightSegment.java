import java.awt.Point;

public class StraightSegment implements Segment {

	private float x1;
	private float y1;
	private float x2;
	private float y2;

	public StraightSegment(int x1, int y1, int x2, int y2) {
		this.x1 = x1;
		this.y1 = y1;
		this.x2 = x2;
		this.y2 = y2;
	}

	public Point getPosition(int progress) {
		float prog = progress;
		int x = Math.round(x1 + ((x2-x1)*((prog)/100)));
		int y = Math.round(y1 + ((y2-y1)*((prog)/100)));
		return new Point(x,y);
	}
}