using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;
using UnityEditor;
//using UnityEditorInternal;
using UnityEngine;
using UnityEditor.Animations;

public class EBAniData
{

	static public readonly string Path_Assert = Application.dataPath + Path.DirectorySeparatorChar + "AnimJsonData" + Path.DirectorySeparatorChar;

	// 动画层级数据
	static public readonly string JSON_PATH_Layer = Path_Assert + "layers.json";

	// 动画参数数据
	static public readonly string JSON_PATH_Parameters = Path_Assert + "parematers.json";

	// 动画控制器数据
	static public readonly string JSON_PATH_Controls = Path_Assert + "controls.json";
	static public Dictionary<int, EBAniControls> dicControls = new Dictionary<int, EBAniControls> ();

	// 动画状态机数据
	static public readonly string JSON_PATH_States = Path_Assert + "ctrl_acts.json";
	// static public Dictionary<int, EBAniSate> dicStates = new Dictionary<int, EBAniSate> ();

	static public bool isInitData = false;

	static public void initDatas ()
	{
		if (isInitData) {
			return;
		}
		// isInitData = true;

		dicControls.Clear ();

		string json;
		ArrayList list;
		int index;
		int lens;
        
		EBAniLayers layer;
		EBAniParameters parameter;
		EBAniControls controls;


		// 动画层级数据
		Dictionary<int, EBAniLayers> dicLayers = new Dictionary<int, EBAniLayers> ();

		json = File.ReadAllText (JSON_PATH_Layer);
		list = JSON.DecodeList (json);
		lens = list.Count;
		for (index = 0; index < lens; index++) {
			layer = EBAniLayers.parseByMap ((Hashtable)list [index]);
			if (layer.unqid > 0) {
				dicLayers.Add (layer.unqid, layer);
			}
		}

		// 动画参数数据
		Dictionary<int, EBAniParameters> dicParameters = new Dictionary<int, EBAniParameters> ();
		json = File.ReadAllText (JSON_PATH_Parameters);
		list = JSON.DecodeList (json);
		lens = list.Count;
		for (index = 0; index < lens; index++) {
			parameter = EBAniParameters.parseByMap ((Hashtable)list [index]);
			if (parameter.unqid > 0) {
				dicParameters.Add (parameter.unqid, parameter);
			}
		}

		// 动画状态机数据·
		json = File.ReadAllText (JSON_PATH_States);
		//list = JSON.DecodeList (json);
		Hashtable actMap = JSON.DecodeMap (json);
		ArrayList actMapKey = new ArrayList (actMap.Keys);
		lens = actMapKey.Count;

		Dictionary<int, List<EBAniState>> dicActState = new Dictionary<int, List<EBAniState>> ();

		for (index = 0; index < lens; index++) {
			ArrayList aniStateList = (ArrayList)actMap[ actMapKey[index] ];
			int dicKey = int.Parse(actMapKey[index].ToString());
			dicActState [dicKey] = new List<EBAniState> (); 
			for (int i = 0, len = aniStateList.Count; i < len; i++) {
				EBAniState state = EBAniState.parseByMap ((Hashtable)aniStateList [i]);
				state.DescParams (dicParameters);
				dicActState [dicKey].Add (state);
			}

			//EBAniSate state = EBAniSate.parseByMap ((Hashtable)list [index]);
			//			if (state.unqid > 0) {
			//
			//				state.DescParams (dicParameters);
			//
			//				controls = dicControls [state.ctrlUnqid];
			//				if (controls != null) {
			//					controls.listState.Add (state);
			//				}
			//			}
		}

		// ========= 动画控制器数据  很重要的=========
		json = File.ReadAllText (JSON_PATH_Controls);
		list = JSON.DecodeList (json);
		lens = list.Count;
		for (index = 0; index < lens; index++) {
			controls = EBAniControls.parseByMap ((Hashtable)list [index]);
			if (controls.unqid > 0) {
				foreach (int lunqid in controls.layerUnqids) {
					layer = dicLayers [lunqid];
					if (layer != null)
						controls.listLayers.Add (layer);
				}

				foreach (int lunqid in controls.parsUnqids) {
					parameter = dicParameters [lunqid];
					if (parameter != null)
						controls.listParameters.Add (parameter);
				}
				dicControls.Add (controls.unqid, controls);

				controls.listState = dicActState[controls.activeId];
			}
		}


	}

