using UnityEngine;
using System.IO;
using System;
using System.Security.Cryptography;
using System.Text;

public class AssetsUtility
{
    public static readonly string LOCALSTREAMEDPATH =
#if UNITY_ANDROID   //安卓
    "jar:file://" + Application.persistentDataPath + "!/assets//";
#elif UNITY_IOS  //iPhone  
    Application.persistentDataPath + "/Raw/";  
#elif UNITY_STANDALONE_WIN || UNITY_EDITOR  //windows平台和web平台  
    "file://" + Application.dataPath + "/StreamingAssets/";  
#else  
        string.Empty;  
#endif

    public static string KeySave;

    public const string SERVERPATH = "http://38.54.15.131/AssetBundle/AssetBundles_AccType_self_adr/" +
#if UNITY_ANDROID
     "assetbundles_android/";
#elif UNITY_IOS
     "assetbundles_ios/"; 
#else
     "assetbundles/";
#endif
    public const string ASSETVERSIONS = "versions.txt";
    public const string ASSETBUNDLE = "assetbundles";
    public const string SERVERVERSIONS = "serverversions.txt";
    public const string ASSETPATHTABLE = "assetpathtable.txt";

    public delegate bool CallbackSaveLoad(Stream stream, string fileName);
    private static readonly int READ_BUFFER_SIZE = 1024 * 10;

    public static string GetSaveBasePath()
    {
        string path = Application.dataPath;
#if UNITY_EDITOR||UNITY_STANDALONE
        path = path.Substring(0, path.LastIndexOf('/'));
        path += "/Save/";

#elif UNITY_IOS
		path = Application.persistentDataPath + "/";
				
#elif UNITY_ANDROID
		path = Application.persistentDataPath + "/";
#else
#error Not implemented.
#endif
        return path;
    }

    public static string GetDocumentPath()
    {
        string path = GetSaveBasePath();
        path += "Documents/";
        return path;
    }

    public static string GetCachePath()
    {
        string path = GetSaveBasePath();
        path += "Caches/";
        path += ASSETBUNDLE + "/";
        return path;
    }

    public static string GetTemporaryPath()
    {
        string path = GetSaveBasePath();
        path += "Tmp/";
        return path;
    }

    public static string GetOutputPath(string platform = "")
    {
        string path = Application.dataPath;
        path = path.Substring(0, path.LastIndexOf('/'));
        path = path.Substring(0, path.LastIndexOf('/') + 1);
        if (platform != "")
        {
            path += "AssetBundles_" + platform + "/";
        }
        path +=
#if UNITY_ANDROID
     "assetbundles_android";
#elif UNITY_IOS
     "assetbundles_ios"; 
#else
     ASSETBUNDLE;
#endif
        return path + "/" + GameVersion.EXE + "/" + GameVersion.BUILD;
    }

    public static string GetBundleRecordPath(string platform = "")
    {
        string path = Application.dataPath;
        path = path.Substring(0, path.LastIndexOf('/') + 1);
        path += platform;
        path +=
#if UNITY_ANDROID
     "assetbundles_android";
#elif UNITY_IOS
     "assetbundles_ios"; 
#else
     ASSETBUNDLE;
#endif
        return path;
    }

    public enum EPlatform
    {
        ePC = 0,
        eIOS,
        eAndroid,
        eTotal,
    }

    public enum SuffixType
    {
        eBytes = 0,
        ePrefab,
        eMaterial,
        eMp3,
        eImage,
        eAll
    }

    public static string GetSuffix(SuffixType _type)
    {
        if (_type == SuffixType.eBytes)
        {
            return ".bytes|.txt|.xml";
        }
        else if (_type == SuffixType.eImage)
        {
            return ".png|.jpg|.tga|.exr";
        }
        else if (_type == SuffixType.eMaterial)
        {
            return ".mat";
        }
        else if (_type == SuffixType.eMp3)
        {
            return ".mp3";
        }
        else if (_type == SuffixType.ePrefab)
        {
            return ".prefab";
        }
        else if (_type == SuffixType.eAll)
        {
            return ".bytes|.txt|.xml|.png|.jpg|.tga|.exr|.mat|.mp3|.prefab";
        }
        else
        {
            return ".prefab";
        }
    }

