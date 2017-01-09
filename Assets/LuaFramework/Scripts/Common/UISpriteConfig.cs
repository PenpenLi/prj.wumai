using UnityEngine;
using System.Collections.Generic;

public class UISpriteConfig : MonoBehaviour
{
	[SerializeField]
	public List<Sprite> m_spriteList = new List<Sprite>();

	public Sprite GetSprite(string name){
        //TODO 这里需要进一步处理，先跑通，处理其他问题
        int lens = m_spriteList.Count;
        int index;
        for (index = 0; index < lens; index++)
        {
            if(m_spriteList[index].name == name)
            {
                return m_spriteList[index];
            }
        }

        return null;
    }

	public void AddSprite(Sprite sprite){
		if (!m_spriteList.Contains (sprite)) {
			m_spriteList.Add (sprite);
		}
	}

	public int Count(){
		return m_spriteList.Count;
	}
}
