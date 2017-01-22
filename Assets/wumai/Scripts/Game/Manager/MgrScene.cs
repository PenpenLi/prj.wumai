using UnityEngine;
using System.Collections;
using LuaFramework;


public class MgrScene : EventBehaviour
{

	// Use this for initialization


	public static Camera uiCamera;

    const float DESIGN_RESOLUTION_WIDTH = 1024;
    const float DESIGN_RESOLUTION_HEIGHT = 576;

    public static float DESIGN_RESOLUTION_SCALE = ((float)Screen.width / Screen.height) / (DESIGN_RESOLUTION_WIDTH / DESIGN_RESOLUTION_HEIGHT);


    private static bool m_busy = false;

	void Awake()
    {
        uiCamera = GameObject.Find("UIRoot/UICamera").GetComponent<Camera>();
	}




	static SceneBase m_curScene;
    static SceneBase m_nextScene;

	void Start ()
    {
        openNextScene(new SceneMain());
        Tools.SendMessageCommand(NotiConst.LOADING_END, "");
	}


    public override void OnDestroy()
    {
        base.OnDestroy();
        if (m_curScene != null)
            m_curScene.onLeave();

        m_curScene = null;
    }


    public static void openNextScene(SceneBase scene)
    {
        Tools.Log("===> openNextScene!");
        if (m_busy)
        {
            Tools.Log("next scene is busy now!");
            return;
        }
        //MgrPanel.disposeAllPanel();

        if (m_curScene != null)
        {
            MgrResLoader.insertRemoving(m_curScene.getResList());
            m_curScene.onLeave();
            m_curScene = null;
        }

        m_busy = true;
        PanelLoading.open();

        MgrResLoader.insertLoading(scene.getResList());
        m_nextScene = scene;

        MgrPanel.disposeAllPanel();
        MgrRes.clearObjectCacheAll();
        Util.ClearMemory();

        MgrResLoader.start(executeSceneDown);
    }


    static void executeSceneDown()
    {
        m_curScene = m_nextScene;
        m_nextScene = null;
        m_busy = false;
        m_curScene.onEnter();

        Tools.Log("enter executeSceneDown.");
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
