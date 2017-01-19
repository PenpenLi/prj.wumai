using UnityEngine;
using System.Collections;



public class GameMap : GameUnit {

    public override string getAssetBundleName()
    {
        return "Map/Map/prefab";
    }


    private Camera m_camera;
    public override void onCreate(object arguments)
    {
        m_camera = transform.FindChild("Camera").GetComponent<Camera>();
    }
}
