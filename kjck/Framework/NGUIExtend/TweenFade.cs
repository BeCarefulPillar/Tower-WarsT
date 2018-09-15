using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TweenFade : UITweener
{
    [Range(0f, 1f)] public float from = 1f;
    [Range(0f, 1f)] public float to = 1f;
    
    private bool mCached = false;
    private GameObject mGo;
    private UIRect mRect;
    private Material mMat;
    private Light mLight;
    private SpriteRenderer mSr;
    private float mBaseIntensity = 1f;

    void Cache()
    {
        mCached = true;
        mGo = gameObject;
        mRect = GetComponent<UIRect>();
        mSr = GetComponent<SpriteRenderer>();

        if (mRect == null && mSr == null)
        {
            mLight = GetComponent<Light>();

            if (mLight == null)
            {
                Renderer ren = GetComponent<Renderer>();
                if (ren != null) mMat = ren.material;
                if (mMat == null) mRect = GetComponentInChildren<UIRect>();
            }
            else mBaseIntensity = mLight.intensity;
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
            if (mRect != null) return mRect.alpha;
            if (mSr != null) return mSr.color.a;
            return mMat != null ? mMat.color.a : 1f;
        }
        set
        {
            if (!mCached) Cache();

            if (mRect != null)
            {
                mRect.alpha = value;
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
            else if (mLight != null)
            {
                mLight.intensity = mBaseIntensity * value;
            }
        }
    }

    /// <summary>
    /// Tween the value.
    /// </summary>

    protected override void OnUpdate(float factor, bool isFinished)
    {
        value = Mathf.Lerp(from, to, factor);

        if (isFinished && value <= 0f)
        {
            mGo.SetActive(false);
        }
    }

    /// <summary>
    /// Start the tweening operation.
    /// </summary>

    public static TweenFade Begin(GameObject go, bool show, float duration, float delay = 0f)
    {
        TweenFade comp = UITweener.Begin<TweenFade>(go, duration, delay);

        comp.to = show ? 1f : 0f;

        if (go.activeSelf)
        {
            comp.from = comp.value;
        }
        else
        {
            comp.from = 0f;
            comp.value = 0f;
            go.SetActive(show);
        }

        if (duration <= 0f || !go.activeInHierarchy)
        {
            comp.Sample(1f, true);
            comp.enabled = false;
        }
        return comp;
    }

    public override void SetStartToCurrentValue() { from = value; }
    public override void SetEndToCurrentValue() { to = value; }
}
