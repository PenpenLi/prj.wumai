using UnityEngine;
using System.Collections;
using UnityEngine.UI;


using System;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Serialization;

/// <summary>
/// 改编自 Toggle，主要支持整个节点graphic的切换，目测不支持ColorTint之外的Transition
/// 2016-10-10
/// </summary>

[RequireComponent(typeof(RectTransform))]
public class ULToggle : Selectable, IPointerClickHandler, ISubmitHandler, ICanvasElement
{
	public enum ToggleTransition
	{
		None,
		Fade
	}

	/// <summary>
	/// Transition type.
	/// </summary>
	public ToggleTransition toggleTransition = ToggleTransition.Fade;

	/// <summary>
	///The toggle node should be working with.
	/// </summary>
	public RectTransform graphic;

	// group that this toggle can belong to
	[SerializeField]
	private ULToggleGroup m_Group;

	public ULToggleGroup group
	{
		get { return m_Group; }
		set
		{
			m_Group = value;
			#if UNITY_EDITOR
			if (Application.isPlaying)
			#endif
			{
				SetToggleGroup(m_Group, true);
				PlayEffect(true);
			}
		}
	}

	/// <summary>
	/// Allow for delegate-based subscriptions for faster events than 'eventReceiver', and allowing for multiple receivers.
	/// </summary>
	public Toggle.ToggleEvent onValueChanged = new Toggle.ToggleEvent();

	// Whether the toggle is on
	[FormerlySerializedAs("m_IsActive")]
	[Tooltip("Is the toggle currently on or off?")]
	[SerializeField]
	private bool m_IsOn;



	protected ULToggle()
	{}

	#if UNITY_EDITOR
	protected override void OnValidate()
	{
		base.OnValidate();
		Set(m_IsOn, false);
		PlayEffect(toggleTransition == ToggleTransition.None);

		var prefabType = UnityEditor.PrefabUtility.GetPrefabType(this);
		if (prefabType != UnityEditor.PrefabType.Prefab && !Application.isPlaying)
			CanvasUpdateRegistry.RegisterCanvasElementForLayoutRebuild(this);
	}

	#endif // if UNITY_EDITOR

	public virtual void Rebuild(CanvasUpdate executing)
	{
		#if UNITY_EDITOR
		if (executing == CanvasUpdate.Prelayout)
			onValueChanged.Invoke(m_IsOn);
		#endif
	}

	public virtual void LayoutComplete()
	{}

	public virtual void GraphicUpdateComplete()
	{}

	protected override void OnEnable()
	{
		base.OnEnable();
		SetToggleGroup(m_Group, false);
		PlayEffect(true);
	}

	protected override void OnDisable()
	{
		SetToggleGroup(null, false);
		base.OnDisable();
	}


	private void SetToggleGroup(ULToggleGroup newGroup, bool setMemberValue)
	{
		ULToggleGroup oldGroup = m_Group;

		// Sometimes IsActive returns false in OnDisable so don't check for it.
		// Rather remove the toggle too often than too little.
		if (m_Group != null)
			m_Group.UnregisterToggle(this);

		// At runtime the group variable should be set but not when calling this method from OnEnable or OnDisable.
		// That's why we use the setMemberValue parameter.
		if (setMemberValue)
			m_Group = newGroup;

		// Only register to the new group if this Toggle is active.
		if (m_Group != null && IsActive())
			m_Group.RegisterToggle(this);

		// If we are in a new group, and this toggle is on, notify group.
		// Note: Don't refer to m_Group here as it's not guaranteed to have been set.
		if (newGroup != null && newGroup != oldGroup && isOn && IsActive())
			m_Group.NotifyToggleOn(this);
	}

	/// <summary>
	/// Whether the toggle is currently active.
	/// </summary>
	public bool isOn
	{
		get { return m_IsOn; }
		set
		{
			Set(value);
		}
	}

	void Set(bool value)
	{
		Set(value, true);
	}

	void Set(bool value, bool sendCallback)
	{
		if (m_IsOn == value)
			return;

		// if we are in a group and set to true, do group logic
		m_IsOn = value;
		if (m_Group != null && IsActive())
		{
//            if (m_IsOn || (!m_Group.AnyTogglesOn() && !m_Group.allowSwitchOff))
//            {
//                m_IsOn = true;
//				m_Group.NotifyToggleOn(this);
//            }

			if(m_IsOn)
				m_Group.NotifyToggleOn(this);
		}

		// Always send event when toggle is clicked, even if value didn't change
		// due to already active toggle in a toggle group being clicked.
		// Controls like Dropdown rely on this.
		// It's up to the user to ignore a selection being set to the same value it already was, if desired.
		PlayEffect(toggleTransition == ToggleTransition.None);
		if (sendCallback)
			onValueChanged.Invoke(m_IsOn);
	}

	/// <summary>
	/// Play the appropriate effect.
	/// </summary>
	private void PlayEffect(bool instant)
	{
		if (graphic == null) return;

		Graphic[] graphics = graphic.GetComponentsInChildren<Graphic>();

		if(graphics.Length <= 0) return;
		float alpha = m_IsOn ? 1f : 0f;

	#if UNITY_EDITOR
		if (!Application.isPlaying){
			foreach(var g in graphics){
				g.canvasRenderer.SetAlpha(alpha);
			}
		}
		else
	#endif
		{
			foreach(var g in graphics){
				g.CrossFadeAlpha(alpha, instant ? 0f : 0.1f, true);
			}
		}
	}

	/// <summary>
	/// Assume the correct visual state.
	/// </summary>
	protected override void Start()
	{
		PlayEffect(true);
	}

	private void InternalToggle()
	{
		if (!IsActive() || !IsInteractable())
			return;

        // 不允许主动取消
        if(m_Group != null && !m_Group.allowSwitchOff && m_IsOn)
            return;

		isOn = !isOn;
	}

	/// <summary>
	/// React to clicks.
	/// </summary>
	public virtual void OnPointerClick(PointerEventData eventData)
	{
		if (eventData.button != PointerEventData.InputButton.Left)
			return;

		InternalToggle();
	}

	public virtual void OnSubmit(BaseEventData eventData)
	{
		InternalToggle();
	}
}
