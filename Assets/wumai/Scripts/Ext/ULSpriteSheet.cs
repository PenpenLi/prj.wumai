using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class ULSpriteSheet : MonoBehaviour {


    public Sprite[] sprites;
    public float framesPerSecond;

    private Image m_image;

	// Use this for initialization
	void Start () {
        m_image = GetComponent<Image>();
	}

    // Update is called once per frame
    void Update()
    {
        if (m_image == null || framesPerSecond <= 0 || sprites == null)
            return;

        int index = (int)(Time.timeSinceLevelLoad * framesPerSecond);
        index = index % sprites.Length;
        m_image.sprite = sprites[index];
	}
}
