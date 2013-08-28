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
	private static Container data;
	private static boolean stop = false;
	private static Agent pullAgent;
	private static Parameters pullParams;

	//Publisher reader tmp variables
	private static int[] lap;
	private static int[] seg;
	private static int[] prog;
	private static boolean[] inci;
	private static boolean[] dama;
	private static boolean[] ret;
	private static boolean[] over;
	private static int[] rank;

	public Communicator(String publishAddress, int carNumber) {
		this.publishAddress = publishAddress;
		this.pullAddress = pullAddress;
		this.overrideAddress = overrideAddress;
		this.carNumber = carNumber;
		data = new Container(carNumber);
		lap = new int[carNumber];
		seg = new int[carNumber];
		prog = new int[carNumber];
		inci = new boolean[carNumber];
		dama = new boolean[carNumber];
		ret = new boolean[carNumber];
		over = new boolean[carNumber];
		rank = new int[carNumber];
	}

	// PUBLISH METHODS
	private static class UpdateHandler implements IncomingMessageCallback {
		@Override
		public void call(IncomingMessage im) throws Exception {
			Parameters content = im.getParameters();
			// read data from the message
			try {
			for (int i=1; i<=carNumber; i++) {
				System.out.println("Aggiorno car" + i);
				lap[i-1] = content.getInteger("lap "+i);
				seg[i-1] = content.getInteger("seg "+i);
				prog[i-1] = content.getInteger("prog "+i);
				inci[i-1] = content.getBoolean("inci "+i);
				dama[i-1] = content.getBoolean("dama "+i);
				ret[i-1] = content.getBoolean("ret "+i);
				over[i-1] = content.getBoolean("over "+i);
				rank[i-1] = content.getInteger("rank "+i);
				//rank[i-1] = i;
			}
			data.setData(lap, seg, prog, inci, dama, ret, over, rank);
			System.out.println("Aggiornamento completato"); // TODO remove
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

	/**
	Return the last status received by the broker (in mutex)
	*/
	public Status raceUpdate(int carID) {
		return data.getData(carID);
	}
	

	public int getCarNumber() {
		return carNumber;
	}
}