using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography.X509Certificates;
using Microsoft.Win32;
using UnityEditor;
using UnityEngine;
using System.Collections;

public class AndroidJavaTools
{
    // Fields
    public const int DefaultJvmMemory = 0x800;
    public const int MinJvmMemory = 0x40;
    private static string _jdkLocation;

    // Methods
    internal static string BrowseForJdk(string jdkPath)
    {
        if (string.IsNullOrEmpty(jdkPath))
        {
            jdkPath = GuessJdkLocation();
        }
        string title = "Select Java Development Kit (JDK) folder";
        jdkPath = EditorUtility.OpenFolderPanel(title, jdkPath, string.Empty);
        if (jdkPath.Length == 0)
        {
            return string.Empty;
        }
        if (!IsValidJdkHome(jdkPath))
        {
            title = "Invalid JDK home selected";
            string message = "The path you specified does not look like a valid JDK installation.\n";
            message = (message + "Android development requires at least JDK 7 (1.7), having JRE only is not enough. " + "Please make sure you are selecting a suitable JDK home directory, ") + "or download and install the latest JDK: " + "\nhttp://www.oracle.com/technetwork/java/javase/downloads/index.html";
            EditorUtility.DisplayDialog(title, message, "OK");
        }
        return jdkPath;
    }

    public static string Exe(string command)
    {
        return (command + ((Application.platform != RuntimePlatform.WindowsEditor) ? string.Empty : ".exe"));
    }

    private static string GuessJdkLocation()
    {
        string environmentVariable = Environment.GetEnvironmentVariable("JAVA_HOME");
        if (IsValidJdkHome(environmentVariable))
        {
            return environmentVariable;
        }
        string programFilesPath = Environment.GetEnvironmentVariable("ProgramFiles");
        string programFilesX86Path = Environment.GetEnvironmentVariable("ProgramFiles(x86)");
        string[] strArray = new string[] { "/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home/", "/System/Library/Frameworks/JavaVM.framework/Versions/Current/Home/", "/Library/Java/JavaVirtualMachines/*/Contents/Home/", "/System/Library/Java/JavaVirtualMachines/*/Contents/Home/", "/System/Library/Frameworks/JavaVM.framework/Versions/*/Home/", programFilesPath + @"\Java*\jdk*\", programFilesX86Path + @"\Java*\jdk*\" };
        foreach (string path in strArray)
        {
            foreach (string javaHome in AndroidFileLocator.Find(path))
            {
                if (IsValidJdkHome(javaHome))
                {
                    return javaHome;
                }
            }
        }
        if (Application.platform == RuntimePlatform.WindowsEditor)
        {
            string[] paths = new string[] { @"HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit\1.7", @"HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit\1.7", @"HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit\1.8", @"HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit\1.8" };
            foreach (string javaHome in paths)
            {
                environmentVariable = Registry.GetValue(javaHome, "JavaHome", string.Empty).ToString();
                if (IsValidJdkHome(environmentVariable))
                {
                    return environmentVariable;
                }
            }
        }
        return string.Empty;
    }

    internal static bool IsValidJdkHome(string javaHome)
    {
        if (string.IsNullOrEmpty(javaHome))
        {
            return false;
        }
        string bin = Path.Combine(javaHome, "bin");
        string java = Path.Combine(bin, Exe("java"));
        string javac = Path.Combine(bin, Exe("javac"));
        return ((File.Exists(java) && File.Exists(javac)));
    }

    private static string LocateJdkHome()
    {
        if (!string.IsNullOrEmpty(_jdkLocation))
        {
            return _jdkLocation;
        }
        _jdkLocation = EditorPrefs.GetString("JdkPath");
        if (IsValidJdkHome(_jdkLocation))
        {
            return _jdkLocation;
        }
        if (string.IsNullOrEmpty(_jdkLocation))
        {
            _jdkLocation = GuessJdkLocation();
            if (IsValidJdkHome(_jdkLocation))
            {
                EditorPrefs.SetString("JdkPath", _jdkLocation);
                return _jdkLocation;
            }
        }
        _jdkLocation = BrowseForJdk(string.Empty);
        if (IsValidJdkHome(_jdkLocation))
        {
            EditorPrefs.SetString("JdkPath", _jdkLocation);
            return _jdkLocation;
        }
        _jdkLocation = string.Empty;
        EditorPrefs.SetString("JdkPath", _jdkLocation);
        string title = "Unable to find suitable JDK installation.";
        string message = "Please make sure you have a suitable JDK installation.";
        message = (message + " Android development requires at least JDK 7 (1.7), having JRE only is not enough. ") + " The latest JDK can be obtained from the Oracle website " + "\nhttp://www.oracle.com/technetwork/java/javase/downloads/index.html";
        EditorUtility.DisplayDialog(title, message, "OK");
        throw new UnityException(title + " " + message);
    }

    // Properties
    public static string JarPath
    {
        get
        {
            string[] components = new string[] { LocateJdkHome(), "bin", Exe("jar") };
            return Paths.Combine(components);
        }
    }

    public static string JavacPath
    {
        get
        {
            string[] components = new string[] { LocateJdkHome(), "bin", Exe("javac") };
            return Paths.Combine(components);
        }
    }

    public static string JavaPath
    {
        get
        {
            string[] components = new string[] { LocateJdkHome(), "bin", Exe("java") };
            return Paths.Combine(components);
        }
    }

    public static string JavaBin
    {
        get
        {
            string[] components = new string[] { LocateJdkHome(), "bin"};
            return Paths.Combine(components);
        }
    }
}

public static class Paths
{
    // Methods
    public static string Combine(params string[] components)
    {
        if (components.Length < 1)
        {
            throw new ArgumentException("At least one component must be provided!");
        }
        string str = components[0];
        for (int i = 1; i < components.Length; i++)
        {
            str = Path.Combine(str, components[i]);
        }
        return str;
    }

