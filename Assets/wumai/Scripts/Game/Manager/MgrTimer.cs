using UnityEngine;
using Global;
using System.Collections.Generic;
using System;
using GameFramework;


public class MgrTimer : EventBehaviour
{


    class TimerNode
    {
        public long endTime = 0;
        public CallbackWithParam callback = null;
        public object param = null;

        public int times = 0;


        public TimerNode(long endTime, CallbackWithParam callback, object param = null)
        {
            this.endTime = endTime;
            this.callback = callback;
            this.param = param;
        }
    }


    class TimerLoopNode
    {
        public long endTime = 0;
        public CallbackWithParam callback = null;
        public object param = null;
        public int delta = 0;
        public int times = 0;


        public TimerLoopNode(int delta, int times, CallbackWithParam callback, object param = null)
        {
            this.delta = delta;
            this.times = times;
            this.callback = callback;
            this.param = param;
        }
    }


    static LinkedList<TimerNode> m_list = new LinkedList<TimerNode>();
    static LinkedList<TimerLoopNode> m_loopList = new LinkedList<TimerLoopNode>();



	void Start () {
	}


    public override void OnDestroy()
    {
        base.OnDestroy();
        m_list.Clear();
    }

	
	void Update()
    {
        try
        {
            //EventDispatcher.getInstance().procUiEvent();
            var curTime = Tools.getCurTime();
            var node = m_list.First;

            while (node != null)
            {
                var e = node.Value;
                var next = node.Next;
                if (e.endTime <= curTime)
                {
                    m_list.Remove(node);
                    e.callback(e.param);
                }

                node = next;
            }

            var nodeLoop = m_loopList.First;
            while (nodeLoop != null)
            {
                var e = nodeLoop.Value;
                var next = nodeLoop.Next;
                if (e.endTime <= curTime)
                {
                    e.callback(e.param);

                    if (e.times > 0)
                    {
                        e.times--;
                        e.endTime = curTime + e.delta;
                    }

                    if (e.times == 0)
                    {
                        m_loopList.Remove(nodeLoop);
                    }
                    else if (e.times < 0)
                    {
                        e.endTime = curTime + e.delta;
                    }
                }

                nodeLoop = next;
            }
        }
        catch (Exception e)
        {
            Tools.LogError("MgrTimer:" + e.Message);
            Tools.LogError(e.StackTrace);
        }
	}


    /**
     * time 毫秒
     */
    public static void callLaterTime(int time, CallbackWithParam callback, object param = null)
    {
        m_list.AddLast(new TimerNode(time + Tools.getCurTime(), callback, param));
    }


    public static void callLoopTime(int delta, int times, CallbackWithParam callback, object param = null)
    {
        var node = new TimerLoopNode(delta, times, callback, param);
        node.endTime = delta + Tools.getCurTime();
        m_loopList.AddLast(node);
    }
}

