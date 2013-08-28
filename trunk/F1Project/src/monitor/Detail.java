public class Detail {

	private int tireStatus;
	private boolean rainTire;
	private int avgSpeed;
	private int behaviour;
	private int speed;
	private boolean r_box;

	public Detail (int tireStatus, boolean rainTire, int avgSpeed, int behaviour, int speed, boolean r_box) {
		this.tireStatus = tireStatus;
		this.rainTire = rainTire;
		this.avgSpeed = avgSpeed;
		this.behaviour = behaviour;
		this.speed = speed;
		this.r_box = r_box;
	}

	public int getTireStatus() {
		return tireStatus;
	}

	public boolean getRainTire() {
		return rainTire;
	}

	public int getAvgSpeed() {
		return avgSpeed;
	}

	public int getBehaviour() {
		return behaviour;
	}

	public int getSpeed() {
		return speed;
	}

	public boolean getRBox() {
		return r_box;
	}
}