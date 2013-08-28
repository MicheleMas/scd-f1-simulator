public class Status {

	private int lap;
	private int seg;
	private int prog;
	private boolean inci;
	private boolean dama;
	private boolean ret;
	private boolean over;
	private int rank;

	/**
	There is no setter because any useless instance of this class must be deleted, not used again
	(race condition problem)
	*/
	public Status(int lap, int seg, int prog, boolean inci, boolean dama, boolean ret, boolean over, int rank) {
		this.lap = lap;
		this.seg = seg;
		this.prog = prog;
		this.inci = inci;
		this.dama = dama;
		this.ret = ret;
		this.over = over;
		this.rank = rank;
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
}