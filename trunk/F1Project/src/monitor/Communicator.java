import com.inspirel.yami.Agent;
import com.inspirel.yami.IncomingMessage;
import com.inspirel.yami.OutgoingMessage;
import com.inspirel.yami.IncomingMessageCallback;
import com.inspirel.yami.Parameters;
import java.util.*;

public class Communicator implements Runnable {

	private static String publishAddress;
	private static String pullAddress;
	private static String overrideAddress;
	private static int carNumber;
	private static int lapNumber;
	private static boolean raining = false;
	private static Container data;
	private static boolean stop = false;
	private static Agent pullAgent;
	private static Parameters pullParams;
	private static boolean firstRun = true;
	private static int segNumber;

	//Publisher reader tmp variables
	private static int[] lap;
	private static int[] seg;
	private static int[] prog;
	private static boolean[] inci;
	private static boolean[] dama;
	private static boolean[] ret;
	private static boolean[] over;
	private static int[] rank;
	private static int[] dist;

	public Communicator(String publishAddress, int carNumber, int lapNumber, int segmentNumber) {
		this.publishAddress = publishAddress;
		this.pullAddress = pullAddress;
		this.overrideAddress = overrideAddress;
		this.carNumber = carNumber;
		this.lapNumber = lapNumber;
		this.segNumber = segmentNumber;
		data = new Container(carNumber);
		lap = new int[carNumber];
		seg = new int[carNumber];
		prog = new int[carNumber];
		inci = new boolean[carNumber];
		dama = new boolean[carNumber];
		ret = new boolean[carNumber];
		over = new boolean[carNumber];
		rank = new int[carNumber];
		dist = new int[carNumber];
	}

	// PUBLISH METHODS
	private static class UpdateHandler implements IncomingMessageCallback {
		@Override
		public void call(IncomingMessage im) throws Exception {
			Parameters content = im.getParameters();
			// read data from the message
			try {
				if (!firstRun) {
					// interpolate from old to new
					int[] progress1 = new int[carNumber];
					int[] progress2 = new int[carNumber];
					float[] step = new float[carNumber];
					for (int i=1; i<=carNumber; i++) {
						int segment = content.getInteger("seg "+i);
						if (content.getInteger("lap "+i) > lap[i-1]) {
							segment += segNumber;
						}
						progress1[i-1] = prog[i-1];
						progress2[i-1] = (content.getInteger("prog "+i) + (100 * (segment - seg[i-1])));
						step[i-1] = ((float)(progress2[i-1] - progress1[i-1])) / 10;
					}
					float[] progTemp = new float[carNumber];
					int[] progTempInt = new int[carNumber];
					int[] segTemp = new int[carNumber];
					int[] lapTemp = new int[carNumber];
					for (int j=0; j<carNumber; j++) {
						progTemp[j] = progress1[j];
						segTemp[j] = seg[j];
						lapTemp[j] = lap[j];
					}
					for (int run=0; run<10; run++) {
						for (int car=0; car<carNumber; car++) {
							int segment = content.getInteger("seg "+(car+1));
							if (seg[car] != -1 && lap[car] != 0 && segment != -1 && segment != 0) {
								progTemp[car] += step[car];
								while (progTemp[car] > 100) {
									progTemp[car] -= 100;
									segTemp[car]++;
									if (segTemp[car] > segNumber) {
										segTemp[car] = 1;
										lapTemp[car]++;
									}
								}
							}
							progTempInt[car] = (int)progTemp[car];
						}
						data.setData(lapTemp, segTemp, progTempInt, inci, dama, ret, over, rank, dist);
						Thread.currentThread().sleep(50);
					}
				}
				raining = content.getBoolean("rain");
				for (int i=1; i<=carNumber; i++) {
					lap[i-1] = content.getInteger("lap "+i);
					seg[i-1] = content.getInteger("seg "+i);
					prog[i-1] = content.getInteger("prog "+i);
					inci[i-1] = content.getBoolean("inci "+i);
					dama[i-1] = content.getBoolean("dama "+i);
					ret[i-1] = content.getBoolean("ret "+i);
					over[i-1] = content.getBoolean("over "+i);
					rank[i-1] = content.getInteger("rank "+i);
					dist[i-1] = content.getInteger("dist "+i);
			}
			data.setData(lap, seg, prog, inci, dama, ret, over, rank, dist);
			firstRun = false;
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	public void stop() {
		stop = true;
	}

	public void run() {
		try {
			Agent subscriberAgent = new Agent();
			final String updateObjectName = "update_handler";
			subscriberAgent.registerObject(updateObjectName, new UpdateHandler());

			Parameters params = new Parameters();
			params.setString("destination_object", updateObjectName);

			subscriberAgent.sendOneWay(publishAddress, "snapshots", "subscribe", params);

			System.out.println("Connected to publisher");

			while(!stop) {
				Thread thisThread = Thread.currentThread();
				thisThread.sleep(2000);
			}
		} catch(Exception e) {
			stop = true;
			System.out.println("subscriber thread stopped: " + e.getMessage());
		}
		System.out.println("subscriber thread stopped");
	}

	public Status raceUpdate(int carID) {
		return data.getData(carID);
	}
	
	public int getCarNumber() {
		return carNumber;
	}

	public int getLapNumber() {
		return lapNumber;
	}

	public boolean isRaining() {
		return raining;
	}
}