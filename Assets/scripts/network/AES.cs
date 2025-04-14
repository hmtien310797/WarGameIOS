using UnityEngine;
using System.Collections;
using System.Security.Cryptography;

using ProtoMsg;

public class AES
{
	static byte[] ConverToByteArray(MsgEncryptKey item)
	{
		byte[] result = new byte[item.data.Count];

		for (int i = 0; i < item.data.Count; i ++) 
		{
			result[i] = (byte)item.data[i];
		}

		return result;
	}

	/// 有密码的AES加密 
	/// </summary>
	/// <param name="text">加密字符</param>
	/// <param name="password">加密的密码</param>
	/// <param name="iv">密钥</param>
	/// <returns></returns>
	public static byte[] AESEncrypt(byte[] plainText, MsgEncryptKey pwd, MsgEncryptKey iv)
	{
		RijndaelManaged rijndaelCipher = new RijndaelManaged();
		
		rijndaelCipher.Mode = CipherMode.CFB;
		
		rijndaelCipher.Padding = PaddingMode.Zeros;
		
		rijndaelCipher.KeySize = 128;
		
		rijndaelCipher.BlockSize = 128;
		
		byte[] keyBytes = new byte[16];

		byte[] pwdBytes = ConverToByteArray (pwd);
		int len = pwdBytes.Length;
		
		if (len > keyBytes.Length) len = keyBytes.Length;
		
		System.Array.Copy(pwdBytes, keyBytes, len);
		
		rijndaelCipher.Key = keyBytes;
		rijndaelCipher.IV = ConverToByteArray(iv);

		ICryptoTransform transform = rijndaelCipher.CreateEncryptor();
		byte[] cipherBytes = transform.TransformFinalBlock(plainText, 0, plainText.Length);
		
		return cipherBytes;
	}

	/// <summary>
	/// AES解密
	/// </summary>
	/// <param name="text"></param>
	/// <param name="password"></param>
	/// <param name="iv"></param>
	/// <returns></returns>
	public static byte[] AESDecrypt(byte[] encryptedData, MsgEncryptKey pwd, MsgEncryptKey iv)
	{
		RijndaelManaged rijndaelCipher = new RijndaelManaged();
		
		rijndaelCipher.Mode = CipherMode.CFB;
		
		rijndaelCipher.Padding = PaddingMode.Zeros;
		
		rijndaelCipher.KeySize = 128;
		
		rijndaelCipher.BlockSize = 128;
		
		byte[] keyBytes = new byte[16];

		byte[] pwdBytes = ConverToByteArray (pwd);
		int len = pwdBytes.Length;
		
		if (len > keyBytes.Length) len = keyBytes.Length;
		
		System.Array.Copy(pwdBytes, keyBytes, len);
		
		rijndaelCipher.Key = keyBytes;
		rijndaelCipher.IV = ConverToByteArray(iv);
		
		ICryptoTransform transform = rijndaelCipher.CreateDecryptor();
		byte[] plainText = transform.TransformFinalBlock(encryptedData, 0, encryptedData.Length);
		
		return plainText;
	}
}