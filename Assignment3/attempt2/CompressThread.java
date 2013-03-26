import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.util.zip.CRC32;
import java.util.zip.Deflater;
import java.io.FileDescriptor;
import java.io.FileOutputStream;

public class CompressThread extends Thread
{
    public static FileChannel infoWriter;
    public static FileOutputStream dataWriter = new FileOutputStream(FileDescriptor.out);
    public static int HEADER_LENGTH = 10;
    public static int FOOTER_LENGTH = 8;
    static byte[] input;
    static byte[] prev;
    static byte[] output;
    static boolean hasPrev;
    
    CompressThread(byte[] b, boolean isP)
    {
    	infoWriter= new FileOutputStream(FileDescriptor.out).getChannel();
    	dataWriter = new FileOutputStream(FileDescriptor.out);
    	HEADER_LENGTH = 10;
    	FOOTER_LENGTH = 8;
    	input = b.clone();
    	hasPrev = isP;
    }
    
	public static void myHeaderWriter() 
	{
        try
        {
        	ByteBuffer header = ByteBuffer.allocate(HEADER_LENGTH);
        	header.order(ByteOrder.LITTLE_ENDIAN);
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
	
	public void run()
	{
		CRC32 myCRC = new CRC32();
		myCRC.reset();
						
		byte[] output = new byte[100];
		myCRC.update(input);
			
		Deflater compressor = new Deflater(Deflater.DEFAULT_COMPRESSION, true);
            
		compressor.setInput(input);
		
		if(hasPrev)       
			compressor.setDictionary(prev);
			
		compressor.deflate(output);

		compressor.end();		
	}
}