	static public void makeAniCtrlAndPrefab ()
	{
		initDatas ();

		List<EBAniControls> list = new List<EBAniControls> (dicControls.Values);

		int lens = list.Count;
		bool isOkey = true;
		for (int i = 0; i < lens; i++) {
			EBAniControls controls = list [i];
			EditorUtility.DisplayProgressBar ("创建控制器和预制件中", "正在导出 id =" + controls.unqid + ",name=" + controls.name, (float)i / lens);
			try {
				makeOneEBAniCtrlAndFab (controls);
			} catch(Exception e) {
				Debug.LogError (controls.unqid + " " + controls.name);
				Debug.LogError (e.Message);
				isOkey = false;
				break;
			}

	
		}
		EditorUtility.ClearProgressBar ();
		if (isOkey) {
			EditorUtility.DisplayDialog ("完成", "创建完成!!!", "Okey");
		} else {
			EditorUtility.DisplayDialog ("失败", "创建失败!!!", "Okey");
		}

	}

	static void stateClipInList (List<EBAniState> listState, UnityEngine.Object clip)
	{
		if (string.IsNullOrEmpty (clip.name)) {
			return;
		}
		if (listState == null || listState.Count == 0) {
			return;
		}

		int lens = listState.Count;
		EBAniState tmp;
		for (int i = 0; i < lens; i++) {
			tmp = listState [i];
			//TODO 这里需要修改
			if (string.Equals (clip.name, tmp.actName)) {
				tmp.aniClip = (AnimationClip)clip;
			}
		}
	}

	static void relishipClip (UnityEngine.Object[] _objs, EBAniControls controls, EBAniState state)
	{
		int lens = _objs.Length;
		bool isRest = state == null;
 		for (int i = 0; i < lens; i++) {
  			UnityEngine.Object _obj = _objs [i];
 			if (_obj.GetType () == typeof(AnimationClip) && !_obj.name.Contains ("Take 001")) {
				
				if (isRest) {
					stateClipInList (controls.listState, _obj);
				}
					
//				if (state != null) {
//					state.aniClip = (AnimationClip)_obj;
//				} else {
//					Debug.Log (controls.fbxPath + " " + _obj.name);
//				}
			}
		}
	}

