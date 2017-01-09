using UnityEngine;
using UnityEngine.UI;

public class TweenAlpha : UITweener
{
    [Range(0f, 1f)]
    public float from = 1f;
    [Range(0f, 1f)]
    public float to = 1f;

    bool mCached = false;
	Graphic[] graphics;
    Material mMat;
    SpriteRenderer mSr;

	public bool includeChildren = true;

    void Cache()
    {
        mCached = true;
		if(includeChildren)
			graphics = GetComponentsInChildren<Graphic>();
		else
			graphics = GetComponents<Graphic>();

		if (graphics != null && graphics.Length > 0)
            return;

		graphics = null;
		
        mSr = GetComponent<SpriteRenderer>();
        if (mSr != null)
            return;
        
		Renderer ren = GetComponent<Renderer>();
        if (ren != null)
        {
            mMat = ren.material;
            return;
        }
    }

    /// <summary>
    /// Tween's current value.
    /// </summary>

    public float value
    {
        get
        {
            if (!mCached) Cache();
			if (graphics != null)
				return graphics[0].color.a;
            if (mSr != null) return mSr.color.a;
            return mMat != null ? mMat.color.a : 1f;
        }
        set
        {
            if (!mCached)
                Cache();
			else if (graphics != null)
            {
				foreach(Graphic g in graphics){
	                Color c = g.color;
	                c.a = value;
					g.canvasRenderer.SetColor(c);
				}
            }
            else if (mSr != null)
            {
                Color c = mSr.color;
                c.a = value;
                mSr.color = c;
            }
            else if (mMat != null)
            {
                Color c = mMat.color;
                c.a = value;
                mMat.color = c;
            }
        }
    }

    /// <summary>
    /// Tween the value.
    /// </summary>

    protected override void OnUpdate(float factor, bool isFinished) { value = Mathf.Lerp(from, to, factor); }

    /// <summary>
    /// Start the tweening operation.
    /// </summary>

    static public TweenAlpha Begin(GameObject go, float duration, float alpha)
    {
        TweenAlpha comp = UITweener.Begin<TweenAlpha>(go, duration);
        comp.from = comp.value;
        comp.to = alpha;

        if (duration <= 0f)
        {
            comp.Sample(1f, true);
            comp.enabled = false;
        }
        return comp;
    }

    public override void SetStartToCurrentValue() { from = value; }
    public override void SetEndToCurrentValue() { to = value; }
}