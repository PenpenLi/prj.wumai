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


    public virtual void OnDestroy()
    {
        stopProcMsg();
    }
}
