//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
using System;
using System.Text;
using System.IO;
using System.Collections;
using UnityEngine;
using LuaInterface;
using LuaFramework;
using Object = UnityEngine.Object;

public class Tools
{


	public Tools()
	{
	}


	public static ArrayList FindAllFile(string path, Func<string, bool> includer = null, bool deep = true)
	{
		ArrayList list = new ArrayList();
		FindAllFile(ref list, path, includer, deep);
		return list;
	}


	public static void FindAllFile(ref ArrayList list, string path, Func<string, bool> includer = null, bool deep = true)
	{
		if (!Directory.Exists(path)) return;
		string[] dirs = Directory.GetDirectories(path);

		if (deep)
		{
			foreach (string dir in dirs)
			{
				FindAllFile(ref list, dir, includer, deep);
			}
		}

		string[] files = Directory.GetFiles(path);
		foreach (string file in files)
		{
			if (includer == null || includer(file))
			{
				list.Add(file.Replace('\\', '/'));
			}
		}
	}


	//  文件及文件夹操作
	public static bool ExistsFile(string file)
	{
		return File.Exists(file);
	}


	public static void DeleteFile(string file)
	{
		File.Delete(file);
	}


	public static void CopyFile(string resFile, string destFile, bool overwrite)
	{
		File.Copy(resFile, destFile, overwrite);
	}


	public static string GetFileName(string path)
	{
		return Path.GetFileName(path);
	}


	public static string GetDirectoryName(string file)
	{
		return Path.GetDirectoryName(file);
	}


	public static bool ExistsDirectory(string path)
	{
		return Directory.Exists(path);
	}


	public static void DeleteDirectory(string path)
	{
		Directory.Delete(path, true);
	}


	public static void CreateDirectory(string path)
	{
		Directory.CreateDirectory(path);
	}


	public static void CopyDirectory(string srcPath, string destPath, bool clearOld)
	{
		try
		{
			if (destPath[destPath.Length - 1] != Path.DirectorySeparatorChar)
				destPath += Path.DirectorySeparatorChar;

			string[] files = Directory.GetFileSystemEntries(srcPath);
			foreach (string file in files)
			{
				if (Directory.Exists(file))
				{
					CopyDirectory(file, destPath + Path.GetFileName(file), clearOld);
				}
				else
				{
					if (!Directory.Exists(destPath))
						Directory.CreateDirectory(destPath);

					string destFile = (destPath + Path.GetFileName(file)).Replace("\\", "/");
					File.Copy(file, destFile, true);

					if (clearOld)
					{
						File.Delete(file);
					}
				}
			}
		}
		catch (Exception e)
		{
			Util.LogError(e.Message);
		}
	}


	public static string ReadAllText(string fileName)
	{
		if (File.Exists(fileName))
			return File.ReadAllText(fileName);
		else
			return "";
	}

	public static void WriteAllText(string file, string text)
	{
		File.WriteAllText(file, text);
	}


	public static void WriteAllBytes(string path, byte[] bytes)
	{
		string pathName = Path.GetDirectoryName(path);
		if (!Directory.Exists(pathName))
			Directory.CreateDirectory(pathName);

		File.WriteAllBytes(path, bytes);
	}


	public static Byte[] ReadByteFromFileImm(string releaseFileName, string publishFileName, string relativeFileName)
    {


        //先尝试在下载目录读取，如果读取不到就在发布目录读取（android和ios对应的是包内资源）

        if(File.Exists(releaseFileName)){
            //加载方式不分平台，直接在对应目录中加载
            return File.ReadAllBytes(releaseFileName);

        }else{
            //这里不同平台需要用不同加载方式
#if UNITY_EDITOR
            //editor
            return File.ReadAllBytes(publishFileName);
#elif UNITY_ANDROID
            //android
            return Util.ReadZipBytes(Application.dataPath, relativeFileName);
#elif UNITY_IPHONE
            return File.ReadAllBytes(publishFileName);
#else
            
            return File.ReadAllBytes(publishFileName);
#endif
        }


        
    }

    public static string ReadAllTextBySearch(string releaseFileName, string publishFileName, string relativeFileName)
    {

        byte[] data = ReadByteFromFileImm(releaseFileName, publishFileName, relativeFileName);
        if (data == null || data.Length == 0){
            return "";
        }
        return System.Text.Encoding.Default.GetString(data,0,data.Length );
    }



    public static void Compress(string scrPath, string destZipFile)
    {
        ZIP2.compress(scrPath, destZipFile);
    }
    
       
    public static bool Decompress(string zipFile, string pathRoot)
    {
        return ZIP2.decompress(zipFile, pathRoot);
    }




	/// 平台判断
	public static bool isApplePlatform
	{
		get
		{
			return Application.platform == RuntimePlatform.IPhonePlayer;
		}
	}


	public static bool isAndroidPlatform
	{
		get
		{
			return Application.platform == RuntimePlatform.Android;
		}
	}


	public static bool isEditorPlatform
	{
		get
		{
			return Application.platform == RuntimePlatform.WindowsEditor ||
				Application.platform == RuntimePlatform.OSXEditor;
		}
	}


	public static void SendMessageCommand(string cmd, string msg)
	{
		AppFacade.Instance.SendMessageCommand(cmd, msg);
	}


    //public static long getNowTicks()
    //{
    //    return DateTime.Now.Ticks;
    //}


	/// <summary>
	/// Base64编码
	/// </summary>
	public static string Encode(string message) {
		byte[] bytes = Encoding.GetEncoding("utf-8").GetBytes(message);
		return Convert.ToBase64String(bytes);
	}

	/// <summary>
	/// Base64解码
	/// </summary>
	public static string Decode(string message) {
		byte[] bytes = Convert.FromBase64String(message);
		return Encoding.GetEncoding("utf-8").GetString(bytes);
	}


    public static string getUID()
    {
        return SystemInfo.deviceUniqueIdentifier;
    }


    public static void Log(string msg)
    {
        Debug.Log(msg);
    }


    public static void LogWarn(string msg)
    {
        Debug.LogWarning(msg);
    }


    public static void LogError(string msg)
    {
        Debug.LogError(msg);
    }


    public static int Random(int min, int max)
    {
        return UnityEngine.Random.Range(min, max);
    }



    public static int[] RandomArray(int len)
    {
        int[] order = new int[len];
        int rnd;
        for (int i = 1; i <= len; i++)
        {
            do
            {
                rnd = Random(0, len);
            } while (order[rnd] != 0);
            order[rnd] = i;
        }

        return order;
    }


    // 毫秒
    public static long getCurTime()
    {
        return DateTime.Now.Ticks / 10000;
    }
}