    public static string[] GetSuffixArray(SuffixType _type)
    {
        if (_type == SuffixType.eBytes)
        {
            return new string[] { "bytes","bytes" };
        }
        else if (_type == SuffixType.eImage)
        {
            return new string[] { "png", "png", "jpg", "jpg", "tga", "tga", "exr" , "exr" };
        }
        else if (_type == SuffixType.eMaterial)
        {
            return new string[] { "mat" , "mat" };
        }
        else if (_type == SuffixType.eMp3)
        {
            return new string[] { "mp3", "mp3" };
        }
        else if (_type == SuffixType.ePrefab)
        {
            return new string[] { "prefab", "prefab" };
        }
        else
        {
            return new string[] { };
        }
    }

    public static System.Type GetSystemType(SuffixType _type)
    {
        if (_type == SuffixType.eBytes)
        {
            return typeof(TextAsset);
        }
        else if (_type == SuffixType.eImage)
        {
            return typeof(Texture);
        }
        else if (_type == SuffixType.eMaterial)
        {
            return typeof(Material);
        }
        else if (_type == SuffixType.eMp3)
        {
            return typeof(AudioClip);
        }
        else if (_type == SuffixType.ePrefab)
        {
            return typeof(GameObject);
        }
        else
        {
            return typeof(GameObject);
        }
    }

    public static bool EasySave(string filename, bool encrypt, CallbackSaveLoad callback)
    {
        string path = filename.Substring(0, filename.LastIndexOf("/") + 1);
        filename = filename.Substring(filename.LastIndexOf("/") + 1);
        //Debug.Log("filename=" + filename + "     EasySave=" + path);
        return EasySave(path, filename, encrypt, callback);
    }

    public static bool EasySave(string filename, CallbackSaveLoad callback)
    {
        string path = GetDocumentPath();
        //Debug.Log("filename=" + filename + "     EasySave=" + path);
        return EasySave(path, filename, false, callback);
    }

    public static bool EasySave(string path, string filename, bool encrypt, CallbackSaveLoad callback)
    {
        bool success = false;

        try
        {
            if (!Directory.Exists(path))
            {
                //Debug.Log("Utility#EasySave create directory path=" + path);
                Directory.CreateDirectory(path);
            }
            path += filename;

            MemoryStream memStream = new MemoryStream();
            success = callback(memStream, filename);
            memStream.Close();
            if (success)
            {
                if (File.Exists(path))
                {
                    File.Delete(path);
                }
                byte[] bin = memStream.ToArray();
                if (encrypt)
                {
                    bin = EncryptData(bin);
                }
                using (Stream stream = File.Open(path, FileMode.Create))
                {
                    stream.Write(bin, 0, bin.Length);
                    stream.Close();
                }
            }

            if (success)
            {
                //Debug.Log("Utility#EasySave success path=" + path);
            }
            else
            {
                //Debug.LogWarning("Utility#EasySave fail path=" + path);
            }

        }
        catch (Exception e)
        {
            success = false;
            //Debug.LogWarning("Utility#EasySave fail filename=[" + filename + "] e=" + e);

        }

        return success;
    }

    public static bool EasyLoad(string filename, bool decode, CallbackSaveLoad callback)
    {
        string path = filename.Substring(0, filename.LastIndexOf("/") + 1);
        filename = filename.Substring(filename.LastIndexOf("/") + 1);
        //Debug.Log("filename=" + filename + "     EasyLoad=" + path);
        return EasyLoad(path, filename, decode, callback);
    }

    public static bool EasyLoad(string filename, CallbackSaveLoad callback)
    {
        string path = GetDocumentPath();
        //Debug.Log("filename=" + filename + "     EasyLoad=" + path);
        return EasyLoad(path, filename, false, callback);
    }

    public static bool EasyLoad(string path, string filename, bool decode, CallbackSaveLoad callback)
    {
        bool success = false;

        try
        {
            path += filename;
            if (!File.Exists(path))
            {
                //Debug.LogWarning("Utility#EasyLoad not found path=" + path);
                return false;
            }

            using (Stream stream = File.Open(path, FileMode.Open))
            {
                MemoryStream outStream = new MemoryStream();
                byte[] buf = new byte[READ_BUFFER_SIZE];
                int readLen;
                while ((readLen = stream.Read(buf, 0, buf.Length)) > 0)
                {
                    outStream.Write(buf, 0, readLen);
                }
                outStream.Close();
                byte[] bin = outStream.ToArray();
                stream.Close();
                if (decode)
                {
                    bin = DecodeData(bin);
                }
                MemoryStream memStream = new MemoryStream(bin);
                success = callback(memStream, filename);
                memStream.Close();
            }

            if (success)
            {
                //Debug.Log("Utility#EasyLoad success path=" + path);
            }
            else
            {
                //Debug.LogWarning("Utility#EasyLoad fail path=" + path);
            }

        }
        catch (Exception e)
        {
            success = false;
            //Debug.LogWarning("Utility#EasyLoad fail filename=[" + filename + "] e=" + e);
            File.Delete(path);
        }

        return success;
    }

