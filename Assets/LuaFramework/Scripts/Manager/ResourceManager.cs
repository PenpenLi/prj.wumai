#if ASYNC_MODE
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using LuaInterface;
using UObject = UnityEngine.Object;

public class AssetBundleInfo {
    public AssetBundle m_AssetBundle;
    public int m_ReferencedCount;

    public AssetBundleInfo(AssetBundle assetBundle) {
        m_AssetBundle = assetBundle;
        m_ReferencedCount = 0;
    }
}

namespace LuaFramework {

    public class ResourceManager : Manager {
        string m_BaseDownloadingURLDataPath = "";
        string m_BaseDownloadingURLResPath = "";
        AssetBundleManifest m_AssetBundleManifest = null;
        Dictionary<string, string[]> m_Dependencies = new Dictionary<string, string[]>();
        Dictionary<string, AssetBundleInfo> m_LoadedAssetBundles = new Dictionary<string, AssetBundleInfo>();
        Dictionary<string, string> m_LoadingAssetBundlesName = new Dictionary<string, string>();
        Dictionary<string, List<LoadAssetRequest>> m_LoadRequests = new Dictionary<string, List<LoadAssetRequest>>();

        class LoadAssetRequest {
            public Type assetType;
            public string[] assetNames;
            public LuaFunction luaFunc;
            public Action<UObject[]> sharpFunc;
        }

        // Load AssetBundleManifest.
        public void Initialize(string manifestName, Action initOK) {
            m_BaseDownloadingURLDataPath = Util.DataPath;
            m_BaseDownloadingURLResPath = Util.AppContentPath();
#if UNITY_EDITOR
			if (AppConst.SimulateAssetBundleInEditor) {
				if (initOK != null)
					initOK ();
			} 
			else
#endif
			{
				LoadAsset<AssetBundleManifest> (manifestName, new string[] { "AssetBundleManifest" }, delegate(UObject[] objs) {
					if (objs.Length > 0) {
						m_AssetBundleManifest = objs [0] as AssetBundleManifest;
					}
					if (initOK != null)
						initOK ();
				});
			}
           
        }

        public void LoadPrefab(string abName, string assetName, Action<UObject[]> func) {
            LoadAsset<GameObject>(abName, new string[] { assetName }, func);
        }

        public void LoadPrefab(string abName, string[] assetNames, Action<UObject[]> func) {
            LoadAsset<GameObject>(abName, assetNames, func);
        }

        public void LoadLuaPrefab(string abName, string[] assetNames, LuaFunction func) {
            LoadAsset<GameObject>(abName, assetNames, null, func);
        }

        string GetRealAssetPath(string abName) {
            if (abName.Equals(AppConst.PublishAssetDir)) {
                return abName;
            }
            abName = abName.ToLower();
            return abName;
            // if (abName.Contains("/")) {
            //     return abName;
            // }
            // string[] paths = m_AssetBundleManifest.GetAllAssetBundles();
            // for (int i = 0; i < paths.Length; i++) {
            //     int index = paths[i].LastIndexOf('/');
            //     string path = paths[i].Remove(0, index + 1);
            //     if (path.Equals(abName)) {
            //         return paths[i];
            //     }
            // }
            // Debug.LogError("GetRealAssetPath Error:>>" + abName);
            // return null;
        }

        /// <summary>
        /// 载入素材
        /// </summary>
        void LoadAsset<T>(string abName, string[] assetNames, Action<UObject[]> action = null, LuaFunction func = null) where T : UObject {
            abName = GetRealAssetPath(abName);

            LoadAssetRequest request = new LoadAssetRequest();
            request.assetType = typeof(T);
            request.assetNames = assetNames;
            request.luaFunc = func;
            request.sharpFunc = action;

#if UNITY_EDITOR
			if (AppConst.SimulateAssetBundleInEditor) {
				List<UObject> result = new List<UObject> ();
				for (int j = 0; j < assetNames.Length; j++) {
					string[] assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName (abName, assetNames [j]);
					if (assetPaths.Length == 0) {
						Debug.LogError ("There is no asset with name \"" + assetNames [j] + "\" in " + abName);
						return;
					}

					UObject target = AssetDatabase.LoadMainAssetAtPath (assetPaths [0]);
					result.Add (target);
				}

				if (request.sharpFunc != null) {
					request.sharpFunc (result.ToArray ());
					request.sharpFunc = null;
				}
				if (request.luaFunc != null) {
					request.luaFunc.Call ((object)result.ToArray ()); 
					request.luaFunc.Dispose ();
					request.luaFunc = null;
				}
			} 
			else
#endif
			{
				List<LoadAssetRequest> requests = null;
				if (!m_LoadRequests.TryGetValue (abName, out requests)) {
					requests = new List<LoadAssetRequest> ();
					requests.Add (request);
					m_LoadRequests.Add (abName, requests);
					StartCoroutine (OnLoadAsset<T> (abName));
				} else {
					requests.Add (request);
				}
			}

        }

