using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.Events;



public class PanelDialog : PanelBase {


    public PanelDialog(object arguments)
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
        return "UI/PanelDialog/prefab";
    }


    UnityAction m_onClickYes;
    UnityAction m_onClickNo;


    public override void onBuild(object arguments)
    {
        var param = arguments as Hashtable;

        var btnYes = transform.FindChild("BG/BtnYes");
        btnYes.GetComponent<Button>().onClick.AddListener(onClickYes);

        var btnNo = transform.FindChild("BG/BtnNo");
        btnNo.GetComponent<Button>().onClick.AddListener(onClickNo);

        if (param == null)
        {
            btnNo.gameObject.SetActive(false);
            Vector3 cur = btnYes.localPosition;
            cur.x = 0;
            btnYes.localPosition = cur;
            return;
        }


        if (param.Contains("onYes"))
        {
            m_onClickYes = param["onYes"] as UnityAction;
        }

        if (param.Contains("onNo"))
        {
            m_onClickNo = param["onNo"] as UnityAction;
        }
        else
        {
            // 只有一个按钮就居中
            btnNo.gameObject.SetActive(false);
            Vector3 cur = btnYes.localPosition;
            cur.x = 0;
            btnYes.localPosition = cur;
        }

        if (param.Contains("text"))
        {
            gameObject.transform.FindChild("BG/Text").GetComponent<Text>().text = param["text"] as string;
        }
    }


    public void onClickYes()
    {
        if (m_onClickYes != null)
            m_onClickYes();

        close();
    }


    public void onClickNo()
    {
        if (m_onClickNo != null)
            m_onClickNo();

        close();
    }





}
