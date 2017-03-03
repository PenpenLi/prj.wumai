using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using NUnit.Framework;
using System.IO;
using LuaFramework;
using System.Collections.Generic;
using System.Collections;
using System;
using System.Diagnostics;
using Debug = UnityEngine.Debug;


public class GameMenu {

	[MenuItem("Tools/清理存档", false, 1)]
	public static void ClearSave()
	{
		string path = Application.persistentDataPath + "/.rd/";
		if(Tools.ExistsDirectory(path))
			Tools.DeleteDirectory(path);

		Debug.Log("clear data successful.");
	}


	[MenuItem("Tools/更新补丁", false, 2)]
	static void BuildPathInfo(){
		if( EditorUtility.DisplayDialog( "警告", "确认导出补丁？\n(打补丁前请确认所有修改已经被提交)", "确定", "取消" ) ){
			try {
				Process process = new Process(); 
				process.StartInfo.FileName = Application.dataPath + "/../tools/make_patch.bat"; 
				//			process.StartInfo.UseShellExecute = false;
				process.StartInfo.CreateNoWindow = false;
				//			process.StartInfo.Arguments = AppConst.RawScriptPath.Replace("/", "\\");
				process.Start();
				process.WaitForExit();
			} finally {
				//Util.Log( "------> BuildPatchInfo complete." );
			}
		}
	}


	[MenuItem("Tools/Analyze UI Image Deps", false, 202)]
	static void analyzeUiImageDeps()
	{
        Dictionary<string, List<string>> deps = GetAllImageDependencies();

        Dictionary<string, bool> reDeps = new Dictionary<string, bool>();
        // 标记被引用资源
        foreach (var node in deps)
        {
            //string parent = node.Key;
            List<string> list = node.Value;
            foreach (var dep in list)
            {
                reDeps[dep] = true;
            }
        }

        List<string> allImage = new List<string>();
        GetAllUiImage(ref allImage);

        foreach (var image in allImage)
        {
            if (!reDeps.ContainsKey(image))
            {
                Debug.Log("unused:" + image);
            }
        }
	}


	static Dictionary<string,List<string>> GetAllImageDependencies()
	{
		EditorUtility.DisplayProgressBar("Analyze", "waitting", 0f);

		string[] arrPrefabPath = Directory.GetFiles(AppConst.EditorBuildResourcePath, "*", SearchOption.AllDirectories);

        Dictionary<string, List<string>> resourcesTable = new Dictionary<string,List<string>>();
		for (int i = 0, len = arrPrefabPath.Length; i < len; i++) {
			string strTempPath = arrPrefabPath[i].Replace(@"\", "/");
			//截取我们需要的路径
			strTempPath = strTempPath.Substring(strTempPath.LastIndexOf("Assets"));

			//过滤掉不需要的文件
			if (!strTempPath.EndsWith(".prefab"))
				continue;

            if (!resourcesTable.ContainsKey(strTempPath))
				resourcesTable[strTempPath] = new List<string>();

			List<string> list = resourcesTable[strTempPath];

			string[] deps = AssetDatabase.GetDependencies(new string[] { strTempPath });
			for(int j = 0, jlen = deps.Length; j < jlen; j++){

				if (!IsImage(deps[j]))
					continue;

				list.Add(deps[j]);
			}

			EditorUtility.DisplayProgressBar("Analyze", strTempPath, i * 1f / len);
		}

//		string json = JSON.JsonEncode(resourcesTable);
//		Debug.Log("all dep\n" + json);
//		File.WriteAllText("D:/dep.json", json);

		EditorUtility.ClearProgressBar();

		return resourcesTable;
	}


	public static bool IsImage(string file)
	{
		string ext = Path.GetExtension(file).ToLower();
		if (ext == ".png") return true;
        if (ext == ".jpg") return true;
//		if (ext == ".prefab") return true;
//		if (ext == ".exr") return true;
//		if (ext == ".mat") return true;
//		if (ext == ".ttf") return true;
//		if (ext == ".fbx") return true;
//		if (ext == ".map3") return true;
//		if (ext == ".wav") return true;
//		if (ext == ".anim") return true;
//		if (ext == ".shader") return true;
//		if (ext == ".fontsettings") return true;
		return false;
	}


    public static void GetAllUiImage(ref List<string> list, string uiPath = null)
    {
        if (uiPath == null)
        {
            GetAllUiImage(ref list, AppConst.EditorBuildResourcePath);
            GetAllUiImage(ref list, AppConst.AppRoot + "/" + AppConst.AppResName + "/UI/");
            return;
        }

        string[] arrPrefabPath = Directory.GetFiles(uiPath, "*", SearchOption.AllDirectories);

		for (int i = 0, len = arrPrefabPath.Length; i < len; i++) {
			string strTempPath = arrPrefabPath[i].Replace(@"\", "/");
			strTempPath = strTempPath.Substring(strTempPath.LastIndexOf("Assets"));

            if(!IsImage(strTempPath))
				continue;

            list.Add(strTempPath);
		}
    }


	static void ChangeAllComponentInPrefab<T>(Action<T> action)
	{
		string path = Packager.GetSelectionPath();

		if (!string.IsNullOrEmpty(path))
		{
			string[] files = Directory.GetFiles(path, "*.prefab", SearchOption.AllDirectories);

			if(files.Length == 0)
			{
				Debug.LogWarning("can't find prefab in " + path);
				return;
			}

			int startIndex = 0;
			//替换路径中的反斜杠为正斜杠
			//string strTempPath = path.Replace(@"\", "/");

			EditorApplication.update = delegate()
			{
				bool isCancel = false;
				try
				{
					string file = files[startIndex];
					isCancel = EditorUtility.DisplayCancelableProgressBar("处理中..", file, (float)startIndex / (float)files.Length);
					GameObject obj = AssetDatabase.LoadMainAssetAtPath(file) as GameObject;

					if (obj != null)
					{
						T[] tList = obj.GetComponentsInChildren<T>(true);
						foreach (var t in tList)
						{
							action.Invoke(t);
						}
					}

					EditorUtility.SetDirty(obj);
					AssetDatabase.SaveAssets();
				} catch(Exception e){
					Debug.LogError(e.Message);
				}

				startIndex++;
				if (isCancel || startIndex >= files.Length)
				{
					EditorUtility.ClearProgressBar();
					EditorApplication.update = null;
					startIndex = 0;
					//Debug.Log("匹配结束");
				}
			};
		}
	}


//    [MenuItem("Assets/Change Partical Scaling", false, 1004)]
    static void ChangePartical()
    {
		ChangeAllComponentInPrefab<ParticleSystem>(p => {
			var main = p.main;
			main.scalingMode = ParticleSystemScalingMode.Hierarchy;
		});
    }


//    [MenuItem("Assets/Change Font", false, 1005)]
    static void ChangeFont()
    {
		Font font = AssetDatabase.LoadMainAssetAtPath("Assets/Game11/Res/Builds/Font/fzcyj.ttf") as Font;
		ChangeAllComponentInPrefab<UnityEngine.UI.Text>(text => {
			if(text.font.name == "Arial"){
				text.font = font;
			}
		});
    }


//	[MenuItem("Assets/Log Select Path", false, 1005)]
	static void LogSelectPath(){
		Debug.Log("path:" + Packager.GetSelectionPath());
	}

}
