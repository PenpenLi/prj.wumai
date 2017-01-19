using UnityEngine;
using System.Collections;

public class PanelBattle : PanelBase {

    public override string getAssetBundleName()
    {
        return "UI/PanelBattle/prefab";
    }


    public override int getLayer()
    {
        return MgrPanel.LAYER_DIALOG;
    }


    public override int getStyle()
    {
        return MgrPanel.STYLE_FULL;
    }


    public override void onBuild(object arguments)
    {
        UITools.addButtonClickListener(transform.FindChild("BtnClose"), onClickClose);
    }


    void onClickClose()
    {
        close();
        MgrScene.openNextScene(new SceneMain());
    }
}
