using UnityEngine;
using System.Collections;
using GameFramework;



public class SceneMain : SceneBase {


    string[] m_resList = {
         "UI/PanelMain/prefab",
         "UI/PanelDialog/prefab",
                         };

    public override string[] getResList()
    {
        return m_resList;
    }


	public override void onEnter ()
	{
        Tools.Log("enter SceneMain.");
        
        //addEventCallback(EventId.MSG_GAME_OVER, onGameOver);
        startProcMsg();

        PanelMain.open();
        //EventDispatcher.getInstance().dispatchEvent(EventId.UI_CLOSE_LOADING);
	}


    void onStartGame(GameEvent e)
    {
        Tools.Log("Game Start");
        MgrPanel.disposeAllPanel(MgrPanel.LAYER_UI);
    }



    public override void onLeave()
    {
        stopProcMsg();
	}
}
