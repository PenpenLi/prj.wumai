using UnityEngine;
using System.Collections;
using GameFramework;


public abstract class PanelBase : ResObject {


    public abstract int getLayer();

    public abstract int getStyle();

    public abstract void onBuild(object arguments);


    public PanelBase() : base(null, null) { }


    public PanelBase(object arguments):base(arguments, null)
    {
    }


    public override void onCreate(object arguments)
    {
        MgrPanel.addPanel(this);
        onBuild(arguments);
    }


    public void close()
    {
        MgrPanel.closePanel(this);
        dispose();
    }


    public override void dispose()
    {
        base.dispose();
        stopProcMsg();
        GameObject.Destroy(gameObject);
    }








    private EventHandler m_eventHandler;

    public void addEventCallback(EventId eventId, OnEvent callback)
    {
        if (m_eventHandler == null)
            m_eventHandler = new EventHandler();

        m_eventHandler.addEventCallback(eventId, callback);
    }


    public void startProcMsg()
    {
        if (m_eventHandler != null)
            m_eventHandler.startProcMsg();
    }


    public void stopProcMsg()
    {
        if (m_eventHandler != null)
            m_eventHandler.stopProcMsg();
    }




}
