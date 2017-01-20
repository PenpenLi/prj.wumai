using UnityEngine;
using System.Collections;
using GameFramework;


public class SceneBattle : SceneBase
{
    string[] m_resList = {
         "UI/PanelBattle/prefab",
         "UI/PanelDialog/prefab",
         "Map/Map/prefab",
         "Map/Tile/prefab"
                         };

    public override string[] getResList()
    {
        return m_resList;
    }


    
    GameMap m_gameMap;

    public override void onEnter()
    {
        Tools.Log("enter SceneBattle.");

        //addEventCallback(EventId.MSG_GAME_OVER, onGameOver);
        startProcMsg();

        //PanelMain.open();
        new PanelBattle();
        m_gameMap = new GameMap();
        
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
        m_gameMap.dispose();
    }
}
