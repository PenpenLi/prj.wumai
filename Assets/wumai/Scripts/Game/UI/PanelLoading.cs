using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;
using EventSystem;
using System;




public class PanelLoading : PanelBase
{


    static PanelLoading m_inst = null;
    public static PanelLoading getInstance()
    {
        if (m_inst == null)
            m_inst = new PanelLoading();

        return m_inst;
    }


    public override void clean()
    {
        m_inst = null;
    }


    public override int getLayer()
    {
        return MgrPanel.LAYER_UI;
    }


    public override int getStyle()
    {
        return MgrPanel.STYLE_COMMON;
    }


    public override string getResName()
    {
        return "PanelLoading";
    }

    private PanelLoading()
    {
        addEventCallback(EventId.UI_CLOSE_LOADING, onClose);
        addEventCallback(EventId.UI_UPDATE_LOADING, onUpdate);
        startProcMsg();
    }


    Text m_text;
    public override void onBuild(Hashtable param)
    {
        m_text = transform.FindChild("Text").GetComponent<Text>();
        m_text.text = "0%";
    }


    public void onClose(GameEvent e)
    {
        close();
    }


    public void onUpdate(GameEvent e)
    {
        float p = (float)e.getData();
        p = Mathf.Lerp(0, 1, p);
        if (p >= 1)
        {
            m_text.text = "100%";
            MgrTimer.callLaterTime(0, closeLater);
        }
        else
        {
            m_text.text = Mathf.FloorToInt(p * 100) + "%";
        }
    }


    public void closeLater(object obj)
    {
        if (m_inst != null)
        {
            close();
        }
    }

}
