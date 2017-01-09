using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using System.Reflection;
using System.IO;


namespace LuaFramework {
    public class GameManager : Manager, IView {
        //protected static bool initialize = false;
        private List<string> downloadFiles = new List<string>();

        /// <summary>
        /// 初始化游戏管理器
        /// </summary>
        void Awake() {
            Init();
        }

        /// <summary>
        /// 初始化
        /// </summary>
        void Init() {
            DontDestroyOnLoad(gameObject);  //防止销毁自己

            RegisterMessage(this, new List<string>()
                {
                    NotiConst.REBOOT_GAME,
                });

            CheckExtractResource(); //释放资源
            Screen.sleepTimeout = SleepTimeout.NeverSleep;
            Application.targetFrameRate = AppConst.GameFrameRate;
        }


        public virtual void OnMessage(IMessage message) {
            string msg = message.Name;
            switch (msg) {
            case NotiConst.REBOOT_GAME:         //重新起动游戏
				LuaManager.ResetLuaBundle();
				Util.Log( "------> ResetLuaBundle <------");
                break;
            }
        }


        /// <summary>
        /// 释放资源
        /// </summary>
        public void CheckExtractResource() {
            // bool isExists = Directory.Exists(Util.DataPath) &&
            //   Directory.Exists(Util.DataPath + "lua/") && File.Exists(Util.DataPath + "files.txt");
            // if (isExists || AppConst.DebugMode) {
            //     StartCoroutine(OnUpdateResource());
            //     return;   //文件已经解压过了，自己可添加检查文件列表逻辑
            // }
            // StartCoroutine(OnExtractResource());    //启动释放协成 

            facade.SendMessageCommand( NotiConst.LOADING_START, "正在准备游戏" );
#if UNITY_EDITOR  
            //这里需要处理下debug和非debug模式
            //策划想方便 程序想测试
            
			if(AppConst.SimulateAssetBundleInEditor){
                StartCoroutine( OnUpdateResource() ); 
            }else
#endif 
            {
                //测试解压？
                StartCoroutine( OnExtractResource() );
            }
            
        }

        IEnumerator OnExtractResource() {

            Util.Log( "------> extract start <------" );
            string dataPath = Util.DataPath;  //数据目录
            string resPath = Util.AppContentPath(); //游戏包资源目录
            
            if ( !Directory.Exists( dataPath ) ) Directory.CreateDirectory( dataPath );
            
            yield return null;



            //md5对比
            //包内
            string aplicationFileMD5 = resPath + AppConst.FinalSingleFileInfoMD5;
            //包外
            string persistentFileMD5 = dataPath + AppConst.FinalSingleFileInfoMD5;

            string aplicationMd5String = null;
            string persistentMd5String = null;
            
            // 读取文件列表
            string aplicationFileListName = resPath + AppConst.FinalSingleFileInfo;
            


            //获取md5?
            //获取包外
            if (File.Exists (persistentFileMD5)) {
                persistentMd5String = File.ReadAllText( persistentFileMD5 );
            }

            //包内
            WWW www = new WWW( aplicationFileMD5 );
            yield return www;

            aplicationMd5String = www.text;
            www.Dispose();
            
            // md5验证相同,跳过解压
            if( persistentMd5String != null && persistentMd5String.Equals( aplicationMd5String )){
                StartCoroutine( OnUpdateResource() );
                yield break;
            }




            //md5验证不同或者data目录不存在MD5文件
            

            //读取整个单文件
            string inFile = resPath + AppConst.FinalSingleFile;
            www = new WWW( inFile );
            yield return www;


            //解析文件
            ByteBuffer buffer = new ByteBuffer(www.bytes);
            int idx = 0;
            int curIndex = 0;
            int totalCount = buffer.ReadInt();
            byte[] wwwByte = www.bytes;
            NotiConst.MsgProgress msgProgress;

            for (int i = 0; i < totalCount; i ++) {
                //开始写吧
                string outFile = dataPath + buffer.ReadString();
                string dir = Path.GetDirectoryName( outFile );
                if ( !Directory.Exists( dir ) ) Directory.CreateDirectory( dir );

                File.WriteAllBytes( outFile, buffer.ReadBytes());
                curIndex++;
                if( idx++ > 10 ){   // 限制每帧加载4个文件
                    idx = 0;
                    msgProgress.progress = (float)curIndex / (float)totalCount;
                    msgProgress.notice = string.Format( "正在解压:({0}%)", (int)(msgProgress.progress * 100 ));
                    facade.SendMessageCommand( NotiConst.LOADING_PROGRESS, msgProgress);
                    yield return null;
                }
            }
            buffer.Close();

            www.Dispose ();
            //facade.SendMessageCommand( NotiConst.UPDATE_EXTRACT, "解压完毕(100%)" );


            //加载完之后 将包内的md5信息写到包外
            File.WriteAllText (persistentFileMD5, aplicationMd5String);
            

            //Debug.Log("OnExtractResource Done");
            StartCoroutine( OnUpdateResource() );

        }

