using UnityEngine;
using System.Collections;
using EventSystem;



public abstract class SceneBase : EventHandler {


	public virtual void onEnter(){
		
	}


	public virtual void onLeave(){
        stopProcMsg();
	}
}