        IEnumerator OnLoadAsset<T>(string abName) where T : UObject {
            AssetBundleInfo bundleInfo = GetLoadedAssetBundle(abName);
            if (bundleInfo == null) {
                m_LoadingAssetBundlesName.Add(abName, abName);
                yield return StartCoroutine(OnLoadAssetBundle(abName, typeof(T)));

                bundleInfo = GetLoadedAssetBundle(abName);
                if (bundleInfo == null) {
                    m_LoadRequests.Remove(abName);
                    Debug.LogError("OnLoadAsset--->>>" + abName);
                    yield break;
                }
            }
            List<LoadAssetRequest> list = null;
            if (!m_LoadRequests.TryGetValue(abName, out list)) {
                m_LoadRequests.Remove(abName);
                yield break;
            }
            for (int i = 0; i < list.Count; i++) {
                string[] assetNames = list[i].assetNames;
                List<UObject> result = new List<UObject>();

                AssetBundle ab = bundleInfo.m_AssetBundle;
                for (int j = 0; j < assetNames.Length; j++) {
                    string assetPath = assetNames[j];
                    AssetBundleRequest request = ab.LoadAssetAsync(assetPath, list[i].assetType);
                    yield return request;
                    result.Add(request.asset);

                    //T assetObj = ab.LoadAsset<T>(assetPath);
                    //result.Add(assetObj);
                }
                if (list[i].sharpFunc != null) {
                    list[i].sharpFunc(result.ToArray());
                    list[i].sharpFunc = null;
                }
                if (list[i].luaFunc != null) {
                    list[i].luaFunc.Call((object)result.ToArray()); 
                    list[i].luaFunc.Dispose();
                    list[i].luaFunc = null;
                }
                bundleInfo.m_ReferencedCount++;
            }
            m_LoadRequests.Remove(abName);
        }

        IEnumerator OnLoadAssetBundle(string abName, Type type) {
            //先从解压出来的资源去取，如果外面不存在，在从包内去取
            string url = m_BaseDownloadingURLDataPath + abName;
            if(!File.Exists(url)){
                url = m_BaseDownloadingURLResPath + abName;
            }else
            {
                url = "file:///" + url;
            }

            WWW download = null;
            if (type == typeof(AssetBundleManifest))
                download = new WWW(url);
            else {
                string[] dependencies = m_AssetBundleManifest.GetAllDependencies(abName);
                if (dependencies.Length > 0) {
                    if(!m_Dependencies.ContainsKey(abName))//如果不存在再加，用的dependencies加载
                        m_Dependencies.Add(abName, dependencies);
                    for (int i = 0; i < dependencies.Length; i++) {
                        string depName = dependencies[i];
                        AssetBundleInfo bundleInfo = null;
                        if (m_LoadedAssetBundles.TryGetValue(depName, out bundleInfo)) {
                            bundleInfo.m_ReferencedCount++;
                        } else if (!m_LoadRequests.ContainsKey(depName)) {
                            if (!m_LoadingAssetBundlesName.ContainsKey(depName))
                            {
                                //loading中不包含
                                m_LoadingAssetBundlesName.Add(depName, depName);
                                yield return StartCoroutine(OnLoadAssetBundle(depName, type));
                            }
                            
                        }
                    }
                }
                //download = WWW.LoadFromCacheOrDownload(url, m_AssetBundleManifest.GetAssetBundleHash(abName), 0);
                download = new WWW(url);
            }
            yield return download;

            AssetBundle assetObj = download.assetBundle;
            if (assetObj != null) {
                m_LoadedAssetBundles.Add(abName, new AssetBundleInfo(assetObj));
            }
            m_LoadingAssetBundlesName.Remove(abName);
        }

