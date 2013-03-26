import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.GZIPOutputStream;
import java.io.*;
import java.util.*;
import java.util.zip.*;

class CompressThread extends Thread 
{
		//Instance Variables
		private byte[] b;
		private int size;
		private int status;
		private byte[] output;
	
		private DictGZIPOutputStream gOut;
		private ByteArrayOutputStream bAOut;
		
		//Constructor
		public CompressThread(byte[] inB, int inSize) throws IOException
		{
			b = inB.clone();
			size = inSize;
			status = 0;
		}

		//Setters, getters
		
		synchronized public int getStatus()
		{
		 	return status; 
		}
		
		synchronized public byte[] getOutput()
		{
			return output;
		}	
		
		synchronized void setDict(byte[] b)
		{
			            System.out.println("Reaches here 2");
				if(gOut != null)
					gOut.setDictionary(b);
		}
		
		//run() function
		public void run() 
		{		
			// For some reason, if I try to construct the objects inside the constructor
			// I get errors:java.io.IOException: write beyond end of stream
			// at java.util.zip.DeflaterOutputStream.write(DeflaterOutputStream.java:102)
			// Not entirely sure why
			try 
			{
				bAOut = new ByteArrayOutputStream();
				gOut = new DictGZIPOutputStream (bAOut);
				gOut.write(b, 0 , size);
				gOut.close();
			} 
			catch (IOException e) 
			{ 
				e.printStackTrace(); 
			}
		
			output = bAOut.toByteArray();
			status = 1;
		}
}
	


	
	