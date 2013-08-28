public class Container {

	private static boolean initialized = false;
    private static int carNumber;
    private static Status[] data;

	public Container(int carNumber) {
		if(!initialized) {
			initialized = true;
			this.carNumber = carNumber;
			data = new Status[carNumber];
		}
	}

	public static synchronized void setData(int[] lap, int[] seg, int[] prog, boolean[] inci, boolean[] dama, boolean[] ret, boolean[] over, int[] rank) {
		for (int i=0; i<carNumber; i++) {
			data[i] = new Status(lap[i], seg[i], prog[i], inci[i], dama[i], ret[i], over[i], rank[i]);
		}
	}

	public static synchronized Status getData(int carID) {
		return data[carID];
	}

}