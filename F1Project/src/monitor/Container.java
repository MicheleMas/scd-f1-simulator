public class Container {

	private static boolean initialized = false;
    private static int carNumber;
    private static Detail[] data;

	public Container(int carNumber) {
		if(!initialized) {
			initialized = true;
			this.carNumber = carNumber;
			data = new Detail[carNumber];
		}
	}

	public static synchronized void setData(int[] lap, int[] seg, int[] prog, boolean[] inci, boolean[] ret, boolean[] over) {
		for (int i=0; i<carNumber; i++) {
			data[i] = new Detail(lap[i], seg[i], prog[i], inci[i], ret[i], over[i]);
		}
	}

	public static synchronized Detail getData(int carID) {
		return data[carID];
	}

}