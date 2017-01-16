using UnityEngine;
using System.Collections;
using GameFramework;



public abstract class EventBehaviour : MonoBehaviour {


    private EventHandler m_eventHandler = new EventHandler();

    public void addEventCallback(EventId eventId, OnEvent callback)
    {
        m_eventHandler.addEventCallback(eventId, callback);
    }


    public void startProcMsg()
    {
        m_eventHandler.startProcMsg();
    }


    public void stopProcMsg()
    {
        m_eventHandler.stopProcMsg();
    }


    void OnDestroy()
    {
        stopProcMsg();
        onDestory();
    }


    public abstract void onDestory();


    //public virtual void onDestory()
    //{
    //    // 强制隐藏该方法
    //    Tools.LogError("you must check onDestory, it's importent.");
    //}
}
