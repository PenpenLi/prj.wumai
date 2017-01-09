using UnityEditor;
using UnityEngine;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using LuaFramework;

public class Packager {
    public static string platform = string.Empty;
    static List<string> paths = new List<string>();
    static List<string> files = new List<string>();
    static List<AssetBundleBuild> maps = new List<AssetBundleBuild>();



    ///-----------------------------------------------------------
    static string[] exts = { ".txt", ".xml", ".lua", ".assetbundle", ".json" };
    static bool CanCopy(string ext) {   //能不能复制
        foreach (string e in exts) {
            if (ext.Equals(e)) return true;
        }
        return false;
    }



	const string kSimulateAssetBundlesMenu = "LuaFramework/Simulate AssetBundles";

	[MenuItem(kSimulateAssetBundlesMenu, false, 2)]
	public static void ToggleSimulateAssetBundle ()
	{
		AppConst.SimulateAssetBundleInEditor = !AppConst.SimulateAssetBundleInEditor;
	}
	[MenuItem(kSimulateAssetBundlesMenu, true, 2)]
	public static bool ToggleSimulateAssetBundleValidate ()
	{
		Menu.SetChecked(kSimulateAssetBundlesMenu, AppConst.SimulateAssetBundleInEditor);
		return true;
	}


    [MenuItem("LuaFramework/3 Build iPhone Resource", false, 300)]
    public static void BuildiPhoneResource() {
        BuildTarget target;
#if UNITY_5
        target = BuildTarget.iOS;
#else
        target = BuildTarget.iPhone;
#endif
        BuildAssetResource(target);
    }

    [MenuItem("LuaFramework/3 Build Android Resource", false, 301)]
    public static void BuildAndroidResource() {
        BuildAssetResource(BuildTarget.Android);
    }

    [MenuItem("LuaFramework/3 Build Windows Resource", false, 302)]
    public static void BuildWindowsResource() {
        BuildAssetResource(BuildTarget.StandaloneWindows);
    }
    [MenuItem("LuaFramework/3 Build Lua File", false, 303)]
    public static void BuildLuaFile() {
        HandleLuaFile();
    }

    /// <summary>
    /// 生成绑定素材
    /// </summary>
    public static void BuildAssetResource(BuildTarget target) {
        if (Directory.Exists(Util.DataPath)) {
            Directory.Delete(Util.DataPath, true);
        }
        string streamPath = AppConst.PublishAssetsPath;
        if (Directory.Exists(streamPath)) {
            Directory.Delete(streamPath, true);
        }
        Directory.CreateDirectory(streamPath);
        AssetDatabase.Refresh();

        maps.Clear();
        if (AppConst.LuaBundleMode) {
            HandleLuaBundle();
        } else {
            HandleLuaFile();
        }
        string resPath = "Assets/" + AppConst.PublishAssetDir;
        BuildAssetBundleOptions options = BuildAssetBundleOptions.DeterministicAssetBundle | 
                                          //lz4格式压缩，减少解压时间，但是相应的会增加包体大小，如果需要极致小包，可将此开关关闭 MARK
                                          BuildAssetBundleOptions.ChunkBasedCompression; 


        //将设置好了的资源加入map列表
        string[] abNames = AssetDatabase.GetAllAssetBundleNames();

        for (int i = 0, len = abNames.Length; i < len; i++)
        {

            AssetBundleBuild build = new AssetBundleBuild();
            build.assetBundleName = abNames[i];
            build.assetNames = AssetDatabase.GetAssetPathsFromAssetBundle(abNames[i]);
            maps.Add(build);
        }


        //导出加入到maps的资源
        if(maps.Count > 0)
        {
            BuildPipeline.BuildAssetBundles(resPath, maps.ToArray(), options, target);
        }

        BuildFileIndex();

        string streamDir = Application.dataPath + "/" + AppConst.LuaTempDir;
        if (Directory.Exists(streamDir)) Directory.Delete(streamDir, true);
        AssetDatabase.Refresh();
        EditorUtility.DisplayDialog("tip", "Build Resource Done!", "ok");
    }

