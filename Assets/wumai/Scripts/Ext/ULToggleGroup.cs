using System;
using System.Linq;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;


/// <summary>
/// 改编自 ToggleGroup
/// 2016-10-10
/// </summary>


[DisallowMultipleComponent]
public class ULToggleGroup : UIBehaviour
{
	[SerializeField] private bool m_AllowSwitchOff = false;
	public bool allowSwitchOff { get { return m_AllowSwitchOff; } set { m_AllowSwitchOff = value; } }

	private List<ULToggle> m_Toggles = new List<ULToggle>();

	protected ULToggleGroup()
	{}

	private void ValidateToggleIsInGroup(ULToggle toggle)
	{
		if (toggle == null || !m_Toggles.Contains(toggle))
			throw new ArgumentException(string.Format("using UnityEngine; {0} is not part of ULToggleGroup {1}", new object[] {toggle, this}));
	}

	public void NotifyToggleOn(ULToggle toggle)
	{
		ValidateToggleIsInGroup(toggle);

		// disable all toggles in the group
		for (var i = 0; i < m_Toggles.Count; i++)
		{
			if (m_Toggles[i] == toggle)
				continue;

			m_Toggles[i].isOn = false;
		}
	}

	public void UnregisterToggle(ULToggle toggle)
	{
		if (m_Toggles.Contains(toggle))
			m_Toggles.Remove(toggle);
	}

	public void RegisterToggle(ULToggle toggle)
	{
		if (!m_Toggles.Contains(toggle))
			m_Toggles.Add(toggle);
	}

	public bool AnyTogglesOn()
	{
		return m_Toggles.Find(x => x.isOn) != null;
	}

	public IEnumerable<ULToggle> ActiveToggles()
	{
		return m_Toggles.Where(x => x.isOn);
	}

	public void SetAllTogglesOff()
	{
		bool oldAllowSwitchOff = m_AllowSwitchOff;
		m_AllowSwitchOff = true;

		for (var i = 0; i < m_Toggles.Count; i++)
			m_Toggles[i].isOn = false;

		m_AllowSwitchOff = oldAllowSwitchOff;
	}
}
