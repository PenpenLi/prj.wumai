using UnityEngine;
using System.Collections;


/// <summary>
/// 新型 函数
/// </summary>
public class Test : MonoBehaviour {

	// Use this for initialization
	void Start () {
        var l = gameObject.GetComponent<UIEventListener>();
        l.onClick = onClick;
	}


    void onClick(GameObject go, UnityEngine.EventSystems.PointerEventData e)
    {
        Debug.Log("----------- onClick.");
    }




	
	// Update is called once per frame
	void Update () {
	
	}
}
