using UnityEngine;
using System.Collections;
using GameFramework;


public abstract class PanelBase : ResObject {


    
    public abstract int getLayer();

    public abstract int getStyle();



    public PanelBase() : base(null, null) { }


    public PanelBase(object arguments):base(arguments, null)
    {
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
