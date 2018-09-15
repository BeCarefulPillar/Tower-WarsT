using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIWrapItemTween : MonoBehaviour
{
    /// <summary>
    /// 弹性强度，越大越快
    /// </summary>
    public float strength = 9f;
    /// <summary>
    /// 渐入渐出时间
    /// </summary>
    public float fadeTime = 0.2f;

    [NonSerialized] private GameObject mGo;
    [NonSerialized] private Transform mTrans;
    [NonSerialized] private UIRect mRect;
    [NonSerialized] private SpriteRenderer mSr;
    [NonSerialized] private Light mLight;
    [NonSerialized] private Material mMat;
    [NonSerialized] private float mBaseIntensity = 1f;

    [NonSerialized] private bool mIsInit = false;
    [NonSerialized] private float mAlpha = 0f;
    [NonSerialized] private float mThreshold = 0f;
    [NonSerialized] private Vector3 mTarget = Vector3.zero;
    [NonSerialized] private float mFadeTime = 0f;

    private void Awake()
    {
        if (!mIsInit) Init();
    }

    private void Update()
    {
        float val = alpha;
        if (mAlpha != val)
        {
            if (fadeTime > 0.0001f)
            {
                mFadeTime += Time.unscaledDeltaTime;
                val = Mathf.Lerp(val, mAlpha, Mathf.Clamp01(mFadeTime / fadeTime));
            }
            else
            {
                val = mAlpha;
            }

            alpha = val;
        }

        if (mAlpha != 0f)
        {
            if (mThreshold == 0f) mThreshold = (mTarget - mTrans.localPosition).sqrMagnitude * 0.00001f;
            mTrans.localPosition = NGUIMath.SpringLerp(mTrans.localPosition, mTarget, strength, Time.unscaledDeltaTime);

            if (mThreshold >= (mTarget - mTrans.localPosition).sqrMagnitude)
            {
                mTrans.localPosition = mTarget;
                if (val == mAlpha) enabled = false;
            }
        }
        else if (val == mAlpha)
        {
            mTrans.localPosition = mTarget;
            enabled = false;
            mGo.SetActive(false);
        }
    }

    private void OnEnable()
    {
        mThreshold = 0f;
    }

    private void OnDisable()
    {
        alpha = mAlpha;
        mFadeTime = fadeTime;
        mTrans.localPosition = mTarget;
        //mGo.SetActive(mAlpha != 0f);
    }

    private void Init()
    {
        mIsInit = true;
        mGo = gameObject;
        mTrans = transform;
        mRect = GetComponent<UIRect>();
        mSr = GetComponent<SpriteRenderer>();

        mTarget = mTrans.localPosition;
        mFadeTime = fadeTime;

        if (mRect == null && mSr == null)
        {
            mLight = GetComponent<Light>();

            if (mLight == null)
            {
                Renderer ren = GetComponent<Renderer>();
                if (ren != null) mMat = ren.material;
                if (mMat == null) mRect = GetComponentInChildren<UIRect>();
            }
            else
            {
                mBaseIntensity = mLight.intensity;
            }
        }
    }

    private float alpha
    {
        get
        {
            if (!mIsInit) Init();
            if (mRect) return mRect.alpha;
            if (mSr) return mSr.color.a;
            return mMat ? mMat.color.a : 1f;
        }
        set
        {
            if (!mIsInit) Init();

            if (mRect)
            {
                mRect.alpha = value;
            }
            else if (mSr)
            {
                Color c = mSr.color;
                c.a = value;
                mSr.color = c;
            }
            else if (mMat)
            {
                Color c = mMat.color;
                c.a = value;
                mMat.color = c;
            }
            else if (mLight)
            {
                mLight.intensity = mBaseIntensity * value;
            }
        }
    }

    public void SetActive(bool value, bool smoothly = false)
    {
        if (!mIsInit) Init();

        if (value)
        {
            mAlpha = 1f;
            
            if (smoothly)
            {
                if (!mGo.activeInHierarchy)
                {
                    mGo.SetActive(true);
                    alpha = 0f;
                }
                mFadeTime = alpha * fadeTime;
                enabled = true;
            }
            else
            {
                mGo.SetActive(true);
                alpha = mAlpha;
            }
        }
        else
        {
            mAlpha = 0f;
            if (smoothly && mGo.activeInHierarchy)
            {
                mFadeTime = (1f - alpha) * fadeTime;
                enabled = true;
            }
            else
            {
                alpha = mAlpha;
                mGo.SetActive(false);
            }
        }
    }

    public void SetPosition(Vector3 value, bool smoothly = false)
    {
        if (!mIsInit) Init();

        mTarget = value;

        if (smoothly && mGo.activeInHierarchy)
        {
            enabled = true;
        }
        else
        {
            mTrans.localPosition = mTarget;
        }
    }

    public bool isActive { get { return mAlpha != 0f; } }

    public static void Active(GameObject go, bool value, bool smoothly = false)
    {
        UIWrapItemTween comp = go.GetComponent<UIWrapItemTween>();
        if (comp)
        {
            comp.SetActive(value, smoothly);
        }
        else if (smoothly)
        {
            comp = go.AddComponent<UIWrapItemTween>();
            comp.SetActive(value);
        }
        else
        {
            go.SetActive(value);
        }
    }

    public static void Position(GameObject go, Vector3 value, bool smoothly = false)
    {
        UIWrapItemTween comp = go.GetComponent<UIWrapItemTween>();
        if (comp)
        {
            comp.SetPosition(value, smoothly);
        }
        else if (smoothly)
        {
            comp = go.AddComponent<UIWrapItemTween>();
            comp.SetPosition(value, smoothly);
        }
        else
        {
            go.transform.localPosition = value;
        }
    }
}
