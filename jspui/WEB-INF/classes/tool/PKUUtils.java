package tool;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESKeySpec;
import javax.crypto.spec.IvParameterSpec;

/*
 * 加密函数。
 * 
 */

public class PKUUtils {
	public static String encrypt(String message, String key)
		    throws Exception
		  {
		    Cipher cipher = Cipher.getInstance("DES/CBC/PKCS5Padding");
		    
		    DESKeySpec desKeySpec = new DESKeySpec(key.getBytes("UTF-8"));
		    
		    SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
		    SecretKey secretKey = keyFactory.generateSecret(desKeySpec);
		    IvParameterSpec iv = new IvParameterSpec(key.getBytes("UTF-8"));
		    cipher.init(1, secretKey, iv);
		    
		    return toHexString(cipher.doFinal(message.getBytes("UTF-8")));
		  }
		
	public static String toHexString(byte[] b)
	{
	  StringBuffer hexString = new StringBuffer();
	  for (int i = 0; i < b.length; i++)
	  {
	    String plainText = Integer.toHexString(0xFF & b[i]);
	    if (plainText.length() < 2) {
	      plainText = "0" + plainText;
	    }
	    hexString.append(plainText);
	  }
	  return hexString.toString();
	}	
}
