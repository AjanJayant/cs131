import java.io.*;
import java.lang.*;
import java.util.*;
import java.nio.*;
import java.util.zip.Deflater;
import java.util.zip.CRC32;
import java.nio.channels.FileChannel;

class Jpigz
{
	private String input;
	private int blockSize; 
	private int primer;
	int processors;
	boolean isInd;
	boolean isValid;
	public static FileChannel infoWriter = new FileOutputStream(FileDescriptor.out).getChannel();
    public static FileOutputStream dataWriter = new FileOutputStream(FileDescriptor.out);
    public static final int HEADER_LENGTH = 10;
    public static final int FOOTER_LENGTH = 8;
    public static final int DICTIONARY_SIZE=8;	

	Jpigz(int bS, int p)
	{
		input = "";
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
	
	public static void myHeaderWriter() {
        try
        {
        	ByteBuffer header = ByteBuffer.allocate(HEADER_LENGTH);
        	header.order(ByteOrder.LITTLE_ENDIAN);
        	header.putInt(0x00088B1F).putInt((int)(System.currentTimeMillis()/1000L)).putShort((short)0xFF00);
        	header.flip();
        	infoWriter.write(header);
        }
        catch (IOException e)
        {
        	System.err.println("error");
        };
	}	
	
	public static void myFooterWriter(int value, int length)
	{
        try
        {
            ByteBuffer footer = ByteBuffer.allocate(FOOTER_LENGTH);
        	footer.order(ByteOrder.LITTLE_ENDIAN);
        	footer.putInt(value).putInt((int)(length % Math.pow(2, 32)));
        	footer.flip();
        	infoWriter.write(footer);
        }
        catch (IOException e)
        {
        	System.err.println("error");
        };
	}
	
	public byte[] compress(String inputString) throws UnsupportedEncodingException
	{
	 	byte[] input = inputString.getBytes("UTF-8");

 		// Compress the bytes
 		byte[] output = new byte[100];
 		Deflater compresser = new Deflater();
 		compresser.setInput(input);
 		compresser.finish();
 		int compressedDataLength = compresser.deflate(output);
 		return output;
	}
		
	public static void main(String[] args) throws IOException
	{
		Jpigz j = new Jpigz(128000, 32000);
		j.parseArgs(args);
		//myHeaderWriter();
		System.out.write(j.compress("This is a test"));
		CRC32 myCRC = new CRC32();
		myCRC.reset();
		myFooterWriter((int)myCRC.getValue(), 14);
		
	}
}