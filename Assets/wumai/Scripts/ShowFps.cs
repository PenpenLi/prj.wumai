using UnityEngine;
using System.Collections;

public class ShowFps : MonoBehaviour {
	
	public float f_UpdateInterval = 0.5F;
	
	private float f_LastInterval;
	
	private int i_Frames = 0;
	
	private float f_Fps;
	public static string str = "";
	void Start()
	{
		//Application.targetFrameRate=60;
		f_LastInterval = Time.realtimeSinceStartup;
		
		i_Frames = 0;
	}
	
	void OnGUI()
	{
		if(true)
		{
			GUI.color = Color.red;
			GUIStyle style = new GUIStyle ();
			style.fontSize = 20;
			style.normal.textColor = Color.red;
			if(str != "")
			{
				GUI.Label(new Rect(0, 0, 400, 400), "FPS:" + str, style);
			}
			else
			{
				GUI.Label(new Rect(0, 0, 400, 400), "FPS:" + f_Fps.ToString("f2"), style);
			}
		}
	}
	
	void Update()
	{
		if(true)
		{
			++i_Frames;			
			if (Time.realtimeSinceStartup > f_LastInterval + f_UpdateInterval)
			{
				f_Fps = i_Frames / (Time.realtimeSinceStartup - f_LastInterval);
				
				i_Frames = 0;
				
				f_LastInterval = Time.realtimeSinceStartup;
			}
		}
	}
}