    static void AddBuildMap(string bundleName, string pattern, string path) {
        string[] files = Directory.GetFiles(path, pattern);
        if (files.Length == 0) return;

        for (int i = 0; i < files.Length; i++) {
            files[i] = files[i].Replace('\\', '/');
        }
        AssetBundleBuild build = new AssetBundleBuild();
        build.assetBundleName = bundleName;
        build.assetNames = files;
        maps.Add(build);
    }

    /// <summary>
    /// 处理Lua代码包
    /// </summary>
    static void HandleLuaBundle() {
        string streamDir = Application.dataPath + "/" + AppConst.LuaTempDir;
        if (!Directory.Exists(streamDir)) Directory.CreateDirectory(streamDir);

        string[] srcDirs = { CustomSettings.luaDir, CustomSettings.toluaLuaDir, CustomSettings.gameLuaDir };
        //先将lua代码拷贝到临时目录
        for (int i = 0; i < srcDirs.Length; i++) {
            
            string sourceDir = srcDirs[i];
            string[] files = Directory.GetFiles(sourceDir, "*.lua", SearchOption.AllDirectories);
            int len = sourceDir.Length;

            //if (sourceDir[len - 1] == '/' || sourceDir[len - 1] == '\\') {
            //    --len;
            //}
            for (int j = 0; j < files.Length; j++) {
                string str = files[j].Remove(0, len).Replace("\\", "_").Replace("/", "_");
                string dest = streamDir + str + AppConst.LuaExtName;
                //string dir = Path.GetDirectoryName(dest);
                //Directory.CreateDirectory(dir);
                if (!AppConst.LuaByteMode)
                {
                    File.Copy(files[j], dest, true);
                }
                else
                {
                    EncodeLuaFile(files[j], dest);
                }
                
            }    

        }
        // string[] dirs = Directory.GetDirectories(streamDir, "*", SearchOption.AllDirectories);
        // for (int i = 0; i < dirs.Length; i++)
        // {
        //     string name = dirs[i].Replace(streamDir, string.Empty);
        //     name = name.Replace('\\', '_').Replace('/', '_');
        //     name = "lua/lua_" + name.ToLower() + AppConst.ExtName;

        //     string path = "Assets" + dirs[i].Replace(Application.dataPath, "");
        //     AddBuildMap(name, "*.bytes", path);
        // }
        AddBuildMap(AppConst.LuaBundleName, "*" + AppConst.LuaExtName, "Assets/" + AppConst.LuaTempDir);
        // AssetBundleBuild build = new AssetBundleBuild();
        // build.assetBundleName = "nimei";
        // build.assetNames = new string[]{"Assets/Lua/3rd_cjson_json2lua.lua.bytes"};
        // build.assetNames = new string[]{"Assets/LuaFramework/Examples/Builds/Prompt/PromptItem.prefab"};
        
        // maps.Add(build);

        ////-------------------------------处理非Lua文件----------------------------------
        //string luaPath = AppConst.PublishAssetsPath + "/lua/";
        //for (int i = 0; i < srcDirs.Length; i++) {
        //    paths.Clear(); files.Clear();
        //    string luaDataPath = srcDirs[i].ToLower();
        //    Recursive(luaDataPath);
        //    foreach (string f in files) {
        //        if (f.EndsWith(".meta") || f.EndsWith(".lua")) continue;
        //        string newfile = f.Replace(luaDataPath, "");
        //        string path = Path.GetDirectoryName(luaPath + newfile);
        //        if (!Directory.Exists(path)) Directory.CreateDirectory(path);

        //        string destfile = path + "/" + Path.GetFileName(f);
        //        File.Copy(f, destfile, true);
        //    }
        //}
        AssetDatabase.Refresh();
    }



