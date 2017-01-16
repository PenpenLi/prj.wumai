using UnityEngine;
using System.Collections;
using GameFramework;



public abstract class SceneBase : EventHandler {


	public virtual void onEnter(){
		
	}


	public virtual void onLeave(){
        stopProcMsg();
	}
}