	static void makeOneEBAniCtrlAndFab (EBAniControls controls)
	{
		bool isExists = File.Exists (controls.fbxPath);
		if (!isExists) {
			Debug.LogWarning (controls.fbxPath + "不存在！！！");
			return;
		}

		string _fold = Path.GetDirectoryName (controls.fbxPath);
		string _pathAniCtrl = _fold + Path.DirectorySeparatorChar + controls.name + ".controller";

		if (File.Exists (_pathAniCtrl)) {
			File.Delete (_pathAniCtrl);
		}

		//创建animationController文件，保存在Assets路径下
		AnimatorController aniController = AnimatorController.CreateAnimatorControllerAtPath (_pathAniCtrl);

		int lens = 0;

		// =========== layer begin ============
		aniController.RemoveLayer (0);
		lens = controls.listLayers.Count;
        
		Dictionary<string,AvatarMask> mapAvatarMask = new Dictionary<string,AvatarMask> ();
		AvatarMask mask;

		for (int i = 0; i < lens; i++) {
			EBAniLayers tmp = controls.listLayers [i];
			aniController.AddLayer (tmp.name);

			AnimatorControllerLayer aniLayer = aniController.layers [i];
			aniLayer.defaultWeight = tmp.weight;
			if (string.IsNullOrEmpty (tmp.mask)) {
				continue; 
			}
			if (mapAvatarMask.ContainsKey (tmp.mask)) {
				mask = mapAvatarMask [tmp.mask];
			} else {
				if (File.Exists (tmp.mask)) {
					mask = AssetDatabase.LoadAssetAtPath (tmp.mask, typeof(AvatarMask)) as AvatarMask;
					mapAvatarMask [tmp.mask] = mask;
				} else {
					mask = null;
				}
			}

			if (mask != null) {
				aniLayer.avatarMask = mask;
			}
		}

		// =========== parameter begin ============
		lens = controls.listParameters.Count;
		for (int i = 0; i < lens; i++) {
			EBAniParameters tmp = controls.listParameters [i];
			aniController.AddParameter (tmp.name, tmp.getPType);
		}

		// =========== AnimationClip state begin ============
		lens = controls.listState.Count;
		string _fabName = Path.GetFileName (controls.fbxPath);
		int _indSuffex = _fabName.LastIndexOf (".");
		string _fabName2 = _fabName.Substring (0, _indSuffex);
		string _suffex = _fabName.Substring (_indSuffex + 1);

		if (controls.isHumanid) {
			string _pathClip = "";
			for (int i = 0; i < lens; i++) {
				EBAniState _state = controls.listState [i];
				if (string.IsNullOrEmpty (_state.actName)) {
					continue;
				}
				_pathClip = _fold + Path.DirectorySeparatorChar + _fabName2 + "@" + _state.actName + "." + _suffex;
				if (File.Exists (_pathClip)) {
					UnityEngine.Object[] _objs = AssetDatabase.LoadAllAssetsAtPath (_pathClip);
					relishipClip (_objs, controls, _state);
				}
			}
		} else {
			UnityEngine.Object[] _objs = AssetDatabase.LoadAllAssetsAtPath (controls.aniPath);
			relishipClip (_objs, controls, null);
		}



		Dictionary<string, AnimatorState>[] stateDics = new Dictionary<string, AnimatorState>[aniController.layers.Length];

		for (int i = 0; i < lens; i++) {
			EBAniState _state = controls.listState [i];

			if (_state.aniClip != null || "None".Equals (_state.name)) {
				AnimatorControllerLayer aniLayer = aniController.layers [_state.layerIndex];// .GetLayer (_state.layerIndex);
				AnimatorStateMachine aniMachine = aniLayer.stateMachine;
				AnimatorState aniState = aniMachine.AddState (_state.name); 
				if ("None".Equals (_state.name)) {
					aniMachine.defaultState = aniState;
				}

//				BlendTree tree = new BlendTree ();
//				tree.blendType = BlendTreeType.SimpleDirectional2D;
//				tree.blendParameter = "Action";
//				tree.AddChild(_state.aniClip, new Vector2(0.2f, 0.5f));
//				tree.name = "_state.name";

				aniState.motion = _state.aniClip;
				aniState.speed = _state.speed;

				if (stateDics [_state.layerIndex] == null) {
					stateDics [_state.layerIndex] = new Dictionary<string, AnimatorState> ();
				}
				stateDics[_state.layerIndex].Add (_state.name, aniState);
			}
		}
			
		//需要先将state添加完成后，才能建立 state之间的关系、
		//但这里有个问题，就是怎么判断不同layer的state

		for (int i = 0, len = controls.listState.Count; i < len; i++) {
			EBAniState _state = controls.listState [i];
			AnimatorControllerLayer aniLayer = aniController.layers [_state.layerIndex];// .GetLayer (_state.layerIndex);
			AnimatorStateMachine aniMachine = aniLayer.stateMachine;

			if (stateDics [_state.layerIndex] [_state.name] == null) {
				Debug.Log (_state.layerIndex + " " + _state.name + " " + stateDics [_state.layerIndex]);
			}
			AnimatorState aniState = stateDics[_state.layerIndex] [_state.name];

			AnimatorStateTransition startTransition = null;
			if (!string.IsNullOrEmpty (_state.enterState)) {
				if (_state.enterState.Equals ("Entry")) {
					aniMachine.defaultState = aniState;
				}else if(_state.enterState.Equals ("Any")) {
					startTransition = aniMachine.AddAnyStateTransition (aniState);
				}else if(stateDics[_state.layerIndex].ContainsKey(_state.enterState)){
					startTransition = stateDics[_state.layerIndex][_state.enterState] .AddTransition( aniState );
				}
			}

			if (startTransition != null) {
				startTransition.exitTime = _state.enterExitTime;
				startTransition.duration = 1 - _state.enterExitTime;
				//过渡用百分比的形式
				startTransition.hasFixedDuration = _state.enterHasFixed;
				//是否动画播放完才过渡
				startTransition.hasExitTime = _state.enterHasExitTime;
				startTransition.canTransitionToSelf = false;
				for(int j = 0, jlen = _state.enterBrigdes.Count; j < jlen; j++){
					EBAniBrigdes brigde = _state.enterBrigdes [j];
					startTransition.AddCondition(brigde.getTMode,  brigde.getTVal, brigde.ebPars.name);
				}
			}


			AnimatorStateTransition endTransition = null;
			if (!string.IsNullOrEmpty (_state.endState) && stateDics[_state.layerIndex].ContainsKey(_state.endState)) {
				endTransition = aniState.AddTransition( stateDics[_state.layerIndex][_state.endState] );
			}

			if (endTransition != null) {
				endTransition.exitTime = _state.endExitTime;
				endTransition.duration = 1 - _state.endExitTime;
				//过渡用百分比的形式
				endTransition.hasFixedDuration = _state.endHasFixed;
				//是否动画播放完才过渡
				endTransition.hasExitTime = _state.endHasExitTime;
				endTransition.canTransitionToSelf = false;
				for(int j = 0, jlen = _state.endBrigdes.Count; j < jlen; j++){
					EBAniBrigdes brigde = _state.endBrigdes [j];
					endTransition.AddCondition(brigde.getTMode,  brigde.getTVal, brigde.ebPars.name);
				}
			}


		}

		// =========== 生成prefab 并绑定 animator controller ============

		string _foldFab = Path.GetDirectoryName (controls.prefabPath);
		if (!Directory.Exists (_foldFab)) {
			Directory.CreateDirectory (_foldFab);
		}


		UnityEngine.GameObject gobjFab;
		UnityEngine.GameObject gobjFBX = AssetDatabase.LoadAssetAtPath (controls.fbxPath, typeof(UnityEngine.GameObject)) as GameObject;
		if (File.Exists (controls.prefabPath)) {
//			File.Delete (controls.prefabPath);
			gobjFab = AssetDatabase.LoadAssetAtPath (controls.prefabPath, typeof(UnityEngine.GameObject)) as GameObject;
		} else {
			gobjFab = GameObject.Instantiate(gobjFBX) as GameObject;
		}

		Animator aniFab = gobjFab.GetComponent<Animator> ();
		aniFab.runtimeAnimatorController = aniController;
		aniFab.applyRootMotion = false;

		UnityEngine.GameObject gobjParent;
		if (controls.isAddParent) {
			gobjParent = new GameObject (gobjFab.name);
			gobjFab.transform.parent = gobjParent.transform;
		} else {
			gobjParent = gobjFab;
		}

		if (!File.Exists (controls.prefabPath)) {
			PrefabUtility.CreatePrefab (controls.prefabPath, gobjParent);
			EditorUtility.SetDirty (gobjParent);
			GameObject.DestroyImmediate(gobjParent);
		}
	}
}

