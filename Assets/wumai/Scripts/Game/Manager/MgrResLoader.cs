using System;
using UnityEngine;
using System.Collections.Generic;
using GameFramework;


public class MgrResLoader {
    // 原始资源加载列表
    private static Dictionary<string, bool> loadingResList = new Dictionary<string, bool>();
    // 原始资源卸载列表
    private static Dictionary<string, bool> removingResList = new Dictionary<string, bool>();
    // 计算完毕的加载资源列表（兼顾卸载和加载后）
    private static Dictionary<string, bool> calculatedLoadResList = new Dictionary<string, bool>();

    private const int MAX_LOAD_TASK = 30;


    public static void start(Action callback)
    {
        preProcess();
        process(callback);
    }


    public static void stop()
    {

    }


    public static void insert(string abName)
    {
        loadingResList[abName] = true;
    }


    public static void remove(string abName)
    {
        removingResList[abName] = true;
    }


    public static void insertLoading(string[] list)
    {
        foreach (var abName in list)
        {
            loadingResList[abName] = true;
        }
    }

    public static void insertRemoving(string[] list)
    {
        foreach (var abName in list)
        {
            removingResList[abName] = true;
        }
    }


    static void preProcess()
    {
        calculatedLoadResList.Clear();
        foreach (var item in removingResList)
        {
            MgrRes.putPrefab(item.Key, null);
        }

        foreach (var item in loadingResList)
        {
            if (!MgrRes.loadReferencedPrefab(item.Key))
            {
                calculatedLoadResList[item.Key] = true;
            }
        }

        //--清空待卸载列表
        removingResList.Clear();
        loadingResList.Clear();
    }


    public static void process(Action callback)
    {
        float total = 0;
        float current = 0;

        LinkedList<string> loadTaskQueue = new LinkedList<string>();
        Action<UnityEngine.Object> onloaded = null;

        onloaded = uobj =>
        {
            current += 1;
            EventDispatcher.getInstance().dispatchEvent(EventId.UI_UPDATE_LOADING, current / total);
            if (current >= total)
            {
                EventDispatcher.getInstance().dispatchEvent(EventId.UI_CLOSE_LOADING);
                callback.Invoke();
                return;
            }

            var abNode = loadTaskQueue.Last;
            if (abNode != null)
            {
                MgrRes.loadPrefab(abNode.Value, null, onloaded);
                loadTaskQueue.RemoveLast();
            }
        };


        foreach (var item in calculatedLoadResList)
        {
            total += 1;
            loadTaskQueue.AddLast(item.Key);
        }


        for (int i = 0; i < MAX_LOAD_TASK; i++)
        {
            var abNode = loadTaskQueue.Last;
            if (abNode != null)
            {
                MgrRes.loadPrefab(abNode.Value, null, onloaded);
                loadTaskQueue.RemoveLast();
            }
        }

        calculatedLoadResList.Clear();

        if (total == 0)
        {
            Tools.Log("MgrResLoader process : no calculatedLoadResList");
            EventDispatcher.getInstance().dispatchEvent(EventId.UI_CLOSE_LOADING);
            callback.Invoke();
        }
    }




	
}