    public static bool EasyDeleteFile(string filename)
    {
        string path = GetDocumentPath();
        //Debug.Log("filename=" + filename + "    EasyDeleteFile=" + path);
        return EasyDeleteFile(path, filename);
    }

    public static bool EasyDeleteFile(string path, string filename)
    {
        bool success = false;

        try
        {
            path += filename;
            File.Delete(path);
            success = true;

        }
        catch (Exception e)
        {
            success = false;
            //Debug.LogWarning("Utility#EasyDeleteFile fail filename=[" + filename + "] e=" + e);

        }

        return success;
    }

    public static string LoadTextFile(string path)
    {
        string ret = null;

        try
        {
            if (!File.Exists(path))
            {
                //Debug.LogWarning("LoadTextFile not found path=" + path);
                return null;
            }

            using (StreamReader stream = new StreamReader(path))
            {
                ret = stream.ReadToEnd();
                stream.Close();
            }

        }
        catch (Exception e)
        {
            ret = null;
            //Debug.LogWarning("LoadTextFile fail path=" + path + " e=" + e);

        }

        return ret;
    }

    private static readonly int ENCRYPT_HEAD_MAGIC = 0x41544144;
    private static readonly int ENCRYPT_HEAD_VERSION = 0x00000001;
    private static readonly int ENCRYPT_RIJNDAEL_SALT_LENGTH = 8;

    private static byte[] EncryptData(byte[] bin)
    {
        byte[] dat;
#if ENCRYPT_CHECK_TYPE_HASH
        byte[] hash = CalcSha256(bin);
        dat = hash;
#else
        int sum = CalcSum(bin);
        dat = BitConverter.GetBytes(sum);
#endif
        var tmpbin = new byte[dat.Length + bin.Length];
        dat.CopyTo(tmpbin, 0);
        bin.CopyTo(tmpbin, dat.Length);
        bin = tmpbin;

#if ENCRYPT_ENCODE_TYPE_RIJNDAEL
        byte[] salt;
        bin = EncryptDataRijndael(bin, out salt);
#else
        int rnd;
        bin = EncryptDataSimple(bin, out rnd);
#endif
        var outStream = new MemoryStream();
        dat = BitConverter.GetBytes(ENCRYPT_HEAD_MAGIC);
        outStream.Write(dat, 0, dat.Length);
        dat = BitConverter.GetBytes(ENCRYPT_HEAD_VERSION);
        outStream.Write(dat, 0, dat.Length);
        dat = BitConverter.GetBytes(bin.Length);
        outStream.Write(dat, 0, dat.Length);

#if ENCRYPT_ENCODE_TYPE_RIJNDAEL
        outStream.Write(salt, 0, salt.Length);
#else
        dat = BitConverter.GetBytes(rnd);
        outStream.Write(dat, 0, dat.Length);
#endif
        outStream.Write(bin, 0, bin.Length);
        outStream.Close();
        bin = outStream.ToArray();

        return bin;
    }