    /// <summary>
    /// 处理Lua文件
    /// </summary>
    static void HandleLuaFile() {
        // string resPath = AppDataPath + "/StreamingAssets/";
        string luaPath = AppConst.PublishAssetsPath + "/lua/";

        //----------复制Lua文件----------------
        if (!Directory.Exists(luaPath)) {
            Directory.CreateDirectory(luaPath); 
        }
        string[] luaPaths = { CustomSettings.luaDir, CustomSettings.toluaLuaDir, CustomSettings.gameLuaDir };

        for (int i = 0; i < luaPaths.Length; i++) {
            paths.Clear(); files.Clear();
            string luaDataPath = luaPaths[i].ToLower();
            Recursive(luaDataPath);
            int n = 0;
            foreach (string f in files) {
                if (f.EndsWith(".meta")) continue;
                string newfile = f.Replace(luaDataPath, "");
                string newpath = luaPath + newfile + AppConst.LuaExtName;
                string path = Path.GetDirectoryName(newpath);
                if (!Directory.Exists(path)) Directory.CreateDirectory(path);

                if (File.Exists(newpath)) {
                    File.Delete(newpath);
                }
                if (AppConst.LuaByteMode) {
                    EncodeLuaFile(f, newpath);
                } else {
                    File.Copy(f, newpath, true);
                }
                UpdateProgress(n++, files.Count, newpath);
            } 
        }
        EditorUtility.ClearProgressBar();
        AssetDatabase.Refresh();
    }

    static void BuildFileIndex() {
        string resPath = AppConst.PublishAssetsPath;
        ///----------------------创建文件列表-----------------------
        string newFilePath = resPath + "/files.txt";
        if (File.Exists(newFilePath)) File.Delete(newFilePath);

        paths.Clear(); files.Clear();
        Recursive(resPath);

        FileStream fs = new FileStream(newFilePath, FileMode.CreateNew);
        StreamWriter sw = new StreamWriter(fs);
        for (int i = 0; i < files.Count; i++) {
            string file = files[i];
            string ext = Path.GetExtension(file);
            if (file.EndsWith(".meta") || file.Contains(".DS_Store")) continue;

            string md5 = Util.md5file(file);
            string value = file.Replace(resPath, string.Empty);
            sw.WriteLine(value + "|" + md5);
        }
        sw.Close(); fs.Close();
    }

    /// <summary>
    /// 数据目录
    /// </summary>
    static string AppDataPath {
        get { return Application.dataPath.ToLower(); }
    }

    /// <summary>
    /// 遍历目录及其子目录
    /// </summary>
    static void Recursive(string path) {
        string[] names = Directory.GetFiles(path);
        string[] dirs = Directory.GetDirectories(path);
        foreach (string filename in names) {
            string ext = Path.GetExtension(filename);
            if (ext.Equals(".meta")) continue;
            //2个重要后缀
            if (ext.Equals(AppConst.FinalSingleFileExt)) continue;
            if (ext.Equals(AppConst.FinalSingleFileInfoExt)) continue;
            files.Add(filename.Replace('\\', '/'));
        }
        foreach (string dir in dirs) {
            paths.Add(dir.Replace('\\', '/'));
            Recursive(dir);
        }
    }

    static void UpdateProgress(int progress, int progressMax, string desc) {
        string title = "Processing...[" + progress + " - " + progressMax + "]";
        float value = (float)progress / (float)progressMax;
        EditorUtility.DisplayProgressBar(title, desc, value);
    }

    public static void EncodeLuaFile(string srcFile, string outFile) {
        if (!srcFile.ToLower().EndsWith(".lua")) {
            File.Copy(srcFile, outFile, true);
            return;
        }
        bool isWin = true;
        string luaexe = string.Empty;
        string args = string.Empty;
        string exedir = string.Empty;
        string currDir = Directory.GetCurrentDirectory();
        if (Application.platform == RuntimePlatform.WindowsEditor) {
            isWin = true;
            luaexe = "luajit.exe";
            args = "-b " + srcFile + " " + outFile;
            exedir = AppDataPath.Replace("assets", "") + "LuaEncoder/luajit/";
        } else if (Application.platform == RuntimePlatform.OSXEditor) {
            isWin = false;
            luaexe = "./luac";
            args = "-o " + outFile + " " + srcFile;
            exedir = AppDataPath.Replace("assets", "") + "LuaEncoder/luavm/";
        }
        Directory.SetCurrentDirectory(exedir);
        ProcessStartInfo info = new ProcessStartInfo();
        info.FileName = luaexe;
        info.Arguments = args;
        info.WindowStyle = ProcessWindowStyle.Hidden;
        info.ErrorDialog = true;
        info.UseShellExecute = isWin;
        Util.Log(info.FileName + " " + info.Arguments);

        Process pro = Process.Start(info);
        pro.WaitForExit();
        Directory.SetCurrentDirectory(currDir);
    }

