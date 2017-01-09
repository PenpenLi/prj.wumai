using UnityEngine;
using System.Collections;
using EventSystem;


public abstract class PanelBase : EventHandler {

    protected GameObject gameObject = null;
    protected RectTransform transform = null;

    public abstract string getResName();

    public abstract void onBuild(Hashtable param);
    
    public abstract int getLayer();

    public abstract int getStyle();

    public abstract void clean();


    public PanelBase()
    {
        gameObject = MgrRes.newObject(getResName()) as GameObject;
        transform = gameObject.transform as RectTransform;
    }


    public void setParam(Hashtable param)
    {
        onBuild(param);
    }


    public void setParent(Transform parent)
    {
        transform.SetParent(parent, false);
    }


    public virtual void show()
    {
        gameObject.SetActive(true);
    }


    public virtual void hide()
    {
        gameObject.SetActive(false);
    }


    public void close()
    {
        MgrPanel.closePanel(this);
        dispose();
    }


    public void dispose()
    {
        GameObject.Destroy(gameObject);
        stopProcMsg();
        clean();
    }

}
