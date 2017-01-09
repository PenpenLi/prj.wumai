using UnityEngine;
using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.UI;

namespace LuaFramework {
    public class LuaBehaviour : View {
		public static bool initialize = false;
        private string data = null;
        private Dictionary<string, LuaFunction> buttons = new Dictionary<string, LuaFunction>();
        public LuaTable luaTableObject = null;

		private LuaFunction updateFun = null;
		private LuaFunction fixedUpdateFun = null;
		private LuaFunction lateUpdateFun = null;
		private LuaFunction appFocusFun = null;

		private LuaFunction colliderFun = null;
        private LuaFunction funcTrgExit = null; 

        // 添加碰撞检测方法
        protected LuaFunction funcCollider = null;


        protected void Awake() {
			// 在调用在onInit之前,所有将awark回调放在OnInit中
			// CallMethod("Awake", gameObject);
        }


        protected void Start() {
			CallMethod("Start");
		}

        protected void OnDisable(){
            if ( !initialize || luaTableObject == null ) return;
            CallMethod("OnDisable");
        }

        protected void OnEnable(){
            if ( !initialize || luaTableObject == null ) return;
            CallMethod("OnEnable");
        }

		
        protected void OnClick() {
			CallMethod("OnClick");
		}

		
        protected void OnClickEvent(GameObject go) {
			CallMethod("OnClick", go);
		}


        protected void Update(){
			if ( !initialize || luaTableObject == null || updateFun == null ) return;
			CallLuaFunction( updateFun, luaTableObject );
        }
        

        protected void FixedUpdate(){
			if ( !initialize || luaTableObject == null || fixedUpdateFun == null ) return;
			CallLuaFunction( fixedUpdateFun, luaTableObject );
        }

        
        protected void LateUpdate(){
            if ( !initialize || luaTableObject == null || lateUpdateFun == null )return;
			CallLuaFunction( lateUpdateFun, luaTableObject );
        }

		protected void OnTriggerEnter(Collider c){
			if ( !initialize || luaTableObject == null || colliderFun == null )return;
			CallLuaFunction( colliderFun, luaTableObject , c);
		}

        protected void OnTriggerExit(Collider target)
        {
            if (!initialize || luaTableObject == null || funcTrgExit == null) return;
            CallLuaFunction(funcTrgExit, luaTableObject, target);
        }


		protected void OnApplicationFocus(bool focus){
			if (!initialize || luaTableObject == null || appFocusFun == null) return;
			CallLuaFunction(appFocusFun, luaTableObject, focus);
		}

        /// <summary>
        /// 碰撞回调
        /// </summary>
        /// <param name="occur">发生碰撞的对象</param>
        /// <param name="source">该物体属于谁</param>
        protected void OnOccurCollider(Transform occur, Transform source)
        {
            if (!initialize || luaTableObject == null || funcCollider == null) return;
            CallLuaFunction(funcCollider, luaTableObject, occur, source);
        }

        /// <summary>
        /// 初始化面板
        /// </summary>
        public void OnInit( LuaTable luatable, string text = null ) {
            this.data = text;   //初始化附加参数

            if ( luatable != null ) {
				setLuaScript( luatable );
            }

//            Debug.Log("OnInit---->>>" + name + " text:>" + text);

			if (LuaManager != null && initialize && luaTableObject != null) {
				// LuaState l = LuaManager.lua;
				// l[ name + ".transform"] = transform;
				// l[ name + ".gameObject"] ]= gameObject;
				luaTableObject[ "transform" ] = transform;
				luaTableObject[ "gameObject" ] = gameObject;

				updateFun = ( LuaFunction )luaTableObject[ "Update" ];
				fixedUpdateFun = ( LuaFunction )luaTableObject[ "FixedUpdate" ];
				lateUpdateFun = ( LuaFunction )luaTableObject[ "LateUpdate" ];
				colliderFun = ( LuaFunction )luaTableObject[ "OnTriggerEnter" ];
                funcTrgExit = (LuaFunction)luaTableObject["OnTriggerExit"];
				appFocusFun = (LuaFunction)luaTableObject["OnApplicationFocus"];


                // 碰撞时候的方法回调
                funcCollider = (LuaFunction)luaTableObject["OnOccurCollider"];
			}

			CallMethod("Awake");
        }

        /// <summary>
        /// 添加单击事件
        /// </summary>
        public void AddClick(GameObject go, LuaFunction luafunc) {
            if (go == null || luafunc == null) return;
            buttons.Add(go.name, luafunc);
            go.GetComponent<Button>().onClick.AddListener(
                delegate() {
                    luafunc.Call(go);
                }
            );
        }

        /// <summary>
        /// 删除单击事件
        /// </summary>
        /// <param name="go"></param>
        public void RemoveClick(GameObject go) {
            if (go == null) return;
            LuaFunction luafunc = null;
            if (buttons.TryGetValue(go.name, out luafunc)) {
                luafunc.Dispose();
                luafunc = null;
                buttons.Remove(go.name);
            }
        }

        /// <summary>
        /// 清除单击事件
        /// </summary>
        public void ClearClick() {
            foreach (var de in buttons) {
                if (de.Value != null) {
                    de.Value.Dispose();
                }
            }
            buttons.Clear();
        }

        ///<summary>
        /// 设置lua脚本 table
        ///</summary>
		public void setLuaScript( LuaTable luaTable){
			this.luaTableObject = luaTable;
		}

        public LuaTable getLuaScript(){
            return this.luaTableObject;
        }


        /// <summary>
        /// 执行Lua方法
        /// </summary>
        protected object[] CallMethod(string func, params object[] args) {
            if (!initialize) return null;
			if (luaTableObject == null ) {
				return Util.CallMethod(name, func, args);
			}
            
			// 这个地方的传参有bug
			return CallMethodLuaTable( func, luaTableObject, args );
		}

		protected object[] CallMethodLuaTable( string func, params object[] args ){
			LuaFunction luaFunc = ( LuaFunction)luaTableObject[ func ];
			if (luaFunc != null) {
				return luaFunc.Call (args);
			}
			return null;
        }


		protected static object[] CallLuaFunction( LuaFunction func, params object[] args ){
			return func.Call( args );
		}


        //-----------------------------------------------------------------
        protected void OnDestroy() {
			CallMethod( "OnDestroy" );
            ClearClick();
			// LuaManager = null;
            luaTableObject = null;
#if ASYNC_MODE
            // string abName = name.ToLower().Replace("panel", "");
            // ResManager.UnloadAssetBundle(abName + AppConst.ExtName);
#endif
            //Util.ClearMemory();
            //Debug.Log("~" + name + " was destroy!");
        }
    }
}