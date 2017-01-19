using UnityEngine;
using System.Collections;


/// <summary>
/// 2d 游戏对象，按照Y轴进行排序（Y轴大的将越靠后）
/// </summary>
public abstract class GameUnit : ResObject
{

    public void setPosition(float x, float y)
    {
        Vector3 pos = new Vector3(x, y, y / 100);
        transform.localPosition = pos;
    }


    public void setPosition(float x, float y, float z)
    {
        transform.localPosition = new Vector3(x, y, z);
    }


    public void setPosition(Vector2 pos)
    {
        Vector3 newPos = new Vector3(pos.x, pos.y, pos.y / 100);
        transform.localPosition = newPos;
    }


    public Vector3 getPosition()
    {
        return transform.localPosition;
    }


    public Vector3 getWorldPosition()
    {
        return transform.position;
    }

}