    // [MenuItem("LuaFramework/Build Protobuf-lua-gen File")]
    // public static void BuildProtobufFile() {
    //     if (!AppConst.ExampleMode) {
    //         Debugger.LogError("若使用编码Protobuf-lua-gen功能，需要自己配置外部环境！！");
    //         return;
    //     }
    //     string dir = AppDataPath + "/Lua/3rd/pblua";
    //     paths.Clear(); files.Clear(); Recursive(dir);

    //     string protoc = "d:/protobuf-2.4.1/src/protoc.exe";
    //     string protoc_gen_dir = "\"d:/protoc-gen-lua/plugin/protoc-gen-lua.bat\"";

    //     foreach (string f in files) {
    //         string name = Path.GetFileName(f);
    //         string ext = Path.GetExtension(f);
    //         if (!ext.Equals(".proto")) continue;

    //         ProcessStartInfo info = new ProcessStartInfo();
    //         info.FileName = protoc;
    //         info.Arguments = " --lua_out=./ --plugin=protoc-gen-lua=" + protoc_gen_dir + " " + name;
    //         info.WindowStyle = ProcessWindowStyle.Hidden;
    //         info.UseShellExecute = true;
    //         info.WorkingDirectory = dir;
    //         info.ErrorDialog = true;
    //         Util.Log(info.FileName + " " + info.Arguments);

    //         Process pro = Process.Start(info);
    //         pro.WaitForExit();
    //     }
    //     AssetDatabase.Refresh();
    // }

    [MenuItem("LuaFramework/2 Clear Asset Bundle Name", false, 200)]
    public static void ClearAssetBundleNameAll(){
        //清理所有AssetBundle Name
        string[] abNames = AssetDatabase.GetAllAssetBundleNames ();
        for (int i = 0, len = abNames.Length; i < len; i++) {
            AssetDatabase.RemoveAssetBundleName(abNames[i], true);
        }
    }

