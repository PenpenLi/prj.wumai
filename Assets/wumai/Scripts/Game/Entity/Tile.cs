using UnityEngine;
using UnityEngine.UI;


public class Tile : GameUnit
{

    public override string getAssetBundleName()
    {
        return "Map/Tile/prefab";
    }



    public Tile(int level) : base(level) { }


    private SpriteRenderer m_spriteRenderer;
    public int level = 0;

    public override void onCreate(object arguments)
    {
        int level = (int)arguments;

        m_spriteRenderer = transform.GetComponent<SpriteRenderer>();

        if (level != 1)
        {
            UITools.setSpriteForContainer(m_spriteRenderer, "Image/tile" + level, this);
        }

        this.level = level;
    }
}
