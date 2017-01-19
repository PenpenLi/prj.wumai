using UnityEngine;
using System.Collections;
using GameFramework;


public class SceneBattle : SceneBase
{
    public override void onEnter()
    {
        Tools.Log("enter SceneBattle.");

        //addEventCallback(EventId.MSG_GAME_OVER, onGameOver);
        startProcMsg();

        //PanelMain.open();
        new PanelBattle();
        EventDispatcher.getInstance().dispatchEvent(EventId.UI_CLOSE_LOADING);
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
