using System;
using System.Collections.Generic;



namespace EventSystem
{
    public class GameEvent
    {

        private object m_data = null;
        private bool m_stop = false;

        public GameEvent()
        {
        }

        public GameEvent(object data)
        {
            m_data = data;
        }


        public void stop()
        {
            m_stop = true;
        }


        public bool bStop()
        {
            return m_stop;
        }


        public object getData()
        {
            return m_data;
        }

    }


    public delegate void OnEvent(GameEvent e);


    public class EventListener
    {
        private OnEvent m_callback;

        private bool m_stop = false;
        private bool m_pause = false;

        public EventListener(OnEvent callback)
        {
            m_callback = callback;
        }


        public void onEvent(GameEvent e)
        {
            m_callback(e);
        }


        public void stop()
        {
            m_stop = true;
            m_callback = null;
        }


        public bool bStop()
        {
            return m_stop;
        }


        public void pause()
        {
            m_pause = true;
        }


        public void resume()
        {
            m_pause = false;
        }


        public bool bPause()
        {
            return m_pause;
        }
    }



    public class EventHandler
    {

        private Dictionary<EventId, EventListener> m_events = new Dictionary<EventId, EventListener>();

        public void addEventCallback(EventId eventId, OnEvent callback)
        {
            if (!m_events.ContainsKey(eventId))
            {
                EventListener listener = new EventListener(callback);
                m_events.Add(eventId, listener);
            }
            else
            {
                Tools.LogWarn("event callback is exsits." + eventId);
            }
        }


        public void startProcMsg()
        {
            //m_events.forEach((eid, l)->{
            //    EventDispatcher.getGlobalInstance().addListener(eid, l);
            //});
            foreach (var pair in m_events)
            {
                EventDispatcher.getGlobalInstance().addListener(pair.Key, pair.Value);
            }
        }


        public void stopProcMsg()
        {
            foreach (var l in m_events.Values)
            {
                l.stop();
            }

            // stop之后无法重新start(尚未解决多线程问题)
            m_events.Clear();
        }

    }



    /**
 * 
 * 这个类是有问题的，并非线程安全，目前只对ui Event上锁
 * 
 * 在多线程下add和dispatch可能出现未知bug
 * 
 */
    public class EventDispatcher
    {

        private static EventDispatcher inst = new EventDispatcher();
        public static EventDispatcher getGlobalInstance()
        {
            return inst;
        }



        private Dictionary<EventId, LinkedList<EventListener>> allListeners = new Dictionary<EventId, LinkedList<EventListener>>();



        public EventDispatcher(){}


        public void addListener(EventId eid, EventListener listener)
        {
            if (!checkListener(eid, listener))
            {
                allListeners[eid].AddLast(listener);
            }
            else
            {
                Tools.LogError("Alread has EventListener in Event:[" + eid + "]." + " listener:[" + listener.ToString() + "].");
            }
        }


        private bool checkListener(EventId eid, EventListener listener)
        {
            if (allListeners.ContainsKey(eid))
            {
                var list = allListeners[eid];
                return list.Contains(listener);
            }
            else
            {
                allListeners.Add(eid, new LinkedList<EventListener>());
            }

            return false;
        }


        /**
         * 先添加的会先收到消息
         */
        public void dispatchEvent(EventId eid, object data = null)
        {
            if (!allListeners.ContainsKey(eid))
            {
                Tools.LogWarn("can't find event:" + eid.ToString());
                return;
            }
            var listeners = allListeners[eid];

            var e = new GameEvent(data);

            var node = listeners.First;
            while (node != null)
            {
                var listener = node.Value;
                if (listener.bStop())
                {
                    var next = node.Next;
                    listeners.Remove(node);
                    node = next;
                    continue;
                }

                listener.onEvent(e);
                if (e.bStop())
                    break;

                node = node.Next;
            }
        }


        public class UiEvent
        {
            public EventId eid;
            public object data;
            public UiEvent(EventId eid, object data)
            {
                this.eid = eid;
                this.data = data;
            }
        }

        private LinkedList<UiEvent> m_uiEvent = new LinkedList<UiEvent>();
        /**
         * 放入下一帧处理(放入主线)
         */
        public void dispatchUiEvent(EventId eid, object data = null)
        {
            lock (m_uiEvent)
            {
                m_uiEvent.AddLast(new UiEvent(eid, data));
            }
        }


        public void procUiEvent()
        {
            lock (m_uiEvent)
            {
                var node = m_uiEvent.First;
                LinkedListNode<UiEvent> next;
                UiEvent e;
                while (node != null)
                {
                    next = node.Next;
                    e = node.Value;

                    m_uiEvent.Remove(node);
                    node = next;

                    dispatchEvent(e.eid, e.data);
                }
            }
        }


        public void removeAllUnused()
        {
            foreach (var ls in allListeners.Values)
            {
                var node = ls.First;
                while (node != null)
                {
                    if (node.Value.bStop())
                    {
                        var next = node.Next;
                        ls.Remove(node);
                        node = next;
                    }
                    else
                    {
                        node = node.Next;
                    }
                }
            }

            m_uiEvent.Clear();
        }


    }
}


