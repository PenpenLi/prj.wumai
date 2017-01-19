using UnityEngine;
using System.Collections;

public class Tile : GameUnit
{

    public override string getAssetBundleName()
    {
        return "Map/Tile/prefab";
    }


    public override void onCreate(object arguments)
    {
    }
}
