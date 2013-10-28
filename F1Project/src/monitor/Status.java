public class Status {

	private int lap;
	private int seg;
	private int prog;
	private boolean inci;
	private boolean dama;
	private boolean ret;
	private boolean over;
	private int rank;
	private int dist;

	public Status(int lap, int seg, int prog, boolean inci, boolean dama, boolean ret, boolean over, int rank, int dist) {
		this.lap = lap;
		this.seg = seg;
		this.prog = prog;
		this.inci = inci;
		this.dama = dama;
		this.ret = ret;
		this.over = over;
		this.rank = rank;
		this.dist = dist;
	}

	public int getLap() {
		return lap;
	}

	public int getSeg() {
		return seg;
	}

	public int getProg() {
		return prog;
	}

	public boolean getInci() {
		return inci;
	}

	public boolean getDama() {
		return dama;
	}

	public boolean getRet() {
		return ret;
	}

	public boolean getOver() {
		return over;
	}

	public int getRank() {
		return rank;
	}

	public int getDist() {
		return dist;
	}
}