    private static byte[] DecodeData(byte[] bin)
    {
        int dat;

        int index = 0;

        dat = BitConverter.ToInt32(bin, index);
        index += sizeof(int);
        if (dat != ENCRYPT_HEAD_MAGIC)
        {
            //Debug.LogWarning("DecodeData wrong magic 0x" + Convert.ToString(dat, 16) + " != 0x" + Convert.ToString(ENCRYPT_HEAD_MAGIC, 16));
            throw new Exception("DecodeData fail");
        }
        dat = BitConverter.ToInt32(bin, index);
        index += sizeof(int);
        if (dat != ENCRYPT_HEAD_VERSION)
        {
            //Debug.LogWarning("DecodeData wrong version 0x" + Convert.ToString(dat, 16) + " != 0x" + Convert.ToString(ENCRYPT_HEAD_VERSION, 16));
            throw new Exception("DecodeData fail");
        }
        dat = BitConverter.ToInt32(bin, index);
        index += sizeof(int);
        int size = dat;

#if ENCRYPT_ENCODE_TYPE_RIJNDAEL
        var salt = new byte[ENCRYPT_RIJNDAEL_SALT_LENGTH];
        Array.Copy(bin, index, salt, 0, salt.Length);
        index += salt.Length;
#else
        dat = BitConverter.ToInt32(bin, index);
        index += sizeof(int);
        int rnd = dat;
#endif
        int bodysize = bin.Length - index;
        if (bodysize != size)
        {
            //Debug.LogWarning("DecodeData wrong size data=" + size + " file=" + bodysize);
            throw new Exception("DecodeData fail");
        }

        var tmpbin = new byte[bodysize];
        Array.Copy(bin, index, tmpbin, 0, tmpbin.Length);
        bin = tmpbin;

#if ENCRYPT_ENCODE_TYPE_RIJNDAEL
        bin = DecodeDataRijndael(bin, salt);
#else
        bin = DecodeDataSimple(bin, rnd);
#endif
        index = 0;

#if ENCRYPT_CHECK_TYPE_HASH
        var hash = new byte[256 / 8];
        Array.Copy(bin, index, hash, 0, hash.Length);
        index += hash.Length;
#else
        dat = BitConverter.ToInt32(bin, index);
        index += sizeof(int);
        int sum = dat;
#endif

        tmpbin = new byte[bin.Length - index];
        Array.Copy(bin, index, tmpbin, 0, tmpbin.Length);
        bin = tmpbin;

#if ENCRYPT_CHECK_TYPE_HASH
        byte[] check = CalcSha256(bin);
        if (!ArrayEquals(hash, check))
        {
            DebugTool.LogWarning("DecodeData wrong hash data=[" + BytesToHexString(hash) + "] file=[" + BytesToHexString(check) + "]");
            throw new Exception("DecodeData fail");
        }
#else
        int check = CalcSum(bin);
        if (sum != check)
        {
            //Debug.LogWarning("DecodeData wrong sum data=0x" + Convert.ToString(sum, 16) + " file=0x" + Convert.ToString(check, 16));
            throw new Exception("DecodeData fail");
        }
#endif

        return bin;
    }

    public static int CalcSum(byte[] bin)
    {
        int sum = 0;
        foreach (byte n in bin)
        {
            sum += n;
        }
        return sum;
    }

    public static byte[] CalcSha256(byte[] bin)
    {
        var crypto = new SHA256Managed();
        byte[] hashValue = crypto.ComputeHash(bin);
        return hashValue;
    }

    private static byte[] EncryptDataSimple(byte[] bin, out int rnd)
    {
        rnd = UnityEngine.Random.Range(int.MinValue, int.MaxValue);

        int r = rnd;
        byte[] newbin = (byte[])bin.Clone();
        for (int i = 0; i < newbin.Length; i++)
        {
            r = NextEncryptRandom(r);
            newbin[i] ^= (byte)r;
        }

        return newbin;
    }

    private static byte[] DecodeDataSimple(byte[] bin, int rnd)
    {
        byte[] newbin = (byte[])bin.Clone();
        for (int i = 0; i < newbin.Length; i++)
        {
            rnd = NextEncryptRandom(rnd);
            newbin[i] ^= (byte)rnd;
        }

        return newbin;
    }

    private static byte[] EncryptDataRijndael(byte[] bin, out byte[] salt)
    {
        var rijndael = new RijndaelManaged();

        salt = new byte[ENCRYPT_RIJNDAEL_SALT_LENGTH];
        for (int i = 0; i < salt.Length; i++)
        {
            salt[i] = (byte)UnityEngine.Random.Range(byte.MinValue, byte.MaxValue);
        };

        byte[] key, iv;
        GenerateKeyFromPassphrase(GetEncryptPassphrase(), salt, rijndael.KeySize, out key, rijndael.BlockSize, out iv);
        rijndael.Key = key;
        rijndael.IV = iv;

        MemoryStream outStream = new MemoryStream();
        ICryptoTransform encryptor = rijndael.CreateEncryptor();
        CryptoStream crypyStream = new CryptoStream(outStream, encryptor, CryptoStreamMode.Write);
        crypyStream.Write(bin, 0, bin.Length);
        crypyStream.Close();
        encryptor.Dispose();
        outStream.Close();

        byte[] newbin = outStream.ToArray();
        return newbin;
    }

