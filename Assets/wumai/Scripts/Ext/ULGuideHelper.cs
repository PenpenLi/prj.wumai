using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine.EventSystems;




public class ULGuideHelper : MonoBehaviour {


    public Transform guideRoot = null;

    public Camera uiCamera = null;


	void Start () {
        if (guideRoot == null || uiCamera == null)
            Debug.LogError("ULGuideHelper not ready.");
	}


    public bool uiExists(string uiName)
    {
        Transform child = guideRoot.FindChild(uiName);
        if(child == null)
            return false;

        return true;
    }


    public Transform findUi(string uiName)
    {
        Transform child = guideRoot.FindChild(uiName);
        if (child == null)
        {
            var uiObj = GameObject.Find(uiName);
            if (uiObj != null)
                child = uiObj.transform;
        }

        return child;
    }


    public Vector2 getUiPosition(string uiName, RectTransform trans, Camera camera)
    {
        Transform child = findUi(uiName);
        if (child == null)
            return Vector2.zero;

        Vector2 pos;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(trans, camera.WorldToScreenPoint(child.position), uiCamera, out pos);

        return pos;
    }


    public Vector2 getUiPosition(string uiName, RectTransform trans)
    {
        return getUiPosition(uiName, trans, uiCamera);
    }


    public Vector2 getUiPosition(string uiName, Transform trans)
    {
        RectTransform rtrans = trans as RectTransform;
        return getUiPosition(uiName, rtrans);
    }


    public Vector2 getUiPosition(string uiName, Transform trans, Camera camera)
    {
        RectTransform rtrans = trans as RectTransform;
        return getUiPosition(uiName, rtrans, camera);
    }


    public void tryClick(string uiName)
    {
		Transform child = findUi(uiName);
        if(child == null)
            return;

        // 先button
        Button btn = child.GetComponent<Button>();
        if (btn != null)
        {
            btn.onClick.Invoke();
            return;
        }

        // 再toggle
        ULToggle ulToggle = child.GetComponent<ULToggle>();
        if (ulToggle != null)
        {
			ulToggle.isOn = !ulToggle.isOn;
            return;
        }

        Toggle toggle = child.GetComponent<Toggle>();
        if (toggle != null)
        {
			toggle.isOn = !toggle.isOn;
            return;
        }

        // 再UIEventListener（先click再pointDown）
        UIEventListener listener = child.GetComponent<UIEventListener>();
        if (listener != null)
        {
            listener.OnPointerDown(new PointerEventData(EventSystem.current));
			StartCoroutine (LaterUp(listener));
            return;
        }

        Debug.LogWarning("ULGuideHelper: can't click any widget");
    }


	IEnumerator LaterUp(UIEventListener listener)
	{
		yield return null;
		if(listener && listener.enabled)
            listener.OnPointerUp(new PointerEventData(EventSystem.current));
	}




	
	void Update () {}
}
