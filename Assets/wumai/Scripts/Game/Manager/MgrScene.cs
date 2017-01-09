using UnityEngine;
using System.Collections;

public class MgrScene : EventBehaviour
{

	// Use this for initialization


	public static Camera uiCamera;
	public static Camera battleCamera;

    const float DESIGN_RESOLUTION_WIDTH = 1024;
    const float DESIGN_RESOLUTION_HEIGHT = 576;

    public static float DESIGN_RESOLUTION_SCALE = ((float)Screen.width / Screen.height) / (DESIGN_RESOLUTION_WIDTH / DESIGN_RESOLUTION_HEIGHT);


	void Awake()
    {
		uiCamera = GameObject.Find ("UIRoot/UiCamera").GetComponent<Camera>();
		battleCamera = GameObject.Find("BattleCamera").GetComponent<Camera>();
//		battleCamera.enabled = false;
        //float value = battleCamera.fieldOfView;
        //battleCamera.fieldOfView = 50 / DESIGN_RESOLUTION_SCALE;
	}


    public override void onDestory()
    {
    }


	static SceneBase m_curScene;
	void Start ()
    {
        openNextScene(new SceneMain());
	}


    void OnDestroy()
    {
        if (m_curScene != null)
            m_curScene.onLeave();

        m_curScene = null;
    }


    public static void openNextScene(SceneBase scene)
    {
        if (m_curScene != null)
            m_curScene.onLeave();

        MgrPanel.disposeAllPanel();

        m_curScene = scene;
        m_curScene.onEnter();
    }

	// Update is called once per frame
	void Update ()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            MgrPanel.openDialog("Quit Game?", () =>
            {
                Application.Quit();
            }, () =>
            {
                //
            });
        }
	}
}
