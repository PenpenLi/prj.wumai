//----------------------------------------------
//            继承ngui
//----------------------------------------------

using UnityEngine;
using System;
using System.Collections.Generic;
using Direction = UITweener.Direction;

/// <summary>
/// Play the specified tween on click.
/// </summary>

public class UIPlayTween : MonoBehaviour
{
	static public UIPlayTween current;

	/// <summary>
	/// Target on which there is one or more tween.
	/// </summary>

	public GameObject tweenTarget;

	/// <summary>
	/// If there are multiple tweens, you can choose which ones get activated by changing their group.
	/// </summary>

	public int tweenGroup = 0;

	/// <summary>
	/// Direction to tween in.
	/// </summary>

	public Direction playDirection = Direction.Forward;

	/// <summary>
	/// Whether the tween will be reset to the start or end when activated. If not, it will continue from where it currently is.
	/// </summary>

	bool resetOnPlay = true;

	/// <summary>
	/// Whether the tween will be reset to the start if it's disabled when activated.
	/// </summary>

	bool resetIfDisabled = true;

	/// <summary>
	/// Whether the tweens on the child game objects will be considered.
	/// </summary>

	public bool includeChildren = false;

	/// <summary>
	/// Event delegates called when the animation finishes.
	/// </summary>

	public Action onAllFinished;

	UITweener[] mTweens;
	int mActive = 0;

	void Awake ()
	{
	}

	void Start()
	{
		if (tweenTarget == null)
		{
			tweenTarget = gameObject;
		}
	}

	void OnEnable ()
	{
	}

	void OnDisable ()
	{
#if UNITY_EDITOR
		if (!Application.isPlaying) return;
#endif
	}


	void Update ()
	{
	}

	/// <summary>
	/// Activate the tweeners.
	/// </summary>

	public void Play (bool forward)
	{
		#if UNITY_EDITOR
		if (!Application.isPlaying) return;
		#endif

		mActive = 0;
		GameObject go = (tweenTarget == null) ? gameObject : tweenTarget;

		// Gather the tweening components
		mTweens = includeChildren ? go.GetComponentsInChildren<UITweener>() : go.GetComponents<UITweener>();

		if (mTweens.Length == 0)
		{
			// No tweeners found -- should we disable the object?
		}
		else
		{
			bool activated = false;
			if (playDirection == Direction.Reverse) forward = !forward;

			// Run through all located tween components
			for (int i = 0, imax = mTweens.Length; i < imax; ++i)
			{
				UITweener tw = mTweens[i];

				// If the tweener's group matches, we can work with it
				if (tw.tweenGroup == tweenGroup)
				{
					// Ensure that the game objects are enabled
					if (!activated && !( go && go.activeInHierarchy ))
					{
						activated = true;
						go.SetActive(true);
					}

					++mActive;

					// Toggle or activate the tween component
					if (playDirection == Direction.Toggle)
					{
						// Listen for tween finished messages
						tw.OnFinished = OnFinished;
						tw.Toggle();
					}
					else
					{
						if (resetOnPlay || (resetIfDisabled && !tw.enabled))
						{
							tw.ResetToBeginning();
						}
						// Listen for tween finished messages
						tw.OnFinished = OnFinished;
						tw.Play(forward);
					}
				}
			}
		}
	}

	/// <summary>
	/// Callback triggered when each tween executed by this script finishes.
	/// </summary>

	void OnFinished ()
	{
		if (--mActive == 0 && current == null)
		{
			current = this;
			if(onAllFinished != null)
				onAllFinished();

			current = null;
		}
	}

}
