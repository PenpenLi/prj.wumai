using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;



public class ULTweenDirector : MonoBehaviour {



    public GameObject m_actor = null;


    TweenPosition m_tPosition;
    TweenRotation m_tRotation;


    List<Command> m_commands = new List<Command>();

    Action m_onMoveCallback;
    Action m_onRotateCallback;


	bool m_bInit = false;
	bool m_bMoving = false;
	bool m_bRotating = false;

	// Use this for initialization
	void Start () {
        //if (m_actor == null)
        //    m_actor = gameObject;

        //m_tPosition = TweenPosition.Begin(m_actor, 0f, m_actor.transform.position, true);
        //m_tPosition.tweenGroup = 1;
        //m_tRotation = TweenRotation.Begin(m_actor, 0, m_actor.transform.localRotation);
        //m_tRotation.tweenGroup = 1;

        //m_player = m_actor.GetComponent<UIPlayTween>();
        //if (m_player == null)
        //    m_player = m_actor.AddComponent<UIPlayTween>();

        //m_player.onAllFinished = OnFinished;
	}


	public void Init()
	{
		if (m_actor == null)
			m_actor = gameObject;
		
		m_tPosition = TweenPosition.Begin(m_actor, 0f, m_actor.transform.localPosition);
		m_tPosition.OnFinished = onMoveFinished;

		m_tRotation = TweenRotation.Begin(m_actor, 0, m_actor.transform.localRotation);
		m_tRotation.OnFinished = onRotateFinished;

		m_bInit = true;
	}


    public void Init(Vector3 pos, Vector3 rot)
    {
        if (m_actor == null)
            m_actor = gameObject;

        m_actor.transform.localPosition = pos;
        m_actor.transform.localRotation = Quaternion.Euler(rot);

		Init();
    }


    void onMoveFinished()
    {
		if(m_onMoveCallback != null){
			m_onMoveCallback.Invoke();
		}

		doNextTween(Command.TYPE_POSITION);
    }


    void onRotateFinished()
    {
		if(m_onRotateCallback != null){
			m_onRotateCallback.Invoke();
		}
		
		doNextTween(Command.TYPE_ROTATION);
    }


	void doNextTween(int type)
    {
		Command info = null;
		for(int i = 0; i < m_commands.Count; i++){
			if(m_commands[i].type == type){
				info = m_commands[i];
				m_commands.RemoveAt(i);
				break;
			}
		}

		if(info == null){
			if(type == Command.TYPE_POSITION)
				m_bMoving = false;
			else if(type == Command.TYPE_ROTATION)
				m_bRotating = false;
			return;
		}

		if (info.type == Command.TYPE_POSITION)
        {
			m_tPosition.from = m_actor.transform.localPosition;
            m_tPosition.to = info.value;
			m_tPosition.delay = info.delay;
			m_tPosition.duration = info.duration;
			m_tPosition.method = info.method;
			m_onMoveCallback = info.callback;
			m_tPosition.ResetToBeginning();
            m_tPosition.Play(true);
			m_bMoving = true;
        }
        else if (info.type == Command.TYPE_ROTATION)
        {
			m_tRotation.from = m_actor.transform.localRotation.eulerAngles;
            m_tRotation.to = info.value;
			m_tRotation.delay = info.delay;
			m_tRotation.duration = info.duration;
			m_tRotation.method = info.method;
			m_onRotateCallback = info.callback;
			m_tRotation.ResetToBeginning();
			m_tRotation.Play(true);
			m_bRotating = true;
        }
        else
        {
            Debug.LogError("Next Info Type:" + info.type);
			doNextTween(type);
            return;
        }
    }


    // Update is called once per frame
    void Update()
    {
	}


	public void AddNextPosition(Vector3 pos, float delay, float duration, LuaFunction callback)
	{
		AddNextInfo(pos, delay, duration, Command.TYPE_POSITION, callback, UITweener.Method.Linear);
	}


	public void AddNextPosition(Vector3 pos, float delay, float duration, LuaFunction callback, UITweener.Method method)
    {
		AddNextInfo(pos, delay, duration, Command.TYPE_POSITION, callback, method);
    }


	public void AddNextRotation(Vector3 rot, float delay, float duration, LuaFunction callback)
	{
		AddNextInfo(rot, delay, duration, Command.TYPE_ROTATION, callback, UITweener.Method.Linear);
	}


	public void AddNextRotation(Vector3 rot, float delay, float duration, LuaFunction callback, UITweener.Method method)
    {
		AddNextInfo(rot, delay, duration, Command.TYPE_ROTATION, callback, method);
    }


	void AddNextInfo(Vector3 value, float delay, float duration, int type, LuaFunction callback, UITweener.Method method)
    {
		Action action = null;
		if(callback != null)
			action = ()=>{
				callback.Call();
			};

		var info = new Command(value, delay, duration, type, action, method);
        m_commands.Add(info);
    }


    public void Play()
    {
		if(!m_bInit)
			return;
		
		if(!m_bMoving)
			doNextTween(Command.TYPE_POSITION);
		if(!m_bRotating)
			doNextTween(Command.TYPE_ROTATION);
    }


    public void Clear()
    {
        m_commands.Clear();
    }




    class Command
    {
        public const int TYPE_POSITION = 0;
        public const int TYPE_ROTATION = 1;

        public Vector3 value;
        public float delay;
		public float duration;
        public Action callback;
        public int type;
		public UITweener.Method method;

		public Command(Vector3 value, float delay, float duration, int type, Action callback, UITweener.Method method)
        {
            this.value = value;
			this.delay = delay;
			this.duration = duration;
            this.type = type;
			this.method = method;
            this.callback = callback;
        }
    }
}
