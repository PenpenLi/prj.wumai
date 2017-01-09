using UnityEngine;
using System.Collections;
using System.Collections.Generic;

using UnityEngine.Events;

using Global;




public class MgrPanel : EventBehaviour
{

    /****************************** 应用扩展 start ********************************/



    public static void openDialog(string text, UnityAction onYes = null, UnityAction onNo = null)
    {
        Hashtable data = new Hashtable();
        if (onYes != null)
            data["onYes"] = onYes;
        if (onNo != null)
            data["onNo"] = onNo;
   
        data["text"] = text;
        openPanel( new PanelDialog(), data);
    }


    public static void openLoading()
    {
        openPanel(PanelLoading.getInstance());
    }


    public static void openMain()
    {
        openPanel(PanelMain.getInstance());
    }


    public static void openDebugInfo()
    {
        //openPanel(PanelDebugInfo.getInstance());
    }



    public static void openOption(List<string> options, CallbackWithParam callback)
    {
        Hashtable param = new Hashtable();
        param["options"] = options;
        param["callback"] = callback;

        openPanel(new PanelOption(), param);
    }


    public static void openInput(string title, CallbackWithParam callback, string tip = "")
    {
        Hashtable param = new Hashtable();
        param["title"] = title;
        param["tip"] = tip;
        param["callback"] = callback;

        openPanel(new PanelInput(), param);
    }






















    /****************************** 应用扩展 end ********************************/
























	// Update is called once per frame
    //void Update () {}


    //panel类型
    public const int STYLE_COMMON = 1; 	// 通用类型
    public const int STYLE_FULL = 2; 	// 全屏类型
    public const int STYLE_DIALOG = 3; 	// 对话框类型


    //panel层级
    public const int LAYER_BOTTOM = 0;
    public const int LAYER_UI = 1;
    public const int LAYER_DIALOG = 2;
    public const int LAYER_TIP = 3;
    public const int LAYER_TOP = 4;


    private static GameObject m_canvas;

    private static List<List<PanelBase>> m_view_stack = new List<List<PanelBase>>();

    private static List<Transform> m_layerNode = new List<Transform>();

    void Awake()
    {
        getCanvas();
        for (int i = 0; i <= 4; i++)
        {
            m_view_stack.Add(new List<PanelBase>());
        }
    }


    public override void onDestory()
    {
        disposeAllPanel();
    }


    public static GameObject getCanvas()
    {
        if (m_canvas == null)
        {
            m_canvas = GameObject.Find("UIRoot/Canvas");
            initLayers(m_canvas);
        }

        return m_canvas;
    }


    public static void initLayers(GameObject canvas)
    {
        RectTransform layerTemplate = canvas.transform.FindChild("LayerNode") as RectTransform;
        for (int i = 0; i <= 4; i++)
        {
            var node = GameObject.Instantiate(layerTemplate);
            node.name = "Layer" + i;
            node.SetParent(canvas.transform);
            node.offsetMin = Vector2.zero;
            node.offsetMax = Vector2.zero;
            node.localScale = Vector2.one;
            node.gameObject.SetActive(true);

            m_layerNode.Add(node);
        }
    }


    static Transform getLayerNode(int layer)
    {
        return m_layerNode[layer];
    }


    static void pushStack(PanelBase panel, int layer)
    {
        var stack = m_view_stack[layer];
        stack.Add(panel);
    }


    static PanelBase popStack(int layer)
    {
        var stack = m_view_stack[layer];
        int idx = stack.Count - 1;
        if (idx < 0)
        {
            return null;
        }
        else
        {
            PanelBase p = stack[idx];
            stack.RemoveAt(idx);
            return p;
        }
    }


    static PanelBase peekStack(int layer)
    {
        var stack = m_view_stack[layer];
        int idx = stack.Count - 1;
        if (idx < 0)
        {
            return null;
        }
        else
        {
            return stack[idx];
        }
    }


    static void removePanel(PanelBase panel)
    {
        var stack = m_view_stack[panel.getLayer()];
        stack.Remove(panel);
    }


    static void removeAndDispose(PanelBase panel)
    {
        removePanel(panel);
        panel.dispose();
    }



    public static void closePanel(PanelBase panel)
    {
        int layer = panel.getLayer();
        var curPanel = peekStack(layer);
        if (curPanel == panel)
        {
            removeAndDispose(panel);
            //是最上面的面板则pop掉
            curPanel = peekStack(layer);
            if (curPanel != null)
                curPanel.show();
        }
        else
        {
            //没有在最上面则直接移除销毁
            removeAndDispose(panel);
        }
    }


    static void openPanel(PanelBase panel, Hashtable param = null)
    {
        panel.setParam(param);
        addPanel(panel);
    }


    static void addPanel(PanelBase panel)
    {
        if (findPanel(panel))
        {
            removePanel(panel);
            panel.show();
        }

        int layer = panel.getLayer();
        int style = panel.getStyle();
        var topPanel = peekStack(layer);

        if (topPanel != null)
        {
            if (topPanel.getStyle() == STYLE_COMMON)
            {
                // do nothing
            }
            else if (topPanel.getStyle() == style)
            {
                topPanel.hide();
            }
            else if (style == STYLE_FULL)
            {
                topPanel.hide();
            }
        }

        pushStack(panel, layer);
        panel.setParent(getLayerNode(layer));
        panel.show();
    }


    // 暂不支持
    public static bool findPanel(PanelBase panel)
    {
        var stack = m_view_stack[panel.getLayer()];
        foreach (var p in stack)
        {
            if(p == panel)
                return true;
        }

        return false;
    }


    public static void disposeAllPanel(int layer = -1)
    {
        if (layer == -1)
        {
            for (int i = 0; i < m_view_stack.Count; i++)
            {
                disposeAllPanel(i);
            }
        }
        else
        {
            var stack = m_view_stack[layer];
            foreach (var panel in stack)
            {
                panel.dispose();
            }

            stack.Clear();
        }

        
    }







}