/// <summary>
/// 动画控制器 AnimatorController
/// </summary>
public class EBAniControls
{ 
	// 标识
	public int unqid;

	// 控制器名
	public string name;

	// 模型路径
	public string fbxPath;

	// 动画路径
	public string aniPath;

	// 预制件路径
	public string prefabPath;

	public int activeId;

	// 是否是人型动画
	public bool isHumanid;
	
	// 拥有的层级
	public string strLayers;
	
	// 拥有的参数
	public string strParameters;

	// 是否添加一个父级对象
	public bool isAddParent;

	private EBAniControls ()
	{
	}

	public EBAniControls (int unqid, string name, string fbxPath, string aniPath, string prefabPath, bool isHumanid, string strLayers, string strParameters, bool isAddParent)
	{
		this.unqid = unqid;
		this.name = name;
		this.fbxPath = fbxPath;
		this.aniPath = aniPath;
		this.prefabPath = prefabPath;
		this.isHumanid = isHumanid;
		this.strLayers = strLayers;
		this.strParameters = strParameters;
		this.isAddParent = isAddParent;

		this.resplite ();
	}

	public void resplite ()
	{
		if (this.unqid > 0) {
			if (!string.IsNullOrEmpty (this.strLayers)) {
				string[] arrs = this.strLayers.Split (";".ToCharArray ());
				int lens = arrs.Length;
				for (int i = 0; i < lens; i++) {
					layerUnqids.Add (int.Parse (arrs [i]));
				}
			}
			
			if (!string.IsNullOrEmpty (this.strParameters)) {
				string[] arrs = this.strParameters.Split (";".ToCharArray ());
				int lens = arrs.Length;
				for (int i = 0; i < lens; i++) {
					parsUnqids.Add (int.Parse (arrs [i]));
				}
			}
		}
	}

	public void parse (Hashtable map)
	{
		this.unqid = int.Parse ((map ["unqid"]).ToString ());
		object objName;
		if (map.ContainsKey ("name")) {
			objName = map ["name"];
		} else {
			objName = map ["animName"];
		}

		this.name = objName.ToString ();
		this.fbxPath = (map ["fbxPath"]).ToString ();
		this.aniPath = (map ["aniPath"]).ToString ();
		this.prefabPath = (map ["prefabPath"]).ToString ();
		this.strLayers = (map ["layers"]).ToString ();
		this.strParameters = (map ["paremeters"]).ToString ();
		this.activeId = int.Parse( (map ["activeId"]).ToString () );

		string tmpStr = (map ["isHumanid"]).ToString ();
		if (string.IsNullOrEmpty (tmpStr)) {
			this.isHumanid = false;
		} else {
			tmpStr = tmpStr.ToLower ().Trim ();
			this.isHumanid = (string.Equals ("1", tmpStr) || string.Equals ("true", tmpStr)) ? true : false;
		}

		tmpStr = (map ["isAddParent"]).ToString ();
		if (string.IsNullOrEmpty (tmpStr)) {
			this.isAddParent = false;
		} else {
			tmpStr = tmpStr.ToLower ().Trim ();
			this.isAddParent = (string.Equals ("1", tmpStr) || string.Equals ("true", tmpStr)) ? true : false;
		}
	}

