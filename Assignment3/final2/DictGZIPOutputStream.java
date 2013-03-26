import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.GZIPOutputStream;

public class DictGZIPOutputStream extends GZIPOutputStream
{

        public DictGZIPOutputStream(OutputStream out) throws IOException
        {
            super(out);
        }

        public void setDictionary(byte[] b)
        {
            def.setDictionary(b);
            System.out.println("Reaches here");
        }

        public void updateCRC(byte[] input)
        {
            crc.update(input);
        }                       
}