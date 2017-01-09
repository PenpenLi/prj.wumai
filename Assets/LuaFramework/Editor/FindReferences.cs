using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using LuaFramework;
using LuaInterface;

public class FindReferences
{

	static string fileName = "SpriteConfig/";
	static string dirPath = AppConst.AssetName + "/" + AppConst.AppPath + "/" + AppConst.AppResName + "/"  +  AppConst.EditorBuilds + fileName;
	static string luaPath = AppConst.AppRoot + "/" + "Lua/Game/Config/";
	static string configPath = luaPath + "SpriteConfig.lua";

    [MenuItem("Assets/Find References", false, 1000)]
    static private void Find()
    {
        EditorSettings.serializationMode = SerializationMode.ForceText;
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!string.IsNullOrEmpty(path))
        {
            string guid = AssetDatabase.AssetPathToGUID(path);
            string withoutExtensions = "*.prefab*.unity*.mat*.asset";
            string[] files = Directory.GetFiles(Application.dataPath, "*.*", SearchOption.AllDirectories)
                .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
            int startIndex = 0;

            EditorApplication.update = delegate ()
            {
                string file = files[startIndex];

                bool isCancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", file, (float)startIndex / (float)files.Length);

                if (Regex.IsMatch(File.ReadAllText(file), guid))
                {
                    Debug.Log(file, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(file)));
                }

                startIndex++;
                if (isCancel || startIndex >= files.Length)
                {
                    EditorUtility.ClearProgressBar();
                    EditorApplication.update = null;
                    startIndex = 0;
                    Debug.Log("匹配结束");
                }

            };
        }
    }

	//[MenuItem("Assets/Create Sprite Prefab", false, 1001)]
	static private void CreateSpritePrefab()
	{
		EditorSettings.serializationMode = SerializationMode.ForceText;
		string path = AssetDatabase.GetAssetPath(Selection.activeObject);

		if (path.LastIndexOf (".png") > -1) {

			GameObject gobjFab = new GameObject ();
			UISpriteConfig config =  gobjFab.AddComponent<UISpriteConfig> ();
			string fabName = "";

			path = path.Substring(path.LastIndexOf("Assets"));
			Object[] sprites = AssetDatabase.LoadAllAssetsAtPath (path);

			for (int i = 0, len = sprites.Length; i < len; i++) {
				Debugger.Log (sprites [i].name);
				if (i == 0) {
					fabName = sprites [i].name;
				} else {
					config.AddSprite (sprites [i] as Sprite);
				}
			}

			string filePath = dirPath + fabName + ".prefab";

			if (File.Exists (filePath)) {
				File.Delete (filePath);
			}

			if(!Directory.Exists(dirPath) ){
				Directory.CreateDirectory (dirPath);
			}

			PrefabUtility.CreatePrefab (filePath, gobjFab);
			EditorUtility.SetDirty (gobjFab);
			GameObject.DestroyImmediate(gobjFab);
		}

		// CreateSpritePrefabConfig ();
	}


	static public void CreateSpritePrefabConfig()
	{
		string[] arrPrefabPath = Directory.GetFiles(dirPath, "*", SearchOption.AllDirectories);

		StringBuilder builder = new StringBuilder ();
		builder.Append ("return {");

		for (int i = 0, len = arrPrefabPath.Length; i < len; i++) {
			string strTempPath = arrPrefabPath [i];
			string ext = Path.GetExtension(strTempPath).ToLower();
			if (ext.Equals (".prefab")) {
				strTempPath = strTempPath.Substring ( strTempPath.LastIndexOf (fileName) ).Replace (".", "/");
				builder.Append (string.Format("\"{0}\",", strTempPath));
			}
		}

		builder.Append ("}");

		Write(builder.ToString());

	}

	public static void Write(string text)
	{
		if (File.Exists (configPath)) {
			File.Delete (configPath);
		}

		if(!Directory.Exists(luaPath) ){
			Directory.CreateDirectory (luaPath);
		}

		FileStream fs = new FileStream(configPath,FileMode.Append);
		StreamWriter sw = new StreamWriter(fs,Encoding.UTF8);
		sw.Write(text);
		sw.Close();
		fs.Close();
	}

    static private string GetRelativeAssetsPath(string path)
    {
        return "Assets" + Path.GetFullPath(path).Replace(Path.GetFullPath(Application.dataPath), "").Replace('\\', '/');
    }
}
