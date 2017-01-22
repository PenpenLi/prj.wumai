using UnityEngine;
using System.Collections;


/// <summary>
/// 新型 函数
/// </summary>
public class Test : MonoBehaviour {

	// Use this for initialization
	void Start () {
        var l = gameObject.GetComponent<UIEventListener>();
        l.OnPointerClick = onClick;
	}


    void onClick(UnityEngine.EventSystems.PointerEventData e,)


	
	// Update is called once per frame
	void Update () {
	
	}
}