	static public EBAniControls parseByMap (Hashtable map)
	{
		EBAniControls ret = new EBAniControls ();
		ret.parse (map);
		ret.resplite ();
		return ret;
	}

	// 拥有的层数(用于创建layer)
	public List<int> layerUnqids = new List<int> ();
	public List<EBAniLayers> listLayers = new List<EBAniLayers> ();

	// 拥有的参数列表(用于创建参数)
	public List<int> parsUnqids = new List<int> ();
	public List<EBAniParameters> listParameters = new List<EBAniParameters> ();

	// 当前的所有的动画状态机制
	public List<EBAniState> listState = new List<EBAniState> ();
}

/// <summary>
/// 动画状态 state
/// </summary>
public class EBAniState
{


	// 状态机名
	public string name;

	// 动作名
	public string actName;

	// 所在层
	public int layerIndex;
	public float speed;

	// 条件[parsid,parsmode,parsval;parsid,parsmode,parsval]
	public string strBrigdes;

	public string enterState;
	public bool enterHasExitTime;
	public bool enterHasFixed;
	public float enterExitTime;
	public string enterParams;

	public string endState;
	public bool endHasExitTime;
	public bool endHasFixed;
	public float endExitTime;
	public string endParams;


	// 条件Transitions
	public List<EBAniBrigdes> listBrigdes = new List<EBAniBrigdes> ();

	public List<EBAniBrigdes> enterBrigdes = new List<EBAniBrigdes> ();
	public List<EBAniBrigdes> endBrigdes = new List<EBAniBrigdes> ();

	// 动画片段
	public AnimationClip aniClip = null;
	
	public EBAniState(){

	}

	public void parse (Hashtable map)
	{

		this.name = (map ["name"]).ToString ();

		this.actName = (map ["actName"]).ToString ();

		this.layerIndex = int.Parse ((map ["ind4Layer"]).ToString ());
		this.speed = float.Parse ((map ["speed"]).ToString ());

		this.enterState = (map ["enterState"]).ToString ();
		this.enterHasExitTime = GetStringBool((map ["enterHasExitTime"]).ToString ());
		this.enterHasFixed = GetStringBool((map ["enterHasFixed"]).ToString ());
		this.enterExitTime = float.Parse("0"+(map ["enterExitTime"]).ToString ());
		this.enterParams = (map ["enterParams"]).ToString ();

		this.endState = (map ["endState"]).ToString ();
		this.endHasExitTime = GetStringBool((map ["endHasExitTime"]).ToString ());
		this.endHasFixed = GetStringBool((map ["endHasFixed"]).ToString ());
		this.endExitTime = float.Parse("0"+(map ["endExitTime"]).ToString ());
		this.endParams = (map ["endParams"]).ToString ();
	}

	public void DescParams(Dictionary<int, EBAniParameters> dicParameters){

		if (!string.IsNullOrEmpty (enterParams)) {
			string[] arrs = enterParams.Split (";".ToCharArray ());
			for (int i = 0; i < arrs.Length; i++) {
				string[] arrs2 = (arrs [i]).Split (",".ToCharArray ());
				if (arrs2.Length != 3) {
					continue;
				}
				EBAniBrigdes brigde = new EBAniBrigdes (int.Parse (arrs2 [0]), int.Parse (arrs2 [1]), arrs2 [2]);
				brigde.ebPars = dicParameters [brigde.parsUnqid];
				if (brigde.ebPars == null) {
					continue;
				}

				enterBrigdes.Add (brigde);
			}
		}

		if (!string.IsNullOrEmpty (endParams)) {
			string[] arrs = endParams.Split (";".ToCharArray ());
			for (int i = 0; i < arrs.Length; i++) {
				string[] arrs2 = (arrs [i]).Split (",".ToCharArray ());
				if (arrs2.Length != 3) {
					continue;
				}
				EBAniBrigdes brigde = new EBAniBrigdes (int.Parse (arrs2 [0]), int.Parse (arrs2 [1]), arrs2 [2]);
				brigde.ebPars = dicParameters [brigde.parsUnqid];
				if (brigde.ebPars == null) {
					continue;
				}

				endBrigdes.Add (brigde);
			}
		}
	}
	