        /// <summary>
        /// 启动更新下载，这里只是个思路演示，此处可启动线程下载更新
        /// </summary>
        IEnumerator OnUpdateResource() {
            //facade.SendMessageCommand( NotiConst.LOADING_END);
            if (!AppConst.UpdateMode) {
                StartCoroutine(OnResourceInited());
                yield break;
            }
            string dataPath = Util.DataPath;  //数据目录
            string url = AppConst.WebUrl;
            string message = string.Empty;
            string random = DateTime.Now.ToString("yyyymmddhhmmss");
            string listUrl = url + "files.txt?v=" + random;
            Debug.LogWarning("LoadUpdate---->>>" + listUrl);

            WWW www = new WWW(listUrl); yield return www;
            if (www.error != null) {
                OnUpdateFailed(string.Empty);
                yield break;
            }
            if (!Directory.Exists(dataPath)) {
                Directory.CreateDirectory(dataPath);
            }
            File.WriteAllBytes(dataPath + "files.txt", www.bytes);
            string filesText = www.text;
            string[] files = filesText.Split('\n');

            for (int i = 0; i < files.Length; i++) {
                if (string.IsNullOrEmpty(files[i])) continue;
                string[] keyValue = files[i].Split('|');
                string f = keyValue[0];
                string localfile = (dataPath + f).Trim();
                string path = Path.GetDirectoryName(localfile);
                if (!Directory.Exists(path)) {
                    Directory.CreateDirectory(path);
                }
                string fileUrl = url + f + "?v=" + random;
                bool canUpdate = !File.Exists(localfile);
                if (!canUpdate) {
                    string remoteMd5 = keyValue[1].Trim();
                    string localMd5 = Util.md5file(localfile);
                    canUpdate = !remoteMd5.Equals(localMd5);
                    if (canUpdate) File.Delete(localfile);
                }
                if (canUpdate) {   //本地缺少文件
                    Debug.Log(fileUrl);
                    message = "downloading>>" + fileUrl;
                    facade.SendMessageCommand(NotiConst.UPDATE_MESSAGE, message);
                    /*
                    www = new WWW(fileUrl); yield return www;
                    if (www.error != null) {
                        OnUpdateFailed(path);   //
                        yield break;
                    }
                    File.WriteAllBytes(localfile, www.bytes);
                     */
                    //这里都是资源文件，用线程下载
                    BeginDownload(fileUrl, localfile);
                    while (!(IsDownOK(localfile))) { yield return new WaitForEndOfFrame(); }
                }
            }
            yield return new WaitForEndOfFrame();

            message = "更新完成!!";
            facade.SendMessageCommand(NotiConst.UPDATE_MESSAGE, message);

            StartCoroutine(OnResourceInited());
        }

        void OnUpdateFailed(string file) {
            string message = "更新失败!>" + file;
            facade.SendMessageCommand(NotiConst.UPDATE_MESSAGE, message);
        }

        /// <summary>
        /// 是否下载完成
        /// </summary>
        bool IsDownOK(string file) {
            return downloadFiles.Contains(file);
        }

        /// <summary>
        /// 线程下载
        /// </summary>
        void BeginDownload(string url, string file) {     //线程下载
            object[] param = new object[2] { url, file };

            ThreadEvent ev = new ThreadEvent();
            ev.Key = NotiConst.UPDATE_DOWNLOAD;
            ev.evParams.AddRange(param);
            ThreadManager.AddEvent(ev, OnThreadCompleted);   //线程下载
        }

        /// <summary>
        /// 线程完成
        /// </summary>
        /// <param name="data"></param>
        void OnThreadCompleted(NotiData data) {
            switch (data.evName) {
                case NotiConst.UPDATE_EXTRACT:  //解压一个完成
                //
                break;
                case NotiConst.UPDATE_DOWNLOAD: //下载一个完成
                downloadFiles.Add(data.evParam.ToString());
                break;
            }
        }

        /// <summary>
        /// 资源初始化结束
        /// </summary>
        IEnumerator OnResourceInited() {
// #if ASYNC_MODE
//             ResManager.Initialize(AppConst.PublishAssetDir, delegate() {
//                 Debug.Log("Initialize OK!!!");
//                 this.OnInitialize();
//             });
// #else
//             ResManager.Initialize(AppConst.PublishAssetDir);
//             this.OnInitialize();
// #endif

            var request = AssetBundleManager.Initialize(AppConst.PublishAssetDir);
            // var request = AssetBundleManager.Initialize("Windows");
            // Debug.Log("AssetBundleManager.Initialize start" + Time.frameCount);
            if (request != null)
                yield return StartCoroutine(request);
            this.OnInitialize();
        }

        void OnInitialize() {
            LuaManager.InitStart();
            LuaBehaviour.initialize = true;
            LuaManager.DoFile("Main");         //加载游戏
            // LuaManager.DoFile("Logic/Network");      //加载网络
            // NetManager.OnInit();                     //初始化网络
            Util.CallMethod("Main", "main");     //初始化完成
        }

        /// <summary>
        /// 析构函数
        /// </summary>
        void OnDestroy() {
            // if (NetManager != null) {
            //     NetManager.Unload();
            // }
            // if (LuaManager != null) {
            //     LuaManager.Close();
            // }
            Debug.Log("~GameManager was destroyed");
        }
    }
}