    public static string CreateTempDirectory()
    {
        string tempFileName = Path.GetTempFileName();
        File.Delete(tempFileName);
        Directory.CreateDirectory(tempFileName);
        return tempFileName;
    }

    public static string GetFileOrFolderName(string path)
    {
        if (File.Exists(path))
        {
            return Path.GetFileName(path);
        }
        if (!Directory.Exists(path))
        {
            throw new ArgumentException("Target '" + path + "' does not exist.");
        }
        string[] strArray = Split(path);
        return strArray[strArray.Length - 1];
    }

    public static string NormalizePath(this string path)
    {
        if (Path.DirectorySeparatorChar == '\\')
        {
            return path.Replace('/', Path.DirectorySeparatorChar);
        }
        return path.Replace('\\', Path.DirectorySeparatorChar);
    }

    public static string[] Split(string path)
    {
        char[] separator = new char[] { Path.DirectorySeparatorChar };
        List<string> list = new List<string>(path.Split(separator));
        int index = 0;
        while (index < list.Count)
        {
            list[index] = list[index].Trim();
            if (list[index].Equals(string.Empty))
            {
                list.RemoveAt(index);
            }
            else
            {
                index++;
            }
        }
        return list.ToArray();
    }
}

public class AndroidFileLocator
{
    // Methods
    public static string[] Find(string searchPattern)
    {
        List<string> result = new List<string>();
        Find(searchPattern, result, false);
        return result.ToArray();
    }

    public static bool Find(string searchPattern, List<string> result)
    {
        return Find(searchPattern, result, false);
    }

    public static bool Find(string searchPattern, List<string> result, bool findFirst)
    {
        return Find(searchPattern, result, findFirst, 0x100);
    }

    public static bool Find(string searchPattern, List<string> result, bool findFirst, int maxdepth)
    {
        if (maxdepth < 0)
        {
            return false;
        }
        char[] anyOf = new char[] { '/', '\\' };
        char[] chArray2 = new char[] { '*', '?' };
        int startIndex = searchPattern.IndexOfAny(chArray2);
        if (startIndex >= 0)
        {
            int length = searchPattern.IndexOfAny(anyOf, startIndex);
            if (length == -1)
            {
                length = searchPattern.Length;
            }
            string str = searchPattern.Substring(length);
            string path = searchPattern.Substring(0, length);
            string directoryName = Path.GetDirectoryName(path);
            if (string.Empty == directoryName)
            {
                directoryName = Directory.GetCurrentDirectory();
            }
            DirectoryInfo info = new DirectoryInfo(directoryName);
            if (!info.Exists)
            {
                return false;
            }
            string fileName = Path.GetFileName(path);
            foreach (FileSystemInfo info2 in info.GetFileSystemInfos(fileName))
            {
                if (Find(info2.FullName + str, result, findFirst, maxdepth - 1) && findFirst)
                {
                    return true;
                }
            }
        }
        else if (File.Exists(searchPattern) || Directory.Exists(searchPattern))
        {
            result.Add(searchPattern);
        }
        return (result.Count > 0);
    }
}






