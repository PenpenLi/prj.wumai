/*
 * Created by SharpDevelop.
 * User: LDW
 * Date: 2016/4/14
 * Time: 15:55
 * 
 * 本类配合 ULUnityBridge.java 工作，提供给lua调用
 */

using UnityEngine;
using LuaInterface;
using System.Runtime.InteropServices;


public class ULNativeBridge : MonoBehaviour {

	// 对象名
	public const string NAME = "NativeBridge";
	
	// 回调方法名
	const string CALLBACK_NAME = "OnResult";
	
	

#if UNITY_ANDROID
	// java 连接对象
	static AndroidJavaClass ulUnityBridge;

	// java 连接类名
	const string NAME_UNITY_BRIDGE_CLASS = "com.ultralisk.common.ULUnityBridge";

    // 设置方法名
    const string NAME_SETTER_NAME = "setReceiver";

	// java消息接受方法
	const string NAME_NOTIFY_FUNC = "receiveFromUnity";

#elif UNITY_IPHONE && !UNITY_EDITOR
	[DllImport("__Internal")] 
	private static extern void setReceiver(string unityObjName, string callbackName );

	[DllImport("__Internal")] 
	private static extern void receiveFromUnity(string jsonStr);
#endif


    // lua监听
	delegate void LuaCallback (string data);
	static LuaCallback luaCallback;


    protected void Awake()
    {
        name = NAME;
    }
	
	
	public static void Init( LuaFunction onResult ) {
#if UNITY_ANDROID
		if( ulUnityBridge != null ){
			Debug.LogError( "duplicate create ulUnityBridge." );
			ulUnityBridge.Dispose();
		}
		
		ulUnityBridge = new AndroidJavaClass( NAME_UNITY_BRIDGE_CLASS );
		ulUnityBridge.CallStatic( NAME_SETTER_NAME, NAME, CALLBACK_NAME );
		
#elif UNITY_IPHONE && !UNITY_EDITOR
        setReceiver( NAME, CALLBACK_NAME );
#else
        return;
#endif

        luaCallback = data => onResult.Call(data);

        Debug.Log("ULNativeBridge inited.");
    }
	
	
	public static void SendToSdk( string param ){
#if UNITY_ANDROID
		if(ulUnityBridge != null){
			ulUnityBridge.CallStatic(NAME_NOTIFY_FUNC, param);
		} else
			Debug.LogWarning("ULNativeBridge: CSharpBridge is null.");
#elif UNITY_IPHONE && !UNITY_EDITOR
		receiveFromUnity(param);
#endif
	}
	
	
	public void OnResult(string data){
		if(luaCallback != null){
//			Debug.Log("ULNativeBridge.OnResult: " + data);
			luaCallback(data);
		} else
			Debug.LogWarning("ULNativeBridge: onResult is null");
	}
	
}




