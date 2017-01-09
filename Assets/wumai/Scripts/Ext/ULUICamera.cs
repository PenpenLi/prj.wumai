using UnityEngine;
using System.Collections;

public class ULUICamera : MonoBehaviour {


	const float DESIGN_RESOLUTION_WIDTH = 1024;
	const float DESIGN_RESOLUTION_HEIGHT = 576;

    const float DESIGN_RATE = DESIGN_RESOLUTION_WIDTH / DESIGN_RESOLUTION_HEIGHT;

    float originValue = -1;

	void Start () {
	}


    void init(Camera camera)
    {
        if (camera != null)
        {
            // DESIGN_RESOLUTION_SCALE 通常是不会变的
            if (camera.orthographic)
            {
                originValue = camera.orthographicSize;
            }
            else
            {
                originValue = camera.fieldOfView;
            }
        }
    }


    void OnEnable()
    {
        Camera camera = GetComponent<Camera>();
        if (camera != null)
        {
            if (originValue == -1)
                init(camera);

            // DESIGN_RESOLUTION_SCALE 通常是不会变的
            float DESIGN_RESOLUTION_SCALE = (Screen.width / (float)Screen.height) / (DESIGN_RESOLUTION_WIDTH / DESIGN_RESOLUTION_HEIGHT);
            //DESIGN_RESOLUTION_SCALE = 1024f / 768 / DESIGN_RATE;
            //Debug.Log("w:" + Screen.width + " h:" +Screen.height);
            //Debug.Log("DESIGN_RESOLUTION_SCALE:" + DESIGN_RESOLUTION_SCALE);
            if (camera.orthographic)
            {
                camera.orthographicSize = originValue * DESIGN_RESOLUTION_SCALE;
            }
            else
            {
                camera.fieldOfView = originValue * DESIGN_RESOLUTION_SCALE;
            }
        }

        enabled = false;
    }

	
	void Update () {

	}
}