	static public EBAniState parseByMap (Hashtable map)
	{
		EBAniState ret = new EBAniState ();
		ret.parse (map);
		return ret;
	}

	bool GetStringBool(string tmpStr){
		bool result = false;
		if (string.IsNullOrEmpty (tmpStr)) {
			result = false;
		} else {
			tmpStr = tmpStr.ToLower ().Trim ();
			result = (string.Equals ("1", tmpStr) || string.Equals ("true", tmpStr)) ? true : false;
		}
		return result;
	}

}

/// <summary>
/// 动画动画连接桥Transition
/// </summary>
public class EBAniBrigdes
{
	// 参数标识
	public int parsUnqid;

	// 参数判断模式：[0:false,!= ],[1:true,==],[2:>],[3:<]
	public int mode;

	// 判断值
	public string val;
	
	private EBAniBrigdes ()
	{
	}
	
	public EBAniBrigdes (int parsUnqid, int mode, string val)
	{
		this.parsUnqid = parsUnqid;
		this.mode = mode;
		this.val = val;
	}

	public void parse (Hashtable map)
	{
		this.parsUnqid = int.Parse ((map ["parsUnqid"]).ToString ());
		this.mode = int.Parse ((map ["mode"]).ToString ());
		this.val = (map ["val"]).ToString ();
	}

	public EBAniParameters ebPars;

	//AnimatorConditionMode
	public AnimatorConditionMode getTMode {
		get {
			switch (this.mode) {
			case 0:
				return AnimatorConditionMode.Less;
			case 1:
				return AnimatorConditionMode.Equals;
			case 2:
				return AnimatorConditionMode.Greater;
			}
			return AnimatorConditionMode.NotEqual;
		}
	}

	public float getTVal {
		get {
			try {
				return float.Parse (this.val);
			} catch {
				return 0.0f;
			}
		}
	}
}

/// <summary>
/// 参数 Parameters
/// </summary>
public class EBAniParameters
{
	// 标识
	public int unqid;

	// 动画参数名
	public string name;

	// 参数类型:[0:float,1:int,2:bool,3:trigger]
	public int type;

	private EBAniParameters ()
	{
	}

	public EBAniParameters (int unqid, string name, int type)
	{
		this.unqid = unqid;
		this.name = name;
		this.type = type;
	}

	public void parse (Hashtable map)
	{
		this.unqid = int.Parse ((map ["unqid"]).ToString ());
		this.name = (map ["name"]).ToString ();
		this.type = int.Parse ((map ["type"]).ToString ());
	}

	public AnimatorControllerParameterType getPType {
		get {
			switch (this.type) {
			case 1:
				return AnimatorControllerParameterType.Int;
			case 2:
				return AnimatorControllerParameterType.Bool;
			case 3:
				return AnimatorControllerParameterType.Trigger;
			}
			return AnimatorControllerParameterType.Float;
		}
	}

	static public EBAniParameters parseByMap (Hashtable map)
	{
		EBAniParameters ret = new EBAniParameters ();
		ret.parse (map);
		return ret;
	}
}

/// <summary>
/// 层 layers
/// </summary>
public class EBAniLayers
{
	// 标识
	public int unqid;

	// 动画层名字
	public string name;

	// 在layers中的顺序从0开始
	public int index;

	// 权重
	public float weight;

	// Avatar Mask对象数据地址
	public string mask;

	private EBAniLayers ()
	{
	}

	public EBAniLayers (int unqid, string name, int index, float weight, string mask)
	{
		this.unqid = unqid;
		this.name = name;
		this.index = index;
		this.weight = weight;
		this.mask = mask;
	}

	public void parse (Hashtable map)
	{
		this.unqid = int.Parse ((map ["unqid"]).ToString ());
		this.name = (map ["name"]).ToString ();
		this.index = int.Parse ((map ["index"]).ToString ());
		this.weight = float.Parse ((map ["weight"]).ToString ());
		this.mask = (map ["mask"]).ToString ();
	}

	static public EBAniLayers parseByMap (Hashtable map)
	{
		EBAniLayers ret = new EBAniLayers ();
		ret.parse (map);
		return ret;
	}
}