using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;
using Global;




public class PanelOption : PanelBase
{


    public PanelOption(object arguments): base(arguments)
    {
    }


    public override int getLayer()
    {
        return MgrPanel.LAYER_UI;
    }


    public override int getStyle()
    {
        return MgrPanel.STYLE_DIALOG;
    }


    public override string getAssetBundleName()
    {
        return "UI/PanelOption/prefab";
    }


    List<OptionItem> m_list = new List<OptionItem>();
    CallbackWithParam m_callback;
    public override void onBuild(object arguments)
    {
        var param = arguments as Hashtable;
        for (int i = 1; i <= 5; i++)
        {
            m_list.Add(new OptionItem(transform.FindChild("BG/Btn" + i).gameObject, i));
        }

        transform.FindChild("BtnClose").GetComponent<Button>().onClick.AddListener(close);

        if (param == null)
            return;

        m_callback = param["callback"] as CallbackWithParam;

        if(m_callback == null)
            return;

        var list = param["options"] as List<string>;

        for (int i = 0; i < list.Count; i++)
        {
            string str = list[i] as string;
            m_list[i].setInfo(str, onClickOpetion);
            m_list[i].show();
        }
    }


    void onClickOpetion(object obj)
    {
        m_callback(obj);
        close();
    }


    public class OptionItem
    {
        GameObject m_gameObject;
        Text m_text;
        int m_index;

        CallbackWithParam m_callback = null;

        public OptionItem(GameObject obj, int idx)
        {
            m_gameObject = obj;
            m_index = idx;
            m_text = obj.transform.FindChild("Text").GetComponent<Text>();
            obj.GetComponent<Button>().onClick.AddListener(onClick);

            hide();
        }


        void onClick()
        {
            if (m_callback != null)
                m_callback.Invoke(m_index);
        }


        public void setInfo(string text, CallbackWithParam callback)
        {
            m_text.text = text;
            m_callback = callback;
        }


        public void hide()
        {
            m_gameObject.SetActive(false);
        }


        public void show()
        {
            m_gameObject.SetActive(true);
        }
    }


}
