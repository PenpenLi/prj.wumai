using UnityEngine;
using LuaFramework;
using System.Collections.Generic;

public class AppView : View {
    private string message;
    public GameObject panel = null;
    public UnityEngine.UI.Text text = null;
    public UnityEngine.UI.Image progress = null;

    ///<summary>
    /// 监听的消息
    ///</summary>
    List<string> MessageList {
        get {
            return new List<string>()
            { 
                NotiConst.LOADING_START,
                NotiConst.LOADING_PROGRESS,
                NotiConst.LOADING_END,
				NotiConst.UPDATE_EXTRACT,
				NotiConst.UPDATE_PROGRESS,
				NotiConst.UPDATE_MESSAGE,
				NotiConst.UPDATE_DOWNLOAD,
            };
        }
    }

    void Awake() {
        RemoveMessage(this, MessageList);
        RegisterMessage(this, MessageList);
    }

    /// <summary>
    /// 处理View消息
    /// </summary>
    /// <param name="message"></param>
    public override void OnMessage(IMessage message) {
        string name = message.Name;
        object body = message.Body;
        switch (name) {
            case NotiConst.LOADING_START:      //更新消息
                LoadingStart(body.ToString());
            break;
            case NotiConst.LOADING_PROGRESS:      //更新解压
				LoadingProgress(body.ToString());
            break;
            case NotiConst.LOADING_END:     //更新下载
                LoadingEnd();
            break;
			case NotiConst.UPDATE_MESSAGE:
				LoadingProgress(body.ToString());
			break;
			case NotiConst.UPDATE_PROGRESS:
				UpdateProgress(body.ToString());
			break;
        }
    }




    public void LoadingStart(string data) {
        string name = "PanelLoading";
        panel = GameObject.FindWithTag( name );
        if( panel != null ) return;
        
        GameObject prefab = ResourceManager.ResourceLoad( name ) as GameObject;
        panel = Instantiate( prefab ) as GameObject;

        GameObject go = GameObject.FindWithTag("Canvas");
        if( go != null )
            //panel.transform.parent = go.transform;
            panel.transform.SetParent(go.transform, false);
        //panel.transform.localPosition = Vector3.zero;
        //panel.transform.localScale = Vector3.one;
        panel.name = name;
		if(panel.transform.FindChild("Text") != null) {
			text = panel.transform.FindChild("Text").GetComponent<UnityEngine.UI.Text>();
			text.text = data;
		}

        if (panel.transform.FindChild("Image/Image") != null)
        {
            progress = panel.transform.FindChild("Image/Image").GetComponent<UnityEngine.UI.Image>();
		}
    }


	public void LoadingProgress(string msg) {
        if(text == null ) return;

        text.text = msg;

        // GameObject tip = ui.transform.FindChild( "AnchorBottom/loadMessageLabel" ).gameObject;
        // UILabel label = tip.GetComponent<UILabel>();

        // label.text = data;
    }

    
	public void UpdateProgress(string msg){
		if(progress == null) return;

		float value = float.Parse( msg );

        progress.fillAmount = value;
    }

    public void LoadingEnd() {
        // GameObject ui = GameObject.Find( "/GameGui/Camera/SceneUpdate" );
        // if( ui == null ) return;

        // GameObject.Destroy( ui );
        GameObject.Destroy(panel);
        panel = null;
        text = null;
    }
    
    
    void PassUpdate(){
        
    }

    // void OnGUI() {
    //     GUI.Label(new Rect(10, 120, 960, 50), message);

    //     GUI.Label(new Rect(10, 0, 500, 50), "(1) 单击 \"Lua/Gen Lua Wrap Files\"。");
    //     GUI.Label(new Rect(10, 20, 500, 50), "(2) 运行Unity游戏");
    //     GUI.Label(new Rect(10, 40, 500, 50), "PS: 清除缓存，单击\"Lua/Clear LuaBinder File + Wrap Files\"。");
    //     GUI.Label(new Rect(10, 60, 900, 50), "PS: 若运行到真机，请设置Const.DebugMode=false，本地调试请设置Const.DebugMode=true");
    //     GUI.Label(new Rect(10, 80, 500, 50), "PS: 加Unity+ulua技术讨论群：>>341746602");
    // }
}
