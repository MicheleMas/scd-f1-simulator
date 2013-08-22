public class Detail {

	private int lap;
	private int seg;
	private int prog;
	private boolean inci;
	private boolean ret;
	private boolean over;

	/**
	There is no setter because any useless instance of this class must be deleted, not used again
	(race condition problem)
	*/
	public Detail(int lap, int seg, int prog, boolean inci, boolean ret, boolean over) {
		this.lap = lap;
		this.seg = seg;
		this.prog = prog;
		this.inci = inci;
		this.ret = ret;
		this.over = over;
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

	public boolean getRet() {
		return ret;
	}

	public boolean getOver() {
		return over;
	}
}