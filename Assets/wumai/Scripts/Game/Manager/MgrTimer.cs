using UnityEngine;
using Global;
using System.Collections.Generic;
using System;
using EventSystem;


public class MgrTimer : EventBehaviour
{


    class TimerEvent
    {
        public long endTime = 0;
        public CallbackWithParam callback = null;
        public object param = null;

        public TimerEvent(long endTime, CallbackWithParam callback, object param = null)
        {
            this.endTime = endTime;
            this.callback = callback;
            this.param = param;
        }
    }


    static LinkedList<TimerEvent> m_list = new LinkedList<TimerEvent>();



	void Start () {
	}


    public override void onDestory()
    {
        m_list.Clear();
    }


	
	void Update()
    {
        try
        {
            EventDispatcher.getGlobalInstance().procUiEvent();
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
        m_list.AddLast(new TimerEvent(time + Tools.getCurTime(), callback, param));
    }
}