        AssetBundleInfo GetLoadedAssetBundle(string abName) {
            AssetBundleInfo bundle = null;
            m_LoadedAssetBundles.TryGetValue(abName, out bundle);
            if (bundle == null) return null;

            // No dependencies are recorded, only the bundle itself is required.
            string[] dependencies = null;
            if (!m_Dependencies.TryGetValue(abName, out dependencies))
                return bundle;

            // Make sure all dependencies are loaded
            foreach (var dependency in dependencies) {
                AssetBundleInfo dependentBundle;
                m_LoadedAssetBundles.TryGetValue(dependency, out dependentBundle);
                if (dependentBundle == null) return null;
            }
            return bundle;
        }

        public void UnloadAssetBundle(string abName) {
            //Debug.Log(m_LoadedAssetBundles.Count + " assetbundle(s) in memory before unloading " + abName);
#if UNITY_EDITOR
			if(AppConst.SimulateAssetBundleInEditor){
				return;
			}
			else
#endif
			{
				abName = GetRealAssetPath(abName);
				UnloadAssetBundleInternal (abName);
				UnloadDependencies (abName);
			}
            //Debug.Log(m_LoadedAssetBundles.Count + " assetbundle(s) in memory after unloading " + abName);
        }

        void UnloadDependencies(string abName) {
            string[] dependencies = null;
            if (!m_Dependencies.TryGetValue(abName, out dependencies))
                return;

            // Loop dependencies.
            foreach (var dependency in dependencies) {
                UnloadAssetBundleInternal(dependency);
            }
            m_Dependencies.Remove(abName);
        }

        void UnloadAssetBundleInternal(string abName) {
            AssetBundleInfo bundle = GetLoadedAssetBundle(abName);
            if (bundle == null) return;

            if (--bundle.m_ReferencedCount == 0) {
                bundle.m_AssetBundle.Unload(true);
                m_LoadedAssetBundles.Remove(abName);
                //Debug.Log(abName + " has been unloaded successfully");
            }
        }

        public static System.Object ResourceLoad(string name)
        {
            return Resources.Load(name);
        }
    }
}
#else

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using LuaFramework;
using LuaInterface;
using UObject = UnityEngine.Object;


public class AssetBundleInfo
{
    public AssetBundle m_AssetBundle;
    public int m_ReferencedCount;

    public AssetBundleInfo(AssetBundle assetBundle)
    {
        m_AssetBundle = assetBundle;
        m_ReferencedCount = 0;
    }
}


namespace LuaFramework {
    public class ResourceManager : Manager {
        string m_BaseDownloadingURLDataPath = "";
        string m_BaseDownloadingURLResPath = "";
        private string[] m_Variants = { };
        private AssetBundleManifest manifest;

        Dictionary<string, string[]> m_Dependencies = new Dictionary<string, string[]>();
        private Dictionary<string, AssetBundleInfo> bundleInfoDictionary;

        void Awake() {
        }

        /// <summary>
        /// 初始化
        /// </summary>
        public void Initialize(string manifestName) {
            m_BaseDownloadingURLDataPath = Util.DataPath;
            m_BaseDownloadingURLResPath = Util.AppContentPath(false);
            bundleInfoDictionary = new Dictionary<string, AssetBundleInfo>();

            manifest = LoadAsset<AssetBundleManifest>(manifestName, "AssetBundleManifest", false);
        }

        /// <summary>
        /// 载入素材
        /// </summary>
        public T LoadAsset<T>(string abname, string assetname, bool dependencies) where T : UnityEngine.Object {
            abname = abname.ToLower();
            AssetBundleInfo bundleInfo = LoadAssetBundle(abname, dependencies);
            return bundleInfo.m_AssetBundle.LoadAsset<T>(assetname);
        }

        public void LoadLuaPrefab(string abName, string[] assetNames, LuaFunction func) {
            abName = abName.ToLower();
            List<UObject> result = new List<UObject>();
            for (int i = 0; i < assetNames.Length; i++) {
                UObject go = LoadAsset<UObject>(abName, assetNames[i], true);
                if (go != null) result.Add(go);
            }
            if (func != null) func.Call((object)result.ToArray());
        }