    private static byte[] DecodeDataRijndael(byte[] bin, byte[] salt)
    {
        var rijndael = new RijndaelManaged();

        byte[] key, iv;
        GenerateKeyFromPassphrase(GetEncryptPassphrase(), salt, rijndael.KeySize, out key, rijndael.BlockSize, out iv);
        rijndael.Key = key;
        rijndael.IV = iv;

        MemoryStream inStream = new MemoryStream(bin);
        ICryptoTransform decryptor = rijndael.CreateDecryptor();
        CryptoStream crypyStream = new CryptoStream(inStream, decryptor, CryptoStreamMode.Read);
        MemoryStream outStream = new MemoryStream();
        byte[] buf = new byte[READ_BUFFER_SIZE];
        int readLen;
        while ((readLen = crypyStream.Read(buf, 0, buf.Length)) > 0)
        {
            outStream.Write(buf, 0, readLen);
        }
        outStream.Close();
        crypyStream.Close();
        decryptor.Dispose();
        inStream.Close();

        byte[] newbin = outStream.ToArray();
        return newbin;

    }

    private static void GenerateKeyFromPassphrase(string phrase, byte[] salt, int keySize, out byte[] key, int blockSize, out byte[] iv)
    {
        if (salt.Length < 8)
        {
            throw new Exception("wrong salt length=" + salt.Length);
        }

        var deriveBytes = new Rfc2898DeriveBytes(phrase, salt);
        key = deriveBytes.GetBytes(keySize / 8);
        iv = deriveBytes.GetBytes(blockSize / 8);
    }

    private static string GetEncryptPassphrase()
    {
        string phrase = KeySave;
        return phrase;
    }

    private static int NextEncryptRandom(int rnd)
    {
        return (rnd * 5 + 1);
    }

    public static void ApplicationForceQuitWithError(string message, object error = null)
    {
        //Debug.LogError("ERROR: " + message + " error=[" + error + "]");
        System.Console.Out.Flush();
        System.Console.Error.Flush();
#if UNITY_EDITOR || UNITY_WEBPLAYER
        //Debug.LogError("========== Application.Quit ==========");
#else
        Application.Quit();
#endif
    }

    public static string EraseUtfBom(string text)
    {
        const char BOM = (char)0xFEFF;
        if (text == null)
        {
            return null;
        }
        if (text.Length < 1)
        {
            return text;
        }
        char c = text[0];
        if (c != BOM)
        {
            return text;
        }
        return text.Substring(1);
    }

    public static string GetStreamedString(Stream stream)
    {
        byte[] b = new byte[stream.Length];
        stream.Read(b, 0, b.Length);
        return System.Text.Encoding.UTF8.GetString(b);
    }

    public static string GetMd5Hash(byte[] _data)
    {
        // Create a new instance of the MD5CryptoServiceProvider object.
        MD5 md5Hasher = MD5.Create();

        byte[] data = md5Hasher.ComputeHash(_data);

        // Create a new Stringbuilder to collect the bytes
        // and create a string.
        StringBuilder sBuilder = new StringBuilder();

        // Loop through each byte of the hashed data 
        // and format each one as a hexadecimal string.
        for (int i = 0; i < data.Length; i++)
        {
            sBuilder.Append(data[i].ToString("x2"));
        }

        // Return the hexadecimal string.
        return sBuilder.ToString();
    }

    public static string GetMd5Hash(string input)
    {
        // Create a new instance of the MD5CryptoServiceProvider object.
        MD5 md5Hasher = MD5.Create();

        // Convert the input string to a byte array and compute the hash.
        byte[] data = md5Hasher.ComputeHash(Encoding.UTF8.GetBytes(input));

        // Create a new Stringbuilder to collect the bytes
        // and create a string.
        StringBuilder sBuilder = new StringBuilder();

        // Loop through each byte of the hashed data 
        // and format each one as a hexadecimal string.
        for (int i = 0; i < data.Length; i++)
        {
            sBuilder.Append(data[i].ToString("x2"));
        }

        // Return the hexadecimal string.
        return sBuilder.ToString();
    }
}
