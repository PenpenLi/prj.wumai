using UnityEngine;
using System.Collections;


/// <summary>
/// 新型 函数
/// </summary>
public class Test : MonoBehaviour {

	// Use this for initialization
	void Start () {
        for (float x = -Mathf.PI; x < Mathf.PI; x += 0.01f)
        {
            float y = fun(x);
            createObj(y * Mathf.Cos(x), y * Mathf.Sin(x));
        }
	}


    public void createObj(float x, float y)
    {
        var prefab = Resources.Load<GameObject>("Circle");
        var go = GameObject.Instantiate(prefab);

        go.transform.position = new Vector3(x * 10, y * 10, 0);
    }


    public float fun(float rad)
    {
        float v1 = Mathf.Sin(rad) * Mathf.Pow(Mathf.Abs(Mathf.Cos(rad)), 0.5f);
        float v2 = Mathf.Sin(rad) + 7f / 5f;

        return v1 / v2 - 2 * Mathf.Sin(rad) + 2f;
    }



	
	// Update is called once per frame
	void Update () {
	
	}
}
