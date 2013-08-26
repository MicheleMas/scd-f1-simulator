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
	private static boolean[] ret;
	private static boolean[] over;
	private static int[] rank;

	public Communicator(String publishAddress, String pullAddress, String overrideAddress, int carNumber) {
		this.publishAddress = publishAddress;
		this.pullAddress = pullAddress;
		this.overrideAddress = overrideAddress;
		this.carNumber = carNumber;
		data = new Container(carNumber);
		lap = new int[carNumber];
		seg = new int[carNumber];
		prog = new int[carNumber];
		inci = new boolean[carNumber];
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
				ret[i-1] = content.getBoolean("ret "+i);
				over[i-1] = content.getBoolean("over "+i);
				rank[i-1] = content.getInteger("rank "+i);
				//rank[i-1] = i;
			}
			data.setData(lap, seg, prog, inci, ret, over, rank);
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


	// PULL METHOD

	public Detail getDetails(int carID) {
		Detail details = null;
		try {
			if (pullAgent == null || pullParams == null) {
				pullAgent = new Agent();
				pullParams = new Parameters();
			}
			pullParams.setString("type", "D");
			pullParams.setString("car", (carID+1)+"");
			OutgoingMessage message = pullAgent.send(pullAddress, "warehouse", "details", pullParams);
			message.waitForCompletion();
			OutgoingMessage.MessageState state = message.getState();
			if (state == OutgoingMessage.MessageState.REPLIED) {
				Parameters reply = message.getReply();
				int tireStatus = reply.getInteger("tire");
				boolean rainTire = reply.getBoolean("rain");
				int avgSpeed = reply.getInteger("avgspeed");
				int behaviour = reply.getInteger("beh");
				int speed = reply.getInteger("speed");
				details = new Detail(tireStatus, rainTire, avgSpeed,behaviour, speed);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return details;
	}

	// OVERRIDE METHOD

	public void overrideBehaviour(int carID, int behaviour) {
		try {
			Agent overrideAgent = new Agent();
			Parameters params = new Parameters();
			params.setString("type", "Obeh");
			params.setString("beh", ""+behaviour);
			overrideAgent.sendOneWay(overrideAddress, "override", "behaviour", params);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void overrideBoxEntrance(int carID) {
		try {
			Agent overrideAgent = new Agent();
			Parameters params = new Parameters();
			params.setString("type", "Obox");
			overrideAgent.sendOneWay(overrideAddress, "override", "box", params);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public int getCarNumber() {
		return carNumber;
	}
}