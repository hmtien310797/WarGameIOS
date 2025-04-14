using System;
using System.IO;
using UnityEngine;

namespace J3Tech
{
    public class Utility
    {
        public static void Log2File(object message)
        {
            var st = new System.Diagnostics.StackTrace(1, true);
            int line = st.GetFrame(0).GetFileLineNumber();
            string fileName = Path.GetFileName(st.GetFrame(0).GetFileName());
            File.AppendAllText(Application.dataPath + @"/CodeEncipher/Log.txt",
                    "\r\n" + fileName + "(" + line + ")------" + DateTime.Now + "-----" + Application.unityVersion + "\r\n" + message);
        }

        public static string GetJdkPath()
        {
            string path = Environment.GetEnvironmentVariable("Path");
            if (path != null)
            {
                string[] paths = path.Split(';');
                foreach (var s in paths)
                {
                    if (s.Contains("Java\\jdk") || s.Contains("Java/jdk"))
                    {
                        return s;
                    }
                }
            }
            path = Environment.GetEnvironmentVariable("JAVA_HOME");
            return path;
        }

        public static void CheckDir(string root, string dir)
        {
            string[] dirs = dir.Split('/', '\\');
            string path = root;
            foreach (var s in dirs)
            {
                path += "/" + s;
                if (!Directory.Exists(path))
                {
                    Directory.CreateDirectory(path);
                }
            }
        }
    }
}
