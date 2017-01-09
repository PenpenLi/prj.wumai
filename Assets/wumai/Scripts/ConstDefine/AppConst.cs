using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace LuaFramework {
    public class AppConst {
        
        // public const bool DebugMode = false;                       //调试模式-用于内部测试

		/// <summary>
		/// 在编辑器模式下是否模拟资源包加载方式？
		/// </summary>
		static int m_SimulateAssetBundleInEditor = -1;
		const string kSimulateAssetBundles = "SimulateAssetBundles";

		/// <summary>
		/// 编辑器模式下是否模拟资源包加载方式？（不需要真正打出资源包，避免每改动一个资源都打一次包的过程）
		/// </summary>
		public static bool SimulateAssetBundleInEditor 
		{
			get
			{
#if UNITY_EDITOR
				if (m_SimulateAssetBundleInEditor == -1)
				{
					m_SimulateAssetBundleInEditor = EditorPrefs.GetBool(kSimulateAssetBundles, true) ? 1 : 0;
				}
				return m_SimulateAssetBundleInEditor != 0;
#else
                return false;
#endif
				
			}
			set
			{
#if UNITY_EDITOR
				int newValue = value ? 1 : 0;
				if (newValue != m_SimulateAssetBundleInEditor)
				{
					m_SimulateAssetBundleInEditor = newValue;
					EditorPrefs.SetBool(kSimulateAssetBundles, value);
				}
#endif
            }
        }

        //SDK模式和debug模式分开
        public const bool SDKMode = false;                        //是否开启sdk计费


        /// <summary>
        /// 如果开启更新模式，前提必须启动框架自带服务器端。
        /// 否则就需要自己将StreamingAssets里面的所有内容
        /// 复制到自己的Webserver上面，并修改下面的WebUrl。
        /// </summary>
        public static bool UpdateMode = false;                       //更新模式-默认关闭 
        public static bool LuaByteMode = true;                       //Lua字节码模式-默认关闭 
        public static bool LuaBundleMode = true;                    //Lua代码AssetBundle模式

        public static bool assetExtract = false;                      //资源是否解压

        public const int TimerInterval = 1;
        public const int GameFrameRate = 45;                        //游戏帧频



		public const string AppName = "wumai";
        public const string AppPath = AppName;
        public const string AppResName = "Res";


        public const string FrameWorkPath = "LuaFramework";               //应用程序文件夹名
        public static readonly string LuaTempDir = "Lua" + "/";                    //临时目录
        public const string AppPrefix = AppName + "_";              //应用程序前缀
        public const string ExtName = ".unity3d";                   //素材扩展名
        public const string LuaExtName = ".bytes";                  //lua文件扩展名
        public const string LuaBundleName = "lua" + ExtName;        //luabundle 名
        public const string AssetDir = "StreamingAssets";           //素材目录 


        public static string PublishAssetDir = "PublishAssets";


        public const string WebUrl = "http://localhost:6688/";      //测试更新地址

        public static string UserId = string.Empty;                 //用户ID
        public static int SocketPort = 0;                           //Socket服务器端口
        public static string SocketAddress = string.Empty;          //Socket服务器地址


        public static string FrameworkRoot {
            get {
                return Application.dataPath + "/" + FrameWorkPath;
            }
        }

        public static string AppRoot {
            get {
                return Application.dataPath + "/" + AppPath;
            }
        }

        public static string StreamingAssetsPath {
            get {
                return Application.dataPath + "/" + AssetDir + "/";
            }
        }

        public static string PublishAssetsPath {
            get {
                return Application.dataPath + "/" + PublishAssetDir + "/";
            }
        }


        //编辑器用的原始path，在根据原始path的资源导成各个平台的资源
        public static readonly string EditorBuildsName = "Builds";
        public static readonly string EditorBuilds = EditorBuildsName + "/";
        public static readonly string EditorBuildResourcePath = AppRoot + "/" + AppResName + "/" + EditorBuilds;

        public static readonly string ResourceNameSplit = "_";  //转化分隔符


        public static readonly string AssetName = "Assets";




        //最终打包文件后缀

        public static string FinalSingleFileExt = ".ultralisk";

        public static string FinalSingleFile = "data" + FinalSingleFileExt;
        //最终打包文件信息列表
        public static string FinalSingleFileInfoExt = ".ultraliskinfo";
        public static string FinalSingleFileInfo = "fileInfo" + FinalSingleFileInfoExt;
        public static string FinalSingleFileInfoMD5 = "fileInfoMD5" + FinalSingleFileInfoExt;
        






        //////////////////////////////////////////////////////////////////////////////////////////////
        /// 更新补丁相关

        public static readonly string BuildsName = "Builds";
        public static readonly string Builds = BuildsName + "/";

        /// 取得数据存放目录
        public static string DataPath {
            get {
                string game = AppConst.AppName.ToLower();
                if (Application.isMobilePlatform) {
                    return Application.persistentDataPath + "/" + game + "/";
                }
                if (Application.platform == RuntimePlatform.WindowsPlayer) {
                    return Application.streamingAssetsPath + "/";
                }
                // if (AppConst.DebugMode) {
                //  if (Application.isEditor) {
                //      return Application.dataPath + "/StreamingAssets/";
                //  }
                // }
                return "c:/" + game + "/";
            }
        }

        /// <summary>
        /// 应用程序内容路径
        /// </summary>
        public static string AppContentPath() {
            string path = string.Empty;
            switch (Application.platform) {
            case RuntimePlatform.Android:
                path = "jar:file://" + Application.dataPath + "!/assets/";
                break;
            case RuntimePlatform.IPhonePlayer:
                path = Application.dataPath + "/Raw/";
                break;
            default:
                // path = "file://" + Application.dataPath + PublishAssets;
                path = "file://" + Application.streamingAssetsPath + "/";
                break;
            }
            return path;
        }

        // 解压资源根目录
        public static readonly string ReleasePathRoot = DataPath;

        public static string PublishAssets = "/PublishAssets/";

        // 发布资源根目录
        public static readonly string PublishPathRoot = Application.dataPath + PublishAssets;

        // 发布资源目录
        public static readonly string PublishResourcePath = Application.streamingAssetsPath + "/" + Builds;

        // 解压资源目录
        public static readonly string ReleaseResourcePath = ReleasePathRoot + Builds;

        //public const string WebUrl = "127.0.0.1:51234/";            //测试更新地址

        // patch文件
        public static readonly string PatchFileName = "patch_info.json";
        
        // patch存档文件
        public static readonly string PatchRecordFile = ReleasePathRoot + "patch_info.r";

        // 下载目录
        public static readonly string PatchTempPath = ReleasePathRoot + "_patchs/";

        /// 更新补丁相关
        //////////////////////////////////////////////////////////////////////////////////////////////
    }
}