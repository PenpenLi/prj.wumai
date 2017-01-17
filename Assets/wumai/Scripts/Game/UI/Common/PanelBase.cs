using UnityEngine;
using System.Collections;
using GameFramework;


public abstract class PanelBase : ResObject {


    
    public abstract int getLayer();

    public abstract int getStyle();

    public abstract void onBuild(object arguments);


    public PanelBase() : base(null, null) { }


    public PanelBase(object arguments):base(arguments, null)
    {
    }


    public override void onCreate(object arguments)
    {
        MgrPanel.addPanel(this);
        onBuild(arguments);
    }


    public void close()
    {
        MgrPanel.closePanel(this);
        dispose();
    }


    public override void dispose()
    {
        base.dispose();
        GameObject.Destroy(gameObject);
    }

}
