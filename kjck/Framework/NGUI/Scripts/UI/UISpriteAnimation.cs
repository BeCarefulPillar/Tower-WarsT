//----------------------------------------------
//            NGUI: Next-Gen UI kit
// Copyright © 2011-2014 Tasharen Entertainment
//----------------------------------------------

using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// Very simple sprite animation. Attach to a sprite and specify a common prefix such as "idle" and it will cycle through them.
/// </summary>

[ExecuteInEditMode]
[RequireComponent(typeof(UISprite))]
[AddComponentMenu("NGUI/UI/Sprite Animation")]
public class UISpriteAnimation : MonoBehaviour
{
	[HideInInspector][SerializeField] protected int mFPS = 30;
	[HideInInspector][SerializeField] protected string mPrefix = "";
	[HideInInspector][SerializeField] protected bool mLoop = true;
	[HideInInspector][SerializeField] protected bool mSnap = true;

	protected UISprite mSprite;
	protected float mDelta = 0f;
	protected int mIndex = 0;
	protected bool mActive = true;
	protected List<string> mSpriteNames = new List<string>();

    private bool waitAtlas = false;//add by kiol 2015.11.23

	/// <summary>
	/// Number of frames in the animation.
	/// </summary>

	public int frames { get { if (mSpriteNames.Count <= 0) RebuildSpriteList(); return mSpriteNames.Count; } }

	/// <summary>
	/// Animation framerate.
	/// </summary>

	public int framesPerSecond { get { return mFPS; } set { mFPS = value; } }

	/// <summary>
	/// Set the name prefix used to filter sprites from the atlas.
	/// </summary>

	public string namePrefix { get { return mPrefix; } set { if (mPrefix != value) { mPrefix = value; RebuildSpriteList(); } } }

    public bool pixelPerfect { get { return mSnap; } set { mSnap = value; } }

	/// <summary>
	/// Set the animation to be looping or not
	/// </summary>

	public bool loop { get { return mLoop; } set { mLoop = value; } }

	/// <summary>
	/// Returns is the animation is still playing or not
	/// </summary>

	public bool isPlaying { get { return mActive; } }

    public bool ignoreTimeScale = true;

	/// <summary>
	/// Rebuild the sprite list first thing.
	/// </summary>

	protected virtual void Start () { RebuildSpriteList(); }

	/// <summary>
	/// Advance the sprite animation process.
	/// </summary>

	protected virtual void Update ()
	{
        if (mActive && Application.isPlaying)
        {
            if (waitAtlas && mSprite.atlas)
            {
                RebuildSpriteList();
            }

            if (mSpriteNames.Count > 1 && mFPS > 0)
            {
                mDelta += ignoreTimeScale ? RealTime.deltaTime : Time.deltaTime;
                float rate = 1f / mFPS;

                if (rate < mDelta)
                {

                    mDelta = (rate > 0f) ? mDelta - rate : 0f;

                    if (++mIndex >= mSpriteNames.Count)
                    {
                        mIndex = 0;
                        mActive = mLoop;
                    }

                    if (mActive)
                    {
                        mSprite.spriteName = mSpriteNames[mIndex];
                        if (mSnap) mSprite.MakePixelPerfect();
                    }
                }
            }
        }
	}

	/// <summary>
	/// Rebuild the sprite list after changing the sprite name.
	/// </summary>

	public void RebuildSpriteList ()
	{
		if (mSprite == null) mSprite = GetComponent<UISprite>();
		mSpriteNames.Clear();

		if (mSprite != null && mSprite.atlas != null)
		{
            waitAtlas = false;

			List<UISpriteData> sprites = mSprite.atlas.spriteList;

			for (int i = 0, imax = sprites.Count; i < imax; ++i)
			{
				UISpriteData sprite = sprites[i];

				if (string.IsNullOrEmpty(mPrefix) || sprite.name.StartsWith(mPrefix))
				{
					mSpriteNames.Add(sprite.name);
				}
			}
			mSpriteNames.Sort();
		}
        else
        {
            waitAtlas = true;
        }
	}
	
	/// <summary>
	/// Reset the animation to the beginning.
	/// </summary>

	public void Play () { mActive = true; }

	/// <summary>
	/// Pause the animation.
	/// </summary>

	public void Pause () { mActive = false; }

	/// <summary>
	/// Reset the animation to frame 0 and activate it.
	/// </summary>

	public void ResetToBeginning ()
	{
		mActive = true;
		mIndex = 0;

		if (mSprite != null && mSpriteNames.Count > 0)
		{
			mSprite.spriteName = mSpriteNames[mIndex];
			if (mSnap) mSprite.MakePixelPerfect();
		}
	}

    public int PlayIndex { get { return mIndex; } set { mIndex = value; } }
}
