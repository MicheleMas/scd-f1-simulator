import java.awt.Point;

public class TurnSegment implements Segment {

	private float x1;
	private float y1;
	private float x2;
	private float y2;
	private float x3;
	private float y3;
	private float x4;
	private float y4;

	/**
	Bézier curve implementation:
	x1,y1 Starting Point
	x2,y2 First Controll Point
	x3,y3 Second Controll Point
	x4,y4 End Point
	*/
	public TurnSegment(int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4) {
		this.x1 = x1;
		this.y1 = y1;
		this.x2 = x2;
		this.y2 = y2;
		this.x3 = x3;
		this.y3 = y3;
		this.x4 = x4;
		this.y4 = y4;
	}

	public Point getPosition(int progress) {
		float prog = progress;
		prog = prog/100;
		float ax, bx, cx;
		float ay, by, cy;
		float tSquared, tCubed;
		int x, y;

		cx = 3 * (x2 - x1);
		bx = 3 * (x3 - x2) - cx;
		ax = x4 - x1 - cx - bx;

		cy = 3 * (y2 - y1);
		by = 3 * (y3 - y2) - cy;
		ay = y4 - y1 - cy - by;

		tSquared = prog * prog;
		tCubed = tSquared * prog;

		x = Math.round((ax * tCubed) + (bx * tSquared) + (cx * prog) + x1);
		y = Math.round((ay * tCubed) + (by * tSquared) + (cy * prog) + y1);

		return new Point(x,y);
	}
}