using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.Events;
using System.Text;
using Global;


public class PanelInput : PanelBase
{

    public PanelInput(object arguments)
        : base(arguments)
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
        return "UI/PanelInput/prefab";
    }



    Text m_inputText;
    CallbackWithParam m_callback;
    public override void onCreate(object arguments)
    {
        var param = arguments as Hashtable;
        string title = param["title"] as string;
        string tip = param["tip"] as string;
        m_callback = param["callback"] as CallbackWithParam;

        if(title != null)
            transform.FindChild("BG/Text").GetComponent<Text>().text = title;

        if (tip != null)
            transform.FindChild("BG/InputField/Placeholder").GetComponent<Text>().text = tip;

        m_inputText = transform.FindChild("BG/InputField/Text").GetComponent<Text>();
        transform.FindChild("BG/Button").GetComponent<Button>().onClick.AddListener(close);

        var btnYes = transform.FindChild("BG/BtnYes");
        btnYes.GetComponent<Button>().onClick.AddListener(onClickYes);
    }


    public void onClickYes()
    {
        string text = m_inputText.text;

        if (!string.IsNullOrEmpty(text))
        {
            if (m_callback != null)
                m_callback.Invoke(text);

            close();
        }
        else
        {
            MgrPanel.openDialog("please enter a text.");
        }
    }






}
