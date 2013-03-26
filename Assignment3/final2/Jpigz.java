import java.io.*;
import java.util.*;

class Jpigz
{
	// Instance variables
	private byte[] block;
	private int blockSize; 
	private int processors;
	private boolean isInd;

	// Constructor
	Jpigz(int bS, int p)
	{
		block = new byte[120000];
		blockSize = bS;
		//primer = p;
		processors = 0;
		isInd = false;
		//isValid = true;
	}

	// Method to parse arguments passed to main
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
		
		//If the number of processors is not mentioned, then it understood that the number
		//of processors is the number of available processors
		if(processors == 0)
		{
			Runtime runtime = Runtime.getRuntime();
			processors = runtime.availableProcessors();
		}		
	}

	private void writeError(String msg)
	{
		System.err.println("abort: " + msg);
		System.exit(0);
	}
	
	public void processInput()
	{
		ArrayList<CompressThread> allThreads = new ArrayList<CompressThread>();
		
		byte [] prev = new byte[32*2^10];
		try 
		{
			int size;
			while((size = System.in.read(block, 0, blockSize)) != -1)
			{	

				if(allThreads.size() == 0)
				{
					CompressThread thread = new CompressThread(block, size);
					allThreads.add(thread);
					thread.start();
				}
				else
				{
					System.arraycopy(block, 96*2^10, prev, 0, 32*2^10);

					if (isInd == true)
					{
						CompressThread thread = new CompressThread(block, size);
						allThreads.add(thread);
						thread.start();
					}
					else
					{
						CompressThread thread = new CompressThread(block, size);
						allThreads.add(thread);
						thread.setDict(prev);
						thread.start();
					}
				}
			}

			while(allThreads.size() > 0)
			{
				CompressThread first = allThreads.get(0);
					
				while(first.getStatus() != 1)
				{ 
					Thread.currentThread().yield(); 
				}

				if(System.out.checkError() == false)
				{
					first.run();	
					System.out.write(first.getOutput());
				}
				else
				{
					writeError("write error on <stdout>");
				}
				
				allThreads.remove(0);
			}			

		} 
		catch (IOException e) 
		{ 
			e.printStackTrace();
		}	
	}
		
	public static void main(String[] args) throws IOException
	{
		Jpigz j = new Jpigz(128*10^24, 32*10^24);
		j.parseArgs(args);
		j.processInput();
	}
}