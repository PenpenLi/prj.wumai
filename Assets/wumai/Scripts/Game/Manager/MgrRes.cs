using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions; 
using UnityEngine;
using LuaFramework;
using UObject = UnityEngine.Object;



public class MgrRes
{
    class ObjectRef
    {
        public UObject obj;
        public int referencedCount = 0;
        public string assetBundleName;
    }

    static Dictionary<string, ObjectRef> OBJECT_CACHE = new Dictionary<string, ObjectRef>();

    static Dictionary<string, List<Action<UObject>>> loadingRequestCallbackList = new Dictionary<string, List<Action<UObject>>>();


    public static UObject getObject(string resName)
    {
        UObject go = Resources.Load<UObject>("Prefab/" + resName);
        return go;
    }


    public static UObject newObject(string resName)
    {
        return GameObject.Instantiate(getObject(resName));
    }


    public static void loadPrefab(string assetBundleKey, string assetName, Action<UObject> callback, bool fullPath = false)
    {
        if (callback == null)
            callback = obj => { };

        if (assetName == null)
            assetName = getAssetNameByKey(assetBundleKey);

        var objectCacheKey = getObjectCacheKey(assetBundleKey, assetName);
        ObjectRef resObject;
        if (OBJECT_CACHE.TryGetValue(objectCacheKey, out resObject))
        {
            resObject.referencedCount++;
            callback.Invoke(resObject.obj);
            return;
        }

        //将callback挂载loadingRequest中，当加载完毕后再依次调用callback
        List<Action<UObject>> callbacks;
        if (loadingRequestCallbackList.TryGetValue(objectCacheKey, out callbacks))
        {
            callbacks.Add(callback);
            return;
        }
        else
        {
            callbacks = new List<Action<UObject>>();
            callbacks.Add(callback);
            loadingRequestCallbackList.Add(objectCacheKey, callbacks);
        }

        string assetBundleName;
        if (fullPath)
        {
            assetBundleName = assetBundleKey;
        }
        else
        {
            assetBundleName = getAssetBundleNameByKey(assetBundleKey);
        }

        LuaHelper.GetAssetBundleManager().LoadAsyncPrefab2(assetBundleName, assetName, obj =>
        {
            onLoadPrefab(assetBundleName, objectCacheKey, obj);
        });
    }


     /// <summary>
     /// 根据key获取资源名 exp:test/cube/prefab 获取cube
     /// </summary>
    static string getAssetNameByKey(string key)
    {
        return Regex.Match(key, @"/(.*?)/", RegexOptions.RightToLeft).Groups[1].Value;
    }


    /// <summary>
    /// assetBundle和asset组合成的唯一key
    /// </summary>
    static string getObjectCacheKey(string key, string name)
    {
        if (name == null)
            name = getAssetNameByKey(key);
        return key + "|" + name;
    }

    /// <summary>
    /// join with |
    /// </summary>
    static string getAssetBundleNameByKey(string key)
    {
        key = key.Replace("/", "_").Replace(" ", "_");
        return AppConst.AssetName + "_" + AppConst.AppPath + "_" + AppConst.AppResName + "_" + AppConst.EditorBuildsName + "_" + key;
    }


    static void onLoadPrefab(string assetBundleName, string objectCacheKey, UObject obj)
    {
        var oRef = new ObjectRef();
        oRef.obj = obj;
        oRef.assetBundleName = assetBundleName;

        OBJECT_CACHE.Add(objectCacheKey, oRef);

        var callbacks = loadingRequestCallbackList[objectCacheKey];
        oRef.referencedCount = callbacks.Count;
        for (int i = 0; i < callbacks.Count; i++)
        {
            callbacks[i].Invoke(obj);
        }
        loadingRequestCallbackList.Remove(objectCacheKey);
    }



    public static void putPrefab(string assetBundleKey, string assetName)
    {
        var objectCacheKey = getObjectCacheKey(assetBundleKey, assetName);
        ObjectRef oRef;
        OBJECT_CACHE.TryGetValue(objectCacheKey, out oRef);
        if (oRef != null)
            oRef.referencedCount--;
    }


    public static void clearObjectCacheAll()
    {
        List<string> removes = new List<string>();
        foreach (var pair in OBJECT_CACHE)
        {
            if (pair.Value.referencedCount <= 0)
                removes.Add(pair.Value.assetBundleName);
        }

        foreach (var key in removes)
        {
            OBJECT_CACHE.Remove(key);
        }
    }

    

}
