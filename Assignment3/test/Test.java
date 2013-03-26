import java.io.*;
import java.lang.*;
import java.util.*;

class Test
{
	Test()
	{
	}
	public static void main(String [] args) throws IOException
	{
		Test t = new Test();
		t.useBuffInput();	
	}

	void useInput() throws IOException
	{
			Scanner sc = new Scanner(System.in);
        		System.out.println("Printing the file passed in:");
        		String str = "";
			while(sc.hasNextLine())
				str += sc.nextLine();
			System.out.println(str);
		
	}

	void useBuffInput() throws IOException
        {
        	BufferedReader br = new BufferedReader(new InputStreamReader((System.in)));
                System.out.println("Printing the file passed in:");
		String str = "";
		char[] cbuf = new char[6];
		
                while(br.read(cbuf, 0, 6) != -1)
		{
			str += new String(cbuf);
		}
		System.out.print(str);
	}
}