	[MenuItem("LuaFramework/2 Build Asset Bundle Name", false, 201)]
	public static void BuildAssetBundleNameAll()
	{

		EditorUtility.DisplayProgressBar("BuildABName", "Clean All", 0.0f);

		ClearAssetBundleNameAll ();

		string splitName = AppConst.ResourceNameSplit;
		string[] arrPrefabPath = Directory.GetFiles(AppConst.EditorBuildResourcePath, "*", SearchOption.AllDirectories);
		for(int i = 0, len = arrPrefabPath.Length; i < len; i++){



			//替换路径中的反斜杠为正斜杠       
			string strTempPath = arrPrefabPath[i].Replace(@"\", "/");
			strTempPath = strTempPath.Substring(strTempPath.LastIndexOf("Assets"));

			//过滤掉不需要的文件
			if (!IsResourceFile(strTempPath))
			{
				continue;
			}
			BuildAssetBundleName(strTempPath, strTempPath.Replace( "/", splitName ).Replace( ".", splitName ).Replace(" ", splitName));

			EditorUtility.DisplayProgressBar("BuildABName", "Check Assets", i * 1f / len);
		}

        BuildSpritePackerAssetBundleName();


        EditorUtility.ClearProgressBar ();
	}

	[MenuItem("LuaFramework/2 Build Dependencies Asset Bundle Name", false, 202)]
	public static void BuildDependenciesAssetBundleNameAll()
    {


		EditorUtility.DisplayProgressBar("BuildABName", "Clean All", 0.0f);
		
		ClearAssetBundleNameAll ();

        string[] arrPrefabPath = Directory.GetFiles(AppConst.EditorBuildResourcePath, "*", SearchOption.AllDirectories);
		Dictionary<string, ResourceNode> resourcesTable = new Dictionary<string, ResourceNode> ();

		for (int i = 0, len = arrPrefabPath.Length; i < len; i++) {
			string strTempPath = arrPrefabPath[i].Replace(@"\", "/");
			//截取我们需要的路径
			strTempPath = strTempPath.Substring(strTempPath.LastIndexOf("Assets"));

			//过滤掉不需要的文件
			if (!IsResourceFile(strTempPath))
			{
				continue;
			}

			if (resourcesTable.ContainsKey (strTempPath)) {
				resourcesTable [strTempPath].repeat = true;
			} else {
				resourcesTable.Add(strTempPath, new ResourceNode (strTempPath, strTempPath, true));
			}

			string[] deps = AssetDatabase.GetDependencies(new string[] { strTempPath });
			for(int j = 0, jlen = deps.Length; j < jlen; j++){

				if (!IsResourceFile(deps[j]))
				{
					continue;
				}
				AddResourceNode (deps [j], strTempPath, resourcesTable);
			}

			EditorUtility.DisplayProgressBar("BuildABName", "Check Assets", i * 1f / len);
		}

		//所以需要单独打包的资源
		List<string> keys = new List<string> (resourcesTable.Keys);
		for (int i = 0, len = keys.Count; i < len; i++) {
			ResourceNode node = resourcesTable[ keys[i] ];
			if (node.repeat) {
				BuildAssetBundleName (node.path, node.path.Replace ("/", AppConst.ResourceNameSplit).Replace (".", AppConst.ResourceNameSplit).Replace(" ", AppConst.ResourceNameSplit));
			}
		}

        BuildSpritePackerAssetBundleName();

        EditorUtility.ClearProgressBar ();
    }
    [MenuItem("LuaFramework/1 Pack Textures By SpritePacker", false, 101)]
    public static void SpritePackTextureView(){
        EditorUtility.DisplayDialog("tip", "Mouse on the resources, right click on the button 'Pack Textures By SpritePacker'!", "ok");
    }

    [MenuItem("LuaFramework/1 Clear SpritePacker Textures Asset Bundle Name", false, 100)]
    /*
        将所有的合图文件夹中的userdata.assetBundleName删除
         */
    public static void ClearSpritePackTexture()
    {


        ArrayList directoriesList = new ArrayList();
        GetDirectoriesDeep(AppConst.AppRoot, "*", ref directoriesList);
        for (int i = 0, len = directoriesList.Count; i < len; i++)
        {
            string strTempPath = ((string)directoriesList[i]).Replace(@"\", "/");
            strTempPath = strTempPath.Substring(strTempPath.LastIndexOf("Assets"));
            AssetImporter importer = AssetImporter.GetAtPath(strTempPath);

            Hashtable jsonHashTable = null;
            if (importer.userData != "")
            {
                //获取userdata中的json
                jsonHashTable = JSON.DecodeMap(importer.userData);
                if (jsonHashTable != null && jsonHashTable.ContainsKey(SpritePackJsonKey))
                {
                    jsonHashTable.Remove(SpritePackJsonKey);
                    importer.userData = JSON.JsonEncode(jsonHashTable);
                    importer.SaveAndReimport();
                }

                //无法识别的不需要处理，前提是userdata是json格式
            }
        }

        EditorUtility.DisplayDialog("tip", "Clear Pack Texture Asset Bundle Name Done!", "ok");
    }

    
    /*
     
         合图代码，我们将SpritePacker中的tag信息设置好，我们这里需要避开直接设置assetBundleName，所以我们采用黑科技，将assetBundleName放入userdata中。
         在build时统一处理设置assetBundleName，userData统一采用JSON格式，方便扩展

        exp: userdata = {"assetBundleName":"share"}
         
         */
    public static readonly string SpritePackJsonKey = "assetBundleName";
    [MenuItem("Assets/Pack Textures By SpritePacker", false, 1003)]
    public static void SpritePackTexture(){

        string path = GetSelectionPath();
        string directoryName = Path.GetFileName(path).ToLower();
        string splitName = AppConst.ResourceNameSplit;



        //
        AssetImporter importer = AssetImporter.GetAtPath(path);
        Hashtable jsonHashTable = null;

        if (importer.userData != "")
        {
            //获取userdata中的json
            jsonHashTable = JSON.DecodeMap(importer.userData);
            if (jsonHashTable != null && jsonHashTable.ContainsKey(SpritePackJsonKey))
            {
                jsonHashTable.Remove(SpritePackJsonKey);
            }
        }
        if (jsonHashTable == null)
        {
            jsonHashTable = new Hashtable();

        }

        jsonHashTable.Add(SpritePackJsonKey, directoryName);

        importer.userData = JSON.JsonEncode(jsonHashTable);
        importer.SaveAndReimport();


        if (!string.IsNullOrEmpty(path))
        {


            string[] files = Directory.GetFiles(path, "*.png", SearchOption.AllDirectories);

            int startIndex = 0;

            //替换路径中的反斜杠为正斜杠       
            //string strTempPath = path.Replace(@"\", "/");




            EditorApplication.update = delegate ()
            {
                string file = files[startIndex];

                bool isCancel = EditorUtility.DisplayCancelableProgressBar("合图中..", file, (float)startIndex / (float)files.Length);

                TextureImporter texImp = AssetImporter.GetAtPath(file) as TextureImporter;
                

                //设置assetbundlename
                //BuildAssetBundleName(file, strTempPath.Replace("/", splitName).Replace(".", splitName));
                //BuildAssetBundleName(file, directoryName);


                //设置tag
                if (texImp.spritePackingTag != directoryName)
                {
                    texImp.textureType = TextureImporterType.Sprite;
                    texImp.mipmapEnabled = false;
                    texImp.spritePackingTag = directoryName;

                    texImp.textureFormat = TextureImporterFormat.AutomaticCompressed;
                    texImp.SetPlatformTextureSettings("iPhone", 1024, TextureImporterFormat.Automatic16bit);
                    texImp.SetPlatformTextureSettings("Android", 1024, TextureImporterFormat.AutomaticCompressed);

                    texImp.SaveAndReimport();
                }

                //if (Regex.IsMatch(File.ReadAllText(file), guid))
                //{
                //    Debug.Log(file, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(file)));
                //}

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


    [MenuItem("Assets/ADB Push File", false, 1100)]
    public static void AdbPushFile()
    {
        //测试
        //Application.OpenURL("test.bat");
        //获取当前选择
        var select = Selection.activeObject;
        var packageName = PlayerSettings.bundleIdentifier;
        var fullPath = AssetDatabase.GetAssetPath(select);
        //var fileName = getFileNameWithoutExt(fullPath);
        var filePath = GetFilePath(fullPath);
        var strTempPath = filePath.Replace("Assets/", "");



        //var pushPath = "/sdcard/Android/data/cn.ultralisk.game13/files/game13/lua/Game/Ui";
        var pushPath = "/sdcard/Android/data/" + packageName + "/files/" + strTempPath;
        var argument = "push " + fullPath + " " + pushPath;
        RunCmd.processCommand("adb", argument);


        //RunCmd.processCommand("adb", "push test.bat /sdcard/Android/data");

    }

    
    /*
        针对spritepacker 打成ab包合图预处理
         */
    public static void BuildSpritePackerAssetBundleName()
    {
        ArrayList directoriesList = new ArrayList();
        GetDirectoriesDeep(AppConst.AppRoot, "*", ref directoriesList);
        for (int i = 0, len = directoriesList.Count; i < len; i++)
        {
            string strTempPath = ((string)directoriesList[i]).Replace(@"\", "/");
            strTempPath = strTempPath.Substring(strTempPath.LastIndexOf("Assets"));
            AssetImporter importer = AssetImporter.GetAtPath(strTempPath);

            Hashtable jsonHashTable = null;
            if (importer.userData != "")
            {
                //获取userdata中的json
                jsonHashTable = JSON.DecodeMap(importer.userData);
                if (jsonHashTable != null && jsonHashTable.ContainsKey(SpritePackJsonKey))
                {
                    string assetBundleName = (string)jsonHashTable[SpritePackJsonKey];
                    //取出abname之后，遍历文件夹下的png，重新设置abname
                    string[] files = Directory.GetFiles(strTempPath, "*.png", SearchOption.AllDirectories);
                    for (int j = 0; j < files.Length; j++)
                    {
                        BuildAssetBundleName(files[j], assetBundleName);
                    }
                }

                //无法识别的不需要处理，前提是userdata是json格式
            }
        }
    }


    //深度遍历所有文件夹
    public static void GetDirectoriesDeep(string path, string pattern, ref ArrayList al)
    {

        if (path != null)
        {

            string[] f1 = Directory.GetDirectories(path, pattern);

            string[] d1;

            foreach (string f11 in f1)
            {

                al.Add(f11);

            }

            try
            {

                d1 = Directory.GetDirectories(path);

                foreach (string d11 in d1)
                {

                    try { GetDirectoriesDeep(d11, pattern, ref al); }

                    catch (System.Exception e) { }

                }

            }
            catch (System.Exception e) { }




        }
    }

    public static string GetSelectionPath()

    {

        string path = null;



        Object[] selections = Selection.GetFiltered(typeof(Object), SelectionMode.Assets);

        if (selections != null && selections.Length > 0)

            path = AssetDatabase.GetAssetPath(selections[0]);



        return path;

    }

    public static void AddResourceNode(string path, string parentName, Dictionary<string, ResourceNode> resourcesTable){
		if (resourcesTable.ContainsKey (path)) {
			ResourceNode node = resourcesTable [path];
			//如果没有重复则检测父命是否不同，，不同则表示该资源被多个资源依赖
			if (!node.repeat) {
				if (node.parent != parentName) {
					node.repeat = true;
				}
			}
		} else {
			resourcesTable.Add(path, new ResourceNode (path, parentName, false));
		}
	}


    public static void BuildAssetBundleName(string path, string asName)
    {
        AssetImporter ai = AssetImporter.GetAtPath(path);
        //ai.assetBundleName = string.Format("{0}{1}", asName, AppConst.ExtName);
        //全部变成小写
        ai.assetBundleName = asName;
    }

    public static string GetFileName(string path){
        string fileName = "";
        int startIndex = path.LastIndexOf ("/");
        int endIndex = path.LastIndexOf (".");

        if (startIndex != -1 && endIndex != -1) {
            fileName = path.Substring (startIndex + 1, endIndex - startIndex - 1);
        }

        return fileName;
    }

    public static string GetFilePath(string path){
        string filePath = "";
        int startIndex = path.LastIndexOf ("/");
        int endIndex = path.LastIndexOf (".");

        if (startIndex != -1 && endIndex != -1) {
            filePath = path.Substring (0, startIndex);
        }

        return filePath;
    }

    public static string getFileNameWithoutExt(string path)
    {
        string fileName = "";
        int startIndex = path.LastIndexOf("/");
        if (startIndex != -1)
        {
            fileName = path.Substring(startIndex + 1);
        }
        return fileName;
    }

    public static string getPathWithSymbol( string path ){
        path = path.Replace( "\\", "/" );
        if( !path.EndsWith( "/" ) ){
            path = path + "/";  
        }
        
        return path;
    }
    public static string getFileWithSymbol( string path ){
        path = path.Replace( "\\", "/" );
        return path;
    }

    public static bool IsResourceFile(string file)
    {
        string ext = Path.GetExtension(file).ToLower();
        if (ext == ".prefab") return true;
        if (ext == ".exr") return true;
        if (ext == ".mat") return true;
		if (ext == ".png") return true;
		if (ext == ".ttf") return true;
		if (ext == ".fbx") return true;
		if (ext == ".mp3") return true;
		if (ext == ".wav") return true;
		if (ext == ".anim") return true;
		if (ext == ".shader") return true;
        if (ext == ".fontsettings") return true;
        //if (ext == ".cs") return true; //unity5.x不用管cd？
        return false;
    }





    //打包所有文件到单个文件中
    [MenuItem("LuaFramework/4 Merge All Resource", false, 400)]
    public static void PackFileList(){

        //获取所有文件
        paths.Clear(); files.Clear();
        Recursive(AppConst.PublishAssetsPath);

        ArrayList fileInfo = new ArrayList ();
        ArrayList copyFile = new ArrayList ();
        ArrayList packFile = new ArrayList();
        //读，再写
        if ( Directory.Exists( AppConst.StreamingAssetsPath) ) {
            Directory.Delete(AppConst.StreamingAssetsPath, true);
        }
        Directory.CreateDirectory( AppConst.StreamingAssetsPath);

        FileStream stream = new FileStream (AppConst.StreamingAssetsPath + AppConst.FinalSingleFile, FileMode.Create);
        //      StreamWriter sw = new StreamWriter(stream);
        //      byte[] bytes = new byte[]{1,2,3,5};
        //      stream.Write (bytes,0,2);
        //      stream.Write (bytes,2,2);
        ByteBuffer buffer = new ByteBuffer();
        

        //先分类 
        foreach (string f in files) {
			//lua如果是bunde模式,后缀为.unity3d 如果非bundle模式,我们临时加的.byte后缀方便区分,在后面的解压过程中我们会去掉
            if(AppConst.assetExtract){
                //所有资源全部打包
                packFile.Add(f);
            }else{
                if (f.EndsWith(AppConst.ExtName) || f.EndsWith(AppConst.LuaExtName) || f.EndsWith(AppConst.PatchFileName))
                {
                    //只有符合条件的打包
                    packFile.Add(f);
                }else{
                    copyFile.Add(f);
                }
            }
        }

        //文件数量
        buffer.WriteInt(packFile.Count);
        foreach (string f in packFile)
        {

            string filePath = f.Replace("\\", "/");
            byte[] bytes = File.ReadAllBytes(filePath);

            string recodeLine = filePath.Replace(AppConst.PublishAssetsPath, string.Empty).Replace(AppConst.LuaExtName, string.Empty);
            //文件名
            buffer.WriteString(recodeLine);
            //文件内容
            buffer.WriteBytes(bytes);
        }
        
        //      sw.Close ();

        byte[] flushByte = buffer.ToBytes();
        stream.Write(flushByte, 0, flushByte.Length);
        stream.Flush();
        stream.Close();
        stream.Dispose ();

        buffer.Close();
        buffer = null;



        //最后存fileinfo
        //string fileInfoSavePath = AppConst.StreamingAssetsPath + AppConst.FinalSingleFileInfo;
        //FileStream fs = new FileStream (fileInfoSavePath, FileMode.Create);
        //StreamWriter fsw = new StreamWriter(fs);

        //for (int i = 0; i < fileInfo.Count; i ++) {
        //    fsw.WriteLine((string)fileInfo[i]);
        //}

        //fsw.Close ();

        //fs.Close();

        //最后存fileinfo的md5
        string infoMD5 = Util.md5Byte(flushByte);

        FileStream fs = new FileStream (AppConst.StreamingAssetsPath + AppConst.FinalSingleFileInfoMD5, FileMode.Create);
        StreamWriter fsw = new StreamWriter(fs);

        fsw.WriteLine(infoMD5);

        fsw.Close ();

        fs.Close();


        //剩下的直接拷贝过去
        foreach (string f in copyFile) {
            // UnityEngine.Debug.Log(AppConst.StreamingAssetsPath + getFileNameWithoutExt(f));
            File.Copy(f, AppConst.StreamingAssetsPath + getFileNameWithoutExt(f));
        }

        EditorUtility.DisplayDialog ("tip", "Merge All Resource Done!", "ok");



    }



    [MenuItem("LuaFramework/5 LogResDep", false, 500)]
    static void LogResDep()
    {
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!File.Exists(path))
        {
            UnityEngine.Debug.Log("Please Select The Correct File!");
            return;
        }

        string[] deps = AssetDatabase.GetDependencies(new string[] { path });

        foreach (string dep in deps)
        {
            //          if( dep.LastIndexOf( "NGUI" ) < 0 )
            //              Util.Log( dep.Substring( dep.LastIndexOf( "Builds" ) ) );
            //Util.Log(dep);
            UnityEngine.Debug.Log(dep);
        }

        AssetDatabase.Refresh();
    }

    [MenuItem("LuaFramework/5 ClearDataPath", false, 501)]
    static void ClearDataPath()
    {
        Directory.Delete(Util.DataPath, true);
    }

	[MenuItem("LuaFramework/6 CreateAnimator", false, 600)]
	static void CreateAnimatorController()
	{
		EBAniData.makeAniCtrlAndPrefab ();
	}
}

public class ResourceNode{
	public string path;
	public string parent;
	public bool repeat;

	public ResourceNode(string path, string parent, bool isRepeat){
		this.path = path;
		this.parent = parent;
		this.repeat = isRepeat;
	}
}