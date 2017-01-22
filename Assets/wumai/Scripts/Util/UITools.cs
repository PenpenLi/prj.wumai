using UnityEngine;
using UnityEngine.UI;
using System.Collections;


public class UITools
{
    public static void addButtonClickListener(Transform tr, UnityEngine.Events.UnityAction click)
    {
        tr.GetComponent<Button>().onClick.AddListener(click);
    }


    // 由于异步加载，暂时只支持包含从ResObject来的sprite替换，以判断transform是否还有效
    public static void setSpriteForContainer(Image img, string spriteName, ResObject container)
    {
        if (img == null || container == null || container.isDisposed()) return;
        var objs = spriteName.Split('/');
        MgrRes.loadPrefab(objs[0], objs[1], obj =>
        {
            if (container.isDisposed())
                return;

            img.sprite = obj as Sprite;
        }, true);
    }


    public static void setSpriteForContainer(SpriteRenderer render, string spriteName, ResObject container)
    {
        if (render == null || container == null || container.isDisposed()) return;
        var objs = spriteName.Split('/');
        MgrRes.loadPrefab(objs[0], objs[1], obj =>
        {
            if (container.isDisposed())
                return;

            render.sprite = obj as Sprite;
        }, true);
    }
}
