import java.io.*;

public class Drivers {

	private final String fileName = "carsProp.txt";
	private static String[] names;
	private static String[] colors;

	public Drivers(int carNumber) throws IOException {
		names = new String[carNumber];
		colors = new String[carNumber];
		FileInputStream fstream = new FileInputStream(fileName);
		DataInputStream in = new DataInputStream(fstream);
		BufferedReader br = new BufferedReader(new InputStreamReader(in));
		String strLine;
		int counter = 0;
		while(((strLine = br.readLine()) != null) && counter<carNumber) {
			String[] splits = strLine.split(" ");
			names[counter] = splits[0];
			colors[counter] = splits[1];
			counter++;
		}
		if(counter < carNumber) {
			while(counter<carNumber) {
				names[counter] = ""+(counter+1);
				colors[counter] = "000000";
				counter++;
			}
		}
	}

	public String[] getNames() {
		return names;
	}

	public String[] getColors() {
		return colors;
	}

}