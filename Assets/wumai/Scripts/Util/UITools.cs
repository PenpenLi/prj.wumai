using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System;


public class UITools
{
    public static void addButtonClickListener(Transform tr, UnityEngine.Events.UnityAction click)
    {
        tr.GetComponent<Button>().onClick.AddListener(click);
    }
}
