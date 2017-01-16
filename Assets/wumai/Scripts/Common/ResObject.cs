using UnityEngine;
using UObject = UnityEngine.Object;
using SObject = System.Object;
using System;


public abstract class ResObject {


    protected GameObject gameObject = null;
    protected Transform transform = null;


    private SObject m_arguments;

    private bool bInited = false;
    private bool bDisposed = false;


    public ResObject():this(null, null){}


    public ResObject(SObject arguments, Action<ResObject> callback)
    {
        m_arguments = arguments;
        //m_callback = callback;
        MgrRes.loadPrefab(getAssetBundleName(), null, onLoadPrefab);
    }


    public abstract string getAssetBundleName();


    void onLoadPrefab(UObject obj)
    {
        if (bDisposed)
        {
            MgrRes.putPrefab(getAssetBundleName(), null);
            return;
        }

        gameObject = UObject.Instantiate(obj) as GameObject;
        transform = gameObject.transform;
        bInited = true;

        onCreate(m_arguments);
    }


    public abstract void onCreate(SObject arguments);


    public bool isInited()
    {
        return bInited;
    }


    public bool isDisposed()
    {
        return bDisposed;
    }


    public virtual void dispose()
    {
        bDisposed = true;

        if (bInited)
        {
            UObject.Destroy(gameObject);
            gameObject = null;
            transform = null;
            m_arguments = null;
            MgrRes.putPrefab(getAssetBundleName(), null);
            bInited = false;
        }
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
}
