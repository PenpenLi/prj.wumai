using UnityEngine;
using System.Collections;
using GameFramework;



public class SceneMain : SceneBase {
	public override void onEnter ()
	{
        Tools.Log("enter SceneMain.");
        
        //addEventCallback(EventId.MSG_GAME_OVER, onGameOver);
        startProcMsg();


        PanelMain.open();
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
