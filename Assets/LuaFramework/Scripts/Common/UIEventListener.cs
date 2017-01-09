using UnityEngine;
using System.Collections;
using System;
using UnityEngine.EventSystems;

public class UIEventListener : EventTrigger {
	public delegate void VoidPointerDelegate (GameObject go, PointerEventData eventData);
	public delegate void VoidBaseDelegate (GameObject go, BaseEventData eventData);

	public VoidPointerDelegate onClick;
	public VoidPointerDelegate onDown;
	public VoidPointerDelegate onUp;
	public VoidPointerDelegate onEnter;
	public VoidPointerDelegate onExit;

	public VoidBaseDelegate onSelect;
	public VoidBaseDelegate onCancel;

	public VoidPointerDelegate onScroll;

	public VoidPointerDelegate onBeginDrag;
	public VoidPointerDelegate onDrag;
	public VoidPointerDelegate onEndDrag;


	public static UIEventListener Get(GameObject go){
		UIEventListener listener = go.GetComponent<UIEventListener>();
		if (listener == null) listener = go.AddComponent<UIEventListener>();
		return listener;
	}

	public override void OnPointerClick(PointerEventData eventData)
	{
		if(onClick != null) onClick(gameObject, eventData);
	}
	public override void OnPointerDown (PointerEventData eventData){
		if(onDown != null) onDown(gameObject, eventData);
	}
	public override void OnPointerUp (PointerEventData eventData){
		if(onUp != null) onUp(gameObject, eventData);
	}

	public override void OnPointerEnter (PointerEventData eventData){
		if(onEnter != null) onEnter(gameObject, eventData);
	}
	public override void OnPointerExit (PointerEventData eventData){
		if(onExit != null) onExit(gameObject, eventData);
	}

	public override void OnSelect (BaseEventData eventData){
		if(onSelect != null) onSelect(gameObject, eventData);
	}
	public override void OnCancel (BaseEventData eventData){
		if (onCancel != null) onCancel (gameObject, eventData);
	}


	public override void OnScroll (PointerEventData eventData){
		if (onScroll != null) onScroll (gameObject, eventData);
	}
	public override void OnBeginDrag (PointerEventData eventData){
		if (onBeginDrag != null) onBeginDrag (gameObject, eventData);
	}
	public override void OnDrag (PointerEventData eventData){
		if (onDrag != null) onDrag (gameObject, eventData);
	}
	public override void OnEndDrag (PointerEventData eventData){
		if (onEndDrag != null) onEndDrag (gameObject, eventData);
	}


}
