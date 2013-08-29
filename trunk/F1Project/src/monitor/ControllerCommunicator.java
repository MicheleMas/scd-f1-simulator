import com.inspirel.yami.Agent;
import com.inspirel.yami.IncomingMessage;
import com.inspirel.yami.OutgoingMessage;
import com.inspirel.yami.IncomingMessageCallback;
import com.inspirel.yami.Parameters;
import java.util.*;

public class ControllerCommunicator {

	private static String pullAddress;
	private static String overrideAddress;
	private static Agent pullAgent;
	private static Parameters pullParams;
	//private static int carNumber;

	public ControllerCommunicator(String pullAddress, String overrideAddress) {
		this.overrideAddress = overrideAddress;
		this.pullAddress = pullAddress;
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
				boolean r_box = reply.getBoolean("r_box");
				details = new Detail(tireStatus, rainTire, avgSpeed,behaviour, speed, r_box);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return details;
	}

	// OVERRIDE METHODS

	// carID è inteso da 0 a car_number-1
	public void overrideBehaviour(int carID, int behaviour) {
		try {
			Agent overrideAgent = new Agent();
			Parameters params = new Parameters();
			params.setString("type", "Obeh");
			params.setString("car", ""+(carID+1));
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
			params.setString("car", ""+(carID+1));
			overrideAgent.sendOneWay(overrideAddress, "override", "box", params);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}