        /// <summary>
        /// 载入AssetBundle
        /// </summary>
        /// <param name="abname"></param>
        /// <returns></returns>
        public AssetBundleInfo LoadAssetBundle(string abname, bool dependencies) {
            AssetBundleInfo bundleInfo = null;
            if (!bundleInfoDictionary.ContainsKey(abname)) {
                byte[] stream = null;
                //string uri = Util.DataPath + abname;
                //先从解压出来的资源去取，如果外面不存在，在从包内去取
                string uri = m_BaseDownloadingURLDataPath + abname;
                if (!File.Exists(uri))
                {
                    uri = m_BaseDownloadingURLResPath + abname;
                }
                Debug.LogWarning("LoadFile::>> " + uri);
                if(dependencies)
                    LoadDependencies(abname);

                stream = File.ReadAllBytes(uri);
                bundleInfo = new AssetBundleInfo(AssetBundle.LoadFromMemory(stream));//关联数据的素材绑定
                bundleInfoDictionary.Add(abname, bundleInfo);
            } else {
                bundleInfoDictionary.TryGetValue(abname, out bundleInfo);
                
            }

            bundleInfo.m_ReferencedCount++;
            return bundleInfo;
        }

        /// <summary>
        /// 载入依赖
        /// </summary>
        /// <param name="name"></param>
        void LoadDependencies(string name) {
            if (manifest == null) {
                Debug.LogError("Please initialize AssetBundleManifest by calling AssetBundleManager.Initialize()");
                return;
            }
            // Get dependecies from the AssetBundleManifest object..
            string[] dependencies = manifest.GetAllDependencies(name);
            
            if (dependencies.Length == 0) return;
            

            for (int i = 0; i < dependencies.Length; i++)
                dependencies[i] = RemapVariantName(dependencies[i]);
            if (!m_Dependencies.ContainsKey(name))//如果不存在再加，用的dependencies加载
                m_Dependencies.Add(name, dependencies);
            // Record and load all dependencies.
            for (int i = 0; i < dependencies.Length; i++) {
                LoadAssetBundle(dependencies[i], true);
            }
        }

        // Remaps the asset bundle name to the best fitting asset bundle variant.
        string RemapVariantName(string assetBundleName) {
            return assetBundleName.ToLower();
        }

        public void UnloadAssetBundle(string abName)
        {
            //Debug.Log(m_LoadedAssetBundles.Count + " assetbundle(s) in memory before unloading " + abName);
#if UNITY_EDITOR
            if (AppConst.SimulateAssetBundleInEditor)
            {
                return;
            }
            else
#endif
            {
                abName = RemapVariantName(abName);
                UnloadAssetBundleInternal(abName);
                UnloadDependencies(abName);
            }
            //Debug.Log(m_LoadedAssetBundles.Count + " assetbundle(s) in memory after unloading " + abName);
        }

        void UnloadDependencies(string abName)
        {
            string[] dependencies = null;
            if (!m_Dependencies.TryGetValue(abName, out dependencies))
                return;

            // Loop dependencies.
            foreach (var dependency in dependencies)
            {
                UnloadAssetBundleInternal(dependency);
            }
            m_Dependencies.Remove(abName);
        }

        void UnloadAssetBundleInternal(string abName)
        {
            AssetBundleInfo bundle = null;
            bundleInfoDictionary.TryGetValue(abName, out bundle);
            if (bundle == null) return;

            if (--bundle.m_ReferencedCount == 0)
            {
                bundle.m_AssetBundle.Unload(true);
                Debug.LogWarning("UnloadFile::>> " + abName);
                bundleInfoDictionary.Remove(abName);
                //Debug.Log(abName + " has been unloaded successfully");
            }
        }

        /// <summary>
        /// 销毁资源
        /// </summary>
        void OnDestroy() {
            //if (shared != null) shared.Unload(true);
            if (manifest != null) manifest = null;
            Debug.Log("~ResourceManager was destroy!");
        }

        public static System.Object ResourceLoad(string name)
        {
            return Resources.Load(name);
        }
    }
}
#endif
