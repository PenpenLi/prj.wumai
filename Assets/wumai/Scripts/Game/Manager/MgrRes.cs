using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UObject = UnityEngine.Object;

public class MgrRes
{

    public static UObject getObject(string resName)
    {
        UObject go = Resources.Load<UObject>("Prefab/" + resName);
        return go;
    }


    public static UObject newObject(string resName)
    {
        return GameObject.Instantiate(getObject(resName));
    }
}
