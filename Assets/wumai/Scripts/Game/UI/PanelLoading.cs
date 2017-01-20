using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;
using GameFramework;




public class PanelLoading
{


    static PanelLoading m_inst = null;
    public static void open()
    {
        if (m_inst == null)
            m_inst = new PanelLoading();
        else
            m_inst.gameObject.SetActive(true);

        m_inst.transform.SetSiblingIndex(m_inst.transform.parent.childCount);
    }


    Text m_text;
    UnityEngine.UI.Image m_progress;
    EventHandler m_eventHandler;
    GameObject gameObject;
    Transform transform;


    private PanelLoading()
    {
        GameObject prefab = Resources.Load<GameObject>("panelLoading");
        gameObject = GameObject.Instantiate(prefab);
        transform = gameObject.transform;

        m_text = transform.FindChild("Text").GetComponent<Text>();
        m_text.text = "0%";
        m_progress = transform.FindChild("Image/Image").GetComponent<UnityEngine.UI.Image>();

        m_progress.fillAmount = 0;

        m_eventHandler = new EventHandler();
        m_eventHandler.addEventCallback(EventId.UI_CLOSE_LOADING, onClose);
        m_eventHandler.addEventCallback(EventId.UI_UPDATE_LOADING, onUpdate);
        m_eventHandler.startProcMsg();

        transform.SetParent(GameObject.FindWithTag("Canvas").transform, false);
    }


    public void onClose(GameEvent e)
    {
        gameObject.SetActive(false);
    }


    public void onUpdate(GameEvent e)
    {
        float p = (float)e.getData();
        p = Mathf.Lerp(0, 1, p);
        if (p >= 1)
        {
            m_text.text = "100%";
            //MgrTimer.callLaterTime(0, closeLater);
        }
        else
        {
            m_text.text = Mathf.FloorToInt(p * 100) + "%";
        }
    }

}
