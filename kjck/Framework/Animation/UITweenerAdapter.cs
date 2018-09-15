using System;
using UnityEngine;

public class UITweenerAdapter : AnimationAdapter
{
    [SerializeField] public bool playActive;
    [SerializeField] public bool reverseInactive;
    [SerializeField] private UITweener[] mTweeners;

    [NonSerialized] private bool mPlay = false;
    [NonSerialized] private bool mPaused = false;
    /// <summary>
    /// 方向 1正向 -1反向
    /// </summary>
    [NonSerialized] private int mDirection = 1;

    [NonSerialized] private GameObject mGo;

    public GameObject cacheGameObject { get { if (mGo == null) mGo = gameObject; return mGo; } }

    public void OnEnable()
    {
        if (mTweeners == null || mTweeners.Length < 1)
        {
            enabled = false;
        }
    }

    public UITweener this[int index]
    {
        get
        {
            if(index >= 0 && mTweeners != null && index < mTweeners.Length)
            {
                return mTweeners[index];
            }
            return null;
        }
    }

    public override bool isPause { get { return mPaused; } }

    public override bool isPlaying { get { return mPlay; } }

    public override bool isForward { get { return mDirection == 1; } }

    private void Update()
    {
        if (mPlay)
        {
            if (mPaused) return;

            foreach (UITweener ut in mTweeners) if (ut && ut.isActiveAndEnabled) return;

            Stop();
        }
        else
        {
            mPaused = false;
            enabled = false;
        }
    }

    public override void Reset()
    {
        if (mTweeners == null || mTweeners.Length < 1) return;
        foreach (UITweener ut in mTweeners) if (ut) ut.ResetToInit(mDirection != -1);
    }

    public override void Pause()
    {
        if (mPlay && !mPaused)
        {
            mPaused = true;
            enabled = false;
            if (mTweeners == null || mTweeners.Length < 1) return;
            foreach (UITweener ut in mTweeners) if(ut) ut.enabled = false;
        }
    }

    public override void Play()
    {
        if (mPlay)
        {
            if (!mPaused && mDirection == 1) return;
            mDirection = 1;
        }
        else
        {
            mDirection = 1;
            Reset();
        }

        mPlay = true;

        if (mTweeners != null && mTweeners.Length > 0)
        {
            mPaused = false;
            enabled = true;
            foreach (UITweener ut in mTweeners) if (ut) ut.PlayForward();
            if (playActive) gameObject.SetActive(true);
            if (isActiveAndEnabled) return;
        }

        Stop();
    }

    public override void PlayReverse()
    {
        if (mPlay)
        {
            if (!mPaused && mDirection == -1) return;
            mDirection = -1;
        }
        else
        {
            mDirection = -1;
            Reset();
        }

        mPlay = true;

        if (mTweeners != null && mTweeners.Length > 0)
        {
            mPaused = false;
            enabled = true;
            foreach (UITweener ut in mTweeners) if (ut) ut.PlayReverse();
            if (isActiveAndEnabled) return;
        }

        Stop();
    }

    public override void Stop()
    {
        if (!mPlay) return;

        mPlay = false;
        mPaused = false;
        enabled = false;

        if (reverseInactive && mDirection == -1)
        {
            gameObject.SetActive(false);
        }

        if (mTweeners != null && mTweeners.Length > 0)
        {
            foreach (UITweener ut in mTweeners)
            {
                if (ut && ut.enabled)
                {
                    ut.tweenFactor = mDirection == -1 ? 0f : 1f;
                    ut.Sample(ut.tweenFactor, false);
                    ut.enabled = false;
                }
            }
        }

        if (onFinished != null) onFinished(this);
    }

    public override void Play(int index, bool forward)
    {
        if (mPaused) return;
        if (index >= 0 && mTweeners != null && index < mTweeners.Length)
        {
            UITweener ut = mTweeners[index];
            if (!ut || ut.enabled) return;
            ut.ResetToBeginning();
            ut.Play(forward);
        }
    }

    public override void Stop(int index)
    {
        if (mPaused) return;
        if (index >= 0 && mTweeners != null && index < mTweeners.Length)
        {
            UITweener ut = mTweeners[index];
            if (ut && ut.enabled)
            {
                ut.ResetToInit();
                ut.enabled = false;
            }
        }
    }
    public override bool IsPlaying(int index)
    {
        if (index >= 0 && mTweeners != null && index < mTweeners.Length)
        {
            UITweener ut = mTweeners[index];
            return ut && ut.enabled;
        }
        return false;
    }

    public override bool IsPause(int index)
    {
        return mPaused;
    }
    public override void Stop(string name)
    {
        if (mPaused || mTweeners == null || mTweeners.Length < 1) return;
        foreach (UITweener ut in mTweeners)
        {
            if (ut && ut.enabled && ut.name == name)
            {
                ut.ResetToInit();
                ut.enabled = false;
            }
        }
    }
}
