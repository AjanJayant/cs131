import java.io.*;
import java.lang.*;
import java.util.*;
import java.nio.*;
import java.util.zip.Deflater;
import java.util.zip.CRC32;
import java.nio.channels.FileChannel;

class Jpigz
{
	private byte[] block;
	private int blockSize; 
	private int primer;
	int processors;
	boolean isInd;
	boolean isValid;

	Jpigz(int bS, int p)
	{
		blockSize = bS;
		primer = p;
		processors = 0;
		isInd = false;
		isValid = true;
	}

	private void parseArgs(String [] args) throws NumberFormatException
	{
		boolean iSeen = false;
		boolean pSeen = false;
		int len = args.length;		

		for(int i= 0; i < len; i++)
		{
			String str = args[i];
			if(str.equals("-i"))
			{
				if(iSeen)
					writeError("invalid option");
				else
				{
					this.isInd = true;
						iSeen = true;
				}
			}
			else if(str.equals("-p"))
			{
				if(pSeen || i + 1 == len)
                                	writeError("invalid option");
                                else
                                {       
                                        this.processors = Integer.parseInt(args[++i]);
					if(this.processors > 1000000000)
						writeError("too many processors");
					else if(this.processors < 1)
						writeError("invalid number of processors");
                                        pSeen = true;
                                }
			}
			else
				writeError("invalid option");
		}		
	}

	private void writeError(String msg)
	{
		System.err.println("abort: " + msg);
		System.exit(1);
	}
		
	public static void main(String[] args) throws IOException
	{
		Jpigz j = new Jpigz(128000, 32000);
		j.parseArgs(args);
		//myHeaderWriter();
		BufferedReader br = new BufferedReader(new InputStreamReader((System.in)));
		//System.out.println(br.readLine());
        byte[] buf = new byte[6];
        System.in.read(buf, 0, 6);
        //for(byte b : buf)
        //	System.out.print(b);
		CompressThread c = new CompressThread(buf, false);
		c.run();
		System.out.print(c.output);
	}
}