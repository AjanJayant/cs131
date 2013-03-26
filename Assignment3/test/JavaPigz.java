import java.io.*;
import java.util.*;
import java.util.zip.*;


class JavaPigz
{
	public static final int BLOCKSIZE = 128000;
	public static final int PRIMER = 32000;
	
	public static void main (String[] args) 
	{
		int processors = 0;
		boolean independent = false;

		if(args.length > 0)
		{
			for(int i = 0; i < args.length; i++)
			{
				if (args[i].equals("-p") && args.length > (i + 1) )
				{
					processors = Integer.parseInt(args[i+1]);
				}
				else if (args[i].equals("-i"))
				{
					independent = true;
				}
			}
		}
		
		if(processors == 0)
		{
			Runtime runtime = Runtime.getRuntime();
			processors = runtime.availableProcessors();
		}

		int size = 0;
		byte[] block = new byte[BLOCKSIZE];
		byte[] prev = new byte[PRIMER];
		
		ArrayList<MyThreads> allThreads = new ArrayList<MyThreads>();
		
		try 
		{
			while((size = System.in.read(block, 0, BLOCKSIZE)) != -1)
			{
				if(allThreads.size() == processors)
				{
					MyThreads first = allThreads.get(0);
					
					while(first.getStatus() != 1)
					{ Thread.currentThread().yield(); }
			
					if(System.out.checkError() == false)
					{
						System.out.write(first.getCompressed());
					}
					else
					{
						System.err.println("JavaPigz abort: write error on <stdout>");
						System.exit(0);
					}
					
					allThreads.remove(0);
				}
				

				if(allThreads.size() == 0)
				{
					MyThreads thread = new MyThreads(block, size, null);
					allThreads.add(thread);
					thread.start();
				}
				else
				{
					System.arraycopy(block, 96000, prev, 0, 32000);
					
					if (independent == true)
					{
						MyThreads thread = new MyThreads(block, size, prev);
						allThreads.add(thread);
						thread.start();
					}
					else
					{
						MyThreads thread = new MyThreads(block, size, null);
						allThreads.add(thread);
						thread.start();
					}
				}
			}
		} 
		catch (IOException e) 
		{ 
			e.printStackTrace();
		}	
	}

	public static class MyThreads extends Thread 
	{
		private byte[] b;
		private int size;
		private byte[] prev;
		private byte[] output;
		private int status;
	
		private GZIPOutputStream gzipoutput;
		private ByteArrayOutputStream baoutput;

		public MyThreads(byte[] inB, int inSize, byte[] inPrev)
		{
			b = inB.clone();
			size = inSize;
			prev = inPrev;
			status = 0;
		}

		synchronized public int getStatus()
		{ return status; }

		public byte[] getCompressed()
		{ return output; }
	
		public void run() 
		{
			baoutput = new ByteArrayOutputStream ();
			
			try 
			{
				gzipoutput = new GZIPOutputStream (baoutput);
			} catch (IOException e) 
			{ e.printStackTrace(); }
		
			try 
			{
				gzipoutput.write(b, 0 , size);
			} catch (IOException e) 
			{ e.printStackTrace(); }
		
			try 
			{
				gzipoutput.close();
			} catch (IOException e) 
			{ e.printStackTrace(); }
		
			output = baoutput.toByteArray();
			status = 1;
		}
	}
}