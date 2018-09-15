//NGUI Extend Copyright © 何权

using UnityEngine;
using System;
using System.Collections.Generic;
using Random = UnityEngine.Random;

public enum UIEffectFlip
{
    Nothing,
    Left,
    Right,
    Horizontally,
    Vertically,
    Both,
}

[ExecuteInEditMode]
[AddComponentMenu("Effects/UIParticle")]
public class UIParticle : UIWidget
{
    public enum SimulationSpace
    {
        Local = 0,
        World = 1,
    }
    public enum ShapeStyle
    {
        Sphere = 0,
        HemiSphere = 1,
        Cone = 2,
        Box = 3,
        Ellipsoid = 4,
    }
    public enum ValueStyle
    {
        Const = 0,
        Curve = 1,
        RandomTwoConstants = 2,
        RandomTwoCurves = 3,
    }

    public struct Particle
    {
        public Vector3 velocity;
        public Vector3 animatedVelocity;
        public Vector3 position;

        public float dampen;

        public Vector3 axisOfRotation;
        private float mAngularVelocity;
        private float mAnimatedAngularVelocity;
        private float mRotation;
        
        private float mSize;
        private float mAnimatedSize;

        public Color color;
        public Color animatedColor;

        private int mRandomSeed;

        private float mLifetime;
        private float mStartLifetime;

        private int mAnimatedFrame;

        public float lifetime { get { return mLifetime; } set { mLifetime = Mathf.Max(0f, value); } }
        public float startLifetime { get { return mStartLifetime; } set { mStartLifetime = Mathf.Max(0.05f, value); } }
        public float size { get { return mSize; } set { mSize = value; } }
        public float animatedSize { get { return mAnimatedSize; } set { mAnimatedSize = value; } }
        public int animatedFrame { get { return mAnimatedFrame; } set { mAnimatedFrame = Mathf.Max(0, value); } }
        /// <summary>
        /// 度
        /// </summary>
        public float rotation { get { return mRotation; } set { mRotation = value; } }
        /// <summary>
        /// 度
        /// </summary>
        public float animatedAngularVelocity { get { return mAnimatedAngularVelocity; } set { mAnimatedAngularVelocity = value; } }
        /// <summary>
        /// 度
        /// </summary>
        public float angularVelocity { get { return mAngularVelocity; } set { mAngularVelocity = value; } }
        public int randomSeed { get { return mRandomSeed; } set { mRandomSeed = value; } }
    }

    [Serializable]
    public class P_Float
    {
        public ValueStyle style = 0;
        public float min;
        public float max;
        public AnimationCurve minCurve;
        public AnimationCurve maxCurve;

        public P_Float(float value)
        {
            min = max = value;
            style = ValueStyle.Const;
        }

        public float EvaluateRandom(float time)
        {
            switch (style)
            {
                default:
                case ValueStyle.Const: return min;
                case ValueStyle.RandomTwoConstants: return RandomFloat(min, max);
                case ValueStyle.Curve:
                    {
                        if (minCurve != null)
                        {
                            return minCurve.Evaluate(time);
                        }
                        style = ValueStyle.Const;
                        return min;
                    }
                case ValueStyle.RandomTwoCurves:
                    if (minCurve != null && maxCurve != null)
                    {
                        return RandomFloat(minCurve.Evaluate(time), maxCurve.Evaluate(time));
                    }
                    style = ValueStyle.Const;
                    return min;
            }
        }

        public float Evaluate(float time)
        {
            switch (style)
            {
                default:
                case ValueStyle.Const: return min;
                case ValueStyle.RandomTwoConstants: return Random.Range(min, max);
                case ValueStyle.Curve:
                    {
                        if (minCurve != null)
                        {
                            return minCurve.Evaluate(time);
                        }
                        style = ValueStyle.Const;
                        return min;
                    }
                case ValueStyle.RandomTwoCurves:
                    if (minCurve != null && maxCurve != null)
                    {
                        return Random.Range(minCurve.Evaluate(time), maxCurve.Evaluate(time));
                    }
                    style = ValueStyle.Const;
                    return min;
            }
        }
    }
    [Serializable]
    public class P_Color
    {
        /// <summary>
        /// 1/else=单色 2=两单色之间 3=渐变色 4=两渐变色之间
        /// </summary>
        public ValueStyle style = ValueStyle.Const;
        public Color min;
        public Color max;
        public Gradient minCurve;
        public Gradient maxCurve;

        public P_Color(Color value)
        {
            min = max = value;
            style = ValueStyle.Const;
        }

        public Color Evaluate(float time)
        {
            switch (style)
            {
                default:
                case ValueStyle.Const: return min;
                case ValueStyle.RandomTwoConstants: return Color.Lerp(min, max, Random.Range(0f, 1f));
                case ValueStyle.Curve:
                    if (minCurve != null)
                    {
                        return minCurve.Evaluate(time);
                    }
                    style = ValueStyle.Const;
                    return min;
                case ValueStyle.RandomTwoCurves:
                    if (minCurve != null && maxCurve != null)
                    {
                        return Color.Lerp(minCurve.Evaluate(time), maxCurve.Evaluate(time), Random.Range(0f, 1f));
                    }
                    style = ValueStyle.Const;
                    return min;
            }
        }
    }
    [Serializable]
    public class EmitShape
    {
        public ShapeStyle style = ShapeStyle.Sphere;
        /// <summary>
        /// 1/else=基本由内发射 2= 基本由壳发射 3=体积由内发射 4=体积由壳发射
        /// </summary>
        public byte emitFrom = 0;
        [SerializeField] private float mAngle;
        [SerializeField] private float mRadius;
        [SerializeField] private float mLength;
        public Vector3 box;
        public bool randomDirection = false;
        public Quaternion rotation = Quaternion.identity;
        public Vector3 center = Vector3.zero;

        public float angle { get { return mAngle; } set { mAngle = Mathf.Clamp(value, 0f, 90f); } }
        public float radius { get { return mRadius; } set { mRadius = Mathf.Max(value, 0.01f); } }
        public float length { get { return mLength; } set { mLength = Mathf.Max(value, 0f); } }

        Vector3 GetRandomDirection()
        {
            float sa1 = Random.Range(0, Mathf.PI);
            float sa2 = Random.Range(0, 2 * Mathf.PI);
            return new Vector3(Mathf.Sin(sa1) * Mathf.Cos(sa2), Mathf.Sin(sa1) * Mathf.Sin(sa2), Mathf.Cos(sa1));
        }

        public void Emit(ref Particle p)
        {
            switch (style)
            {
                case ShapeStyle.Sphere:
                    float sa1 = Random.Range(0, Mathf.PI);
                    float sa2 = Random.Range(0, 2 * Mathf.PI);
                    p.velocity = new Vector3(Mathf.Sin(sa1) * Mathf.Cos(sa2), Mathf.Sin(sa1) * Mathf.Sin(sa2), Mathf.Cos(sa1));
                    switch (emitFrom)
                    {
                        default:
                        case 1:
                        case 2:
                            p.position = Vector3.zero;
                        break;
                        case 3:
                            p.position = p.velocity * radius * Mathf.Sqrt(Random.Range(0f, 1f));
                            if (randomDirection) p.velocity = GetRandomDirection();
                            break;
                        case 4:
                            p.position = p.velocity * radius;
                            if (randomDirection) p.velocity = GetRandomDirection();
                            break;
                    }
                    break;
                case ShapeStyle.HemiSphere:
                    float ha1 = Random.Range(0, Mathf.PI);
                    float ha2 = Random.Range(0, 2 * Mathf.PI);
                    p.velocity = new Vector3(Mathf.Sin(ha1) * Mathf.Cos(ha2), Mathf.Sin(ha1) * Mathf.Sin(ha2 > Mathf.PI ? ha2 - Mathf.PI : ha2), Mathf.Cos(ha1));
                    switch (emitFrom)
                    {
                        default:
                        case 1:
                        case 2:
                            p.position = Vector3.zero;
                            break;
                        case 3:
                            p.position = p.velocity * radius * Mathf.Sqrt(Random.Range(0f, 1f));
                            if (randomDirection) p.velocity = GetRandomDirection();
                            break;
                        case 4:
                            p.position = p.velocity * radius;
                            if (randomDirection) p.velocity = GetRandomDirection();
                            break;
                    }
                    break;
                case ShapeStyle.Cone:
                    float a = Random.Range(0, 2 * Mathf.PI);
                    Vector3 rpos = new Vector3(Mathf.Cos(a), 0f, Mathf.Sin(a));
                    switch (emitFrom)
                    {
                        default:
                        case 1:
                            rpos *= Mathf.Sqrt(Random.Range(0f, 1f));
                            p.velocity = randomDirection ? GetRandomDirection() : (rpos * Mathf.Tan(angle * Mathf.Deg2Rad) * length + new Vector3(0f, length, 0f)).normalized;
                            p.position = rpos * radius;
                            break;
                        case 2:
                            p.velocity = randomDirection ? GetRandomDirection() : (rpos * Mathf.Tan(angle * Mathf.Deg2Rad) * length + new Vector3(0f, length, 0f)).normalized;
                            p.position = rpos * radius;
                            break;
                        case 3:
                            float rh3 = Random.Range(0f, 1f) * length;
                            rpos *= Mathf.Sqrt(Random.Range(0f, 1f));
                            p.position = rpos * (Mathf.Tan(angle * Mathf.Deg2Rad) * rh3 + radius) + new Vector3(0f, rh3, 0f);
                            p.velocity = randomDirection ? GetRandomDirection() : (p.position - rpos * radius).normalized;
                            break;
                        case 4:
                            float rh4 = Random.Range(0f, 1f) * length;
                            p.position = rpos * (Mathf.Tan(angle * Mathf.Deg2Rad) * rh4 + radius) + new Vector3(0f, rh4, 0f);
                            p.velocity = randomDirection ? GetRandomDirection() : (p.position - rpos * radius).normalized;
                            break;
                    }
                    break;
                case ShapeStyle.Box:
                    Vector3 pos = new Vector3(Random.Range(0, box.x), Random.Range(0, box.y), Random.Range(0, box.z)) - box * 0.5f;
                    switch (emitFrom)
                    {
                        default:
                        case 1:
                        case 3:
                            p.position = pos;
                            p.velocity = randomDirection ? GetRandomDirection() : Vector3.up;
                            break;
                        case 2:
                        case 4:
                            switch (Random.Range(0, 6))
                            {
                                case 0: pos.x = -box.x * 0.5f; break;
                                case 1: pos.x = box.x * 0.5f; break;
                                case 2: pos.y = -box.y * 0.5f; break;
                                case 3: pos.y = box.y * 0.5f; break;
                                case 4: pos.z = -box.z * 0.5f; break;
                                case 5: pos.z = box.z * 0.5f; break;
                            }
                            p.position = pos;
                            p.velocity = randomDirection ? GetRandomDirection() : Vector3.up;
                            break;
                    }
                    break;
                case ShapeStyle.Ellipsoid:
                    float ea1 = Random.Range(0, Mathf.PI);
                    float ea2 = Random.Range(0, 2 * Mathf.PI);
                    if (box.x == 0) { ea1 = ea2; ea2 = Mathf.PI * 0.5f; }
                    else if (box.y == 0) { ea1 = ea2; ea2 = 0f; }
                    else if (box.z == 0) { ea1 = Mathf.PI * 0.5f; }
                    p.velocity = new Vector3(Mathf.Sin(ea1) * Mathf.Cos(ea2) * box.x * 0.5f, Mathf.Sin(ea1) * Mathf.Sin(ea2) * box.y * 0.5f, Mathf.Cos(ea1) * box.z * 0.5f);
                    switch (emitFrom)
                    {
                        default:
                        case 1:
                        case 2:
                            p.position = Vector3.zero;
                        break;
                        case 3:
                            p.position = p.velocity * Mathf.Sqrt(Random.Range(0f, 1f));
                            if (randomDirection) p.velocity = GetRandomDirection();
                            break;
                        case 4:
                            p.position = p.velocity;
                            if (randomDirection) p.velocity = GetRandomDirection();
                            break;
                    }
                    p.velocity = randomDirection ? GetRandomDirection() : p.velocity.normalized;
                    break;
            }
            //
            p.velocity = rotation * p.velocity;
            p.position = rotation * p.position + center;
        }
    }

    private static readonly System.Random _random = new System.Random();

    private static float RandomFloat(float min, float max)
    {
        return min < max ? (float)(_random.NextDouble() * (max - min)) + min : min;
    }

    //资源显示属性
    [HideInInspector][SerializeField] UIAtlas mAtlas;
    [HideInInspector][SerializeField] string mSpriteName;
    [HideInInspector][SerializeField] Texture mTex;
	[HideInInspector][SerializeField] Shader mShader;
    [HideInInspector][SerializeField] UIEffectFlip mFlip = UIEffectFlip.Nothing;
    
    //基础属性
    [SerializeField] public bool isStretched  = false;
    [SerializeField] public float lengthScale = 1f;
    [SerializeField] public float speedScale = 0f;
    [SerializeField] float mDuration = 1f;
    [SerializeField] public bool loop = true;
    [SerializeField] public bool ignoreTimeScale = false;
    [SerializeField] public bool isActualBounds = false;
    [SerializeField] float mStartDelay = 0f;
    [SerializeField] P_Float mStartLifeTime = new P_Float(1f);
    [SerializeField] P_Float mStartSpeed = new P_Float(1f);
    [SerializeField] P_Float mStartSize = new P_Float(1f);
    [SerializeField] P_Float mStartRotation = new P_Float(0f);
    [SerializeField] P_Color mStartColor = new P_Color(Color.white);

    [SerializeField] float mgGravityModifier = 0f;
    [SerializeField] float mInheritVelocity = 0f;
    [SerializeField] Transform mRelative;
    [SerializeField] bool mPlayOnAwake = true;
    [SerializeField] bool mAutoDestroy = false;
    [SerializeField] int mMaxParticles = 100;

    //发射属性
    [SerializeField] bool mEnableEmit = true;
    [SerializeField] public bool isEmitCurveRate = false;
    [SerializeField] int mEmitRateConst = 10;
    [SerializeField] AnimationCurve mEmitRate;
    [SerializeField] float[] mBurstsTime;
    [SerializeField] int[] mBurstsParticles;

    //发射形状
    [SerializeField] public bool hasShape = true;
    [SerializeField] EmitShape mShape;

    //速度随生命周期
    [SerializeField] public bool hasVelocityByLife= false;
    [SerializeField] P_Float[] mVelocityByLife = new P_Float[3];

    //极限速度随生命周期
    [SerializeField] public bool hasLimitVelocityByLife= false;
    [SerializeField] P_Float[] mLimitVelocityByLife = new P_Float[3];
    [SerializeField] [Range(0f, 1f)] private float mLimitVelocityDampen = 1f;

    //力随生命周期
    [SerializeField] public bool hasForceByLife = false;
    [SerializeField] public bool forceRandomize = false;
    [SerializeField] P_Float[] mForceByLife = new P_Float[3];

    //颜色随生命周期
    [SerializeField] public bool hasColorByLife = false;
    [SerializeField] P_Color mColorByLife;

    //大小随生命周期
    [SerializeField] public bool hasSizeByLife = false;
    [SerializeField] P_Float mSizeByLife;

    //旋转随生命周期
    [SerializeField] public bool hasRotationByLife = false;
    [SerializeField] P_Float mRotationByLife;

    //帧动画
    [SerializeField] public bool hasFrameAnimation = false;
    [SerializeField] int mTilesX = 1;
    [SerializeField] int mTilesY = 1;
    [SerializeField] int mCycles = 1;
    [SerializeField] P_Float mFrameOverLifeTime;

    //粒子漩涡
    [SerializeField] public bool hasSwirl = false;
    [SerializeField] public Vector3 swirlCenter = Vector3.zero;
    [SerializeField] public Vector3 swirlAxis = Vector3.forward;
    [SerializeField] public float swirlRadius = 1f;
    [SerializeField] public float swirlAngularSpeed = 1f;
    [SerializeField] public float swirlSuckSpeed = 1f;
    [SerializeField] public float swirlDampen = 0.1f;

    //运行时字段
    [NonSerialized] List<Particle> mParticles = new List<Particle>(2);
    [NonSerialized] Vector3 lastPos = Vector3.zero;
    [NonSerialized] Vector3 mMove = Vector3.zero;
    [NonSerialized] Matrix4x4 ltr;
    [NonSerialized] Matrix4x4 rtl;
    [NonSerialized] int lastSimulateFrame = 0;
    [NonSerialized] float mTime = 0f;
    [NonSerialized] float emitTime = 0f;
    [NonSerialized] int burstIndex = 0;
    [NonSerialized] bool mPlay = false;
    [NonSerialized] bool mPause = false;
    [NonSerialized] Vector2[,] mUV;
    [NonSerialized] Vector3 pos_min;
    [NonSerialized] Vector3 pos_max;

    public List<Particle> Particles { get { return mParticles; } }

    public float duration { get { return mDuration; } set { mDuration = Mathf.Max(0.1f, value); } }
    public float startDelay { get { return mStartDelay; } set { mStartDelay = Mathf.Max(0, value); } }
    public P_Float startLifetime { get { return mStartLifeTime; } }
    public P_Float startSpeed { get { return mStartSpeed; } }
    public P_Float startSize { get { return mStartSize; } }
    public P_Float startRotation { get { return mStartRotation; } }
    public P_Color startColor { get { return mStartColor; } }
    public Transform Relative
    {
        get { return mRelative; }
        set
        {
            if (mRelative != value)
            {
                mRelative = value;
                Matrix4x4 ltr = Relative ? Relative.worldToLocalMatrix * cachedTransform.localToWorldMatrix : cachedTransform.localToWorldMatrix;
                Matrix4x4 rtl = Relative ? cachedTransform.worldToLocalMatrix * Relative.localToWorldMatrix : cachedTransform.worldToLocalMatrix;

                Matrix4x4 rtr = this.rtl * ltr;

                this.ltr = ltr;
                this.rtl = rtl;

                lastPos = rtr.MultiplyPoint3x4(cachedTransform.localPosition);
                mMove = rtr.MultiplyVector(mMove);
                int cnt = particleCount;
                for (int i = 0; i < cnt; i++)
                {
                    Particle p = mParticles[i];
                    p.position = rtr.MultiplyPoint3x4(p.position);
                    mParticles[i] = p;
                }
            }
        }
    }
    public float gravityModifier { get { return mgGravityModifier; } set { mgGravityModifier = value; } }
    public float inheritVelocity { get { return mInheritVelocity; } set { mInheritVelocity = value; } }
    public bool playOnAwake { get { return mPlayOnAwake; } set { mPlayOnAwake = value; } }
    public bool autoDestroy { get { return mAutoDestroy; } set { mAutoDestroy = value; } }
    public int maxParticles { get { return mMaxParticles; } set { mMaxParticles = Mathf.Max(0, value); } }

    public bool enableEmission { get { return mEnableEmit; } set { mEnableEmit = value; } }
    public int emissionRateConst { get { return mEmitRateConst; } set { mEmitRateConst = Mathf.Max(0, value); } }
    public AnimationCurve emissionRate { get { return mEmitRate; } set { mEmitRate = value; } }

    public EmitShape shape { get { return mShape; } }
    public P_Float[] velocityByLife { get { if (mVelocityByLife.GetLength() < 3)mVelocityByLife = new P_Float[3]; return mVelocityByLife; } }
    public P_Float[] limitVelocityByLife { get { if (mLimitVelocityByLife.GetLength() < 3)mLimitVelocityByLife = new P_Float[3]; return mLimitVelocityByLife; } }
    public float limitVelocityDampen { get { return mLimitVelocityDampen; } set { mLimitVelocityDampen = Mathf.Clamp01(value); } }
    public P_Float[] forceByLife { get { if (mForceByLife.GetLength() < 3)mForceByLife = new P_Float[3]; return mForceByLife; } }
    public P_Color colorByLife { get { return mColorByLife; } }
    public P_Float sizeByLife { get { return mSizeByLife; } }
    public P_Float rotationByLife { get { return mRotationByLife; } }
    public int tilesX { get { return mTilesX; } set { value = Mathf.Max(1, value); if (mTilesX != value) { mTilesX = value; mUV = null; } } }
    public int tilesY { get { return mTilesY; } set { value = Mathf.Max(1, value); if (mTilesY != value) { mTilesY = value; mUV = null; } } }
    public int cycles { get { return mCycles; } set { mCycles = Mathf.Max(1, value); } }
    public P_Float frameOverLifeTime { get { return mFrameOverLifeTime; } }

    public Matrix4x4 localToRelative { get { return ltr; } }
    public Matrix4x4 relativeToLocal { get { return rtl; } }

    public float time { get { return mTime; } }
    public bool isPaused { get { return mPause; } }
    public bool isPlaying { get { return mPlay && !mPause; } }
    public bool isStopped { get { return !mPlay; } }

    public int particleCount { get { return mParticles.Count; } }

    private void EachChild(Action<UIParticle> action)
    {
        if (cachedGameObject.activeInHierarchy)
        {
            for (int i = 0; i < mChildren.size; i++)
            {
                UIParticle up = mChildren[i] as UIParticle;
                if (up)
                {
                    action(up);
                }
            }
        }
        else
        {
            mTrans = cachedTransform;
            for (int i = 0; i < mTrans.childCount; i++)
            {
                UIParticle up = mTrans.GetChild(i).GetComponent<UIParticle>();
                if (up)
                {
                    action(up);
                }
            }
        }
    }

    public void Clear(bool withChildren = true)
    {
        mParticles.Clear();
        if (withChildren)
        {
            EachChild(up => { up.Clear(withChildren); });
        }
    }
    public void Emit(int count, bool withChildren = false)
    {
        count = Mathf.Min(count, maxParticles - particleCount);
        for (int i = 0; i < count; i++)
        {
            mParticles.Add(GenParticle(ignoreTimeScale ? RealTime.deltaTime  :Time.deltaTime));
        }
        if (withChildren)
        {
            EachChild(up => { up.Emit(count, true); });
        }
    }
    //public void Emit(Vector3 position, Vector3 velocity, float size, float lifetime, Color32 color)
    //{
    //    if (maxParticles - particleCount > 0)
    //    {
            
    //    }
    //}
    public void Play(bool withChildren = true)
    {
        if (!mPlay)
        {
            mPlay = true;
            mTime = 0f;
            burstIndex = 0;
            emitTime = 0f;
        }
        mPause = false;

        if (withChildren)
        {
            EachChild(up => { up.Play(withChildren); });
        }
    }
    public void Pause(bool withChildren = true)
    {
        mPause = true;

        if (withChildren)
        {
            EachChild(up => { up.Pause(withChildren); });
        }
    }
    public void Stop(bool withChildren = true)
    {
        mPlay = false;
        mPause = false;
        mTime = 0f;
        burstIndex = 0;
        emitTime = 0f;

        if (withChildren)
        {
            EachChild(up => { up.Stop(withChildren); });
        }
    }
    public void Replay(bool withChildren = true)
    {
        mPlay = true;
        mPause = false;
        mTime = 0f;
        burstIndex = 0;
        emitTime = 0f;

        if (withChildren)
        {
            EachChild(up => { up.Replay(withChildren); });
        }
    }

    public void Simulate(float t, bool withChildren = true)
    {
        int frame = Time.frameCount;
        //if (Application.isPlaying && frame == lastSimulateFrame) return;
        if (frame == lastSimulateFrame) return;
        lastSimulateFrame = frame;
        
        if (withChildren)
        {
            for (int i = 0; i < mChildren.size; i++)
            {
                UIParticle up = mChildren[i] as UIParticle;
                if (up) up.Simulate(t, withChildren);
            }
        }

        int cnt = particleCount;
        if (mPlay)
        {
            float pt = mTime - startDelay;
            if (pt < 0) { mTime += t; return; }
            if (!loop && pt > duration)
            {
                if (cnt <= 0)
                {
                    Stop(false);
#if UNITY_EDITOR
                    if (autoDestroy && Application.isPlaying) Destroy(gameObject);
#else
                    if (autoDestroy) Destroy(gameObject);
#endif
                    
                }
            }
            else if (mEnableEmit)
            {
                emitTime += t;
                float emitRate = (isEmitCurveRate && mEmitRate != null) ? mEmitRate.Evaluate(MathEx.FlotPart(pt)) : mEmitRateConst;
                int emitCnt = Mathf.RoundToInt(emitTime * emitRate);
                emitTime -= emitRate > 0 ? emitCnt / emitRate : 0;

                int blen = mBurstsTime.GetLength();
                if (blen > 0)
                {
                    if (burstIndex < blen)
                    {
                        if (mBurstsTime[burstIndex] <= MathEx.FlotPart(pt / duration) * duration)
                        {
                            emitCnt += mBurstsParticles[burstIndex++];
                        }
                    }
                    else if (MathEx.FlotPart(pt / duration) * duration > MathEx.FlotPart((pt + t) / duration) * duration)
                    {
                        burstIndex = 0;
                    }
                }

                emitCnt = Mathf.Min(emitCnt, maxParticles - cnt);
                for (int i = 0; i < emitCnt; i++)
                {
                    mParticles.Add(GenParticle(t));
                    cnt++;
                }
            }
            mTime += t;
        }

        if (cnt > 0)
        {
            //mParticles.Sort(SortParticles);
            mChanged = true;
        }

        int uvCnt = mUV != null ? mUV.GetLength(0): 1;

        for (int i = 0; i < cnt; i++)
        {
            Particle p = mParticles[i];
            if (p.lifetime <= 0)
            {
                mParticles.RemoveAt(i);
                i--;
                cnt--;
                continue;
            }

            float tr = 1f - Mathf.Clamp01(p.lifetime / p.startLifetime);

            p.lifetime -= t;

            p.velocity.y -= gravityModifier * t;

            Random.InitState(p.randomSeed);

            if (hasForceByLife && mForceByLife != null)
            {
                if (forceRandomize)
                {
                    p.velocity += new Vector3(mForceByLife[0].EvaluateRandom(tr), mForceByLife[1].EvaluateRandom(tr), mForceByLife[2].EvaluateRandom(tr)) * t;
                }
                else
                {
                    p.velocity += new Vector3(mForceByLife[0].Evaluate(tr), mForceByLife[1].Evaluate(tr), mForceByLife[2].Evaluate(tr)) * t;
                }
            }

            if (hasVelocityByLife && mVelocityByLife != null)
            {
                p.animatedVelocity = new Vector3(mVelocityByLife[0].Evaluate(tr), mVelocityByLife[1].Evaluate(tr), mVelocityByLife[2].Evaluate(tr));
            }
            else
            {
                p.animatedVelocity = Vector3.zero;
            }

            if (hasColorByLife && mColorByLife != null)
            {
                p.animatedColor = mColorByLife.Evaluate(tr);
            }

            if (hasSizeByLife && mSizeByLife != null)
            {
                p.animatedSize = mSizeByLife.Evaluate(tr);
            }
            else
            {
                p.animatedSize = 1f;
            }

            if (hasRotationByLife && mRotationByLife != null)
            {
                p.animatedAngularVelocity = mRotationByLife.Evaluate(tr);
            }

            if (hasFrameAnimation && mFrameOverLifeTime != null)
            {
                float ctr = tr * mCycles;
                p.animatedFrame = Mathf.RoundToInt(mFrameOverLifeTime.Evaluate(ctr - (int)ctr)) % uvCnt;
            }
            else
            {
                p.animatedFrame = 0;
            }

            if (hasSwirl && swirlRadius > 0f && swirlAxis != Vector3.zero)
            {
                Vector3 dre = rtl.MultiplyPoint3x4(p.position) - swirlCenter;
                float dis = dre.magnitude;
                if (dis <= swirlRadius)
                {
                    float dv = Mathf.Pow(dis / swirlRadius, swirlDampen);
                    p.animatedVelocity = (p.animatedVelocity + (Quaternion.AngleAxis((p.startLifetime - p.lifetime) * swirlAngularSpeed * t, swirlAxis) * dre - dre) / t) * dv;
                    p.velocity = (p.velocity - dre.normalized * swirlSuckSpeed * t) * dv;
                }
            }

            if (hasLimitVelocityByLife && mLimitVelocityByLife != null)
            {
                p.dampen = 1f - (1 - p.dampen) * Mathf.Pow(1 - mLimitVelocityDampen, t * 52f);
                Vector3 v = p.velocity + p.animatedVelocity;
                v.x += (mLimitVelocityByLife[0].Evaluate(tr) - v.x) * p.dampen;
                v.y += (mLimitVelocityByLife[1].Evaluate(tr) - v.y) * p.dampen;
                v.z += (mLimitVelocityByLife[2].Evaluate(tr) - v.z) * p.dampen;
                
                p.position += ltr.MultiplyVector(v * t);
            }
            else
            {
                p.position += ltr.MultiplyVector((p.velocity + p.animatedVelocity) * t);
            }

            p.rotation += (p.angularVelocity + p.animatedAngularVelocity) * t;

            mParticles[i] = p;
        }

        Random.InitState(_random.Next());
    }
    private int SortParticles(Particle x, Particle y)
    {
        return y.position.z - x.position.z > 0 ? 1 : -1;
    }
    private Particle GenParticle(float t)
    {
        Particle p = new Particle();
        float pst = MathEx.FlotPart(Mathf.Max(0, mTime - startDelay));
        p.startLifetime = p.lifetime = startLifetime.Evaluate(pst);
        p.randomSeed = Random.Range(int.MinValue, int.MaxValue);
        p.rotation = startRotation.Evaluate(pst);
        p.size = startSize.Evaluate(pst);
        p.color = startColor.Evaluate(pst);
        p.animatedColor = Color.white;
        if (hasShape && mShape != null)
        {
            mShape.Emit(ref p);
        }
        else
        {
            p.position = Vector3.zero;
            float a1 = Random.Range(0, Mathf.PI);
            float a2 = Random.Range(0, 2 * Mathf.PI);
            p.velocity = new Vector3(Mathf.Sin(a1) * Mathf.Cos(a2), Mathf.Sin(a1) * Mathf.Sin(a2), Mathf.Cos(a1));
        }
        p.velocity = p.velocity * startSpeed.Evaluate(pst) + inheritVelocity * mMove / t;
        p.angularVelocity = 0;
        p.axisOfRotation = Vector3.back;
        p.position = ltr.MultiplyPoint3x4(p.position);
        return p;
    }

    private void CheckMove()
    {
        ltr = Relative ? Relative.worldToLocalMatrix * cachedTransform.localToWorldMatrix : cachedTransform.localToWorldMatrix;
        rtl = Relative ? cachedTransform.worldToLocalMatrix * Relative.localToWorldMatrix : cachedTransform.worldToLocalMatrix;
        Vector3 pos = ltr.MultiplyPoint3x4(cachedTransform.localPosition);
        mMove = rtl.MultiplyVector(pos - lastPos);
        lastPos = pos;
    }

    protected override void OnStart()
    {
        base.OnStart();
        if (playOnAwake) Play();
    }

    protected override void OnEnable()
    {
        ltr = Relative ? Relative.worldToLocalMatrix * cachedTransform.localToWorldMatrix : cachedTransform.localToWorldMatrix;
        rtl = Relative ? cachedTransform.worldToLocalMatrix * Relative.localToWorldMatrix : cachedTransform.worldToLocalMatrix;
        mMove = Vector3.zero;
        lastPos = ltr.MultiplyPoint3x4(cachedTransform.localPosition);
        base.OnEnable();
    }

    /// <summary>
    /// Local space corners of the widget. The order is bottom-left, top-left, top-right, bottom-right.
    /// </summary>
    public override Vector3[] localCorners
    {
        get
        {
            if (isActualBounds)
            {
                mCorners[0] = new Vector3(pos_min.x, pos_min.y);
                mCorners[1] = new Vector3(pos_min.x, pos_max.y);
                mCorners[2] = new Vector3(pos_max.x, pos_max.y);
                mCorners[3] = new Vector3(pos_max.x, pos_min.y);
                return mCorners;
            }
            return base.localCorners;
        }
    }
    /// <summary>
    /// World-space corners of the widget. The order is bottom-left, top-left, top-right, bottom-right.
    /// </summary>
    public override Vector3[] worldCorners
    {
        get
        {
            if (isActualBounds)
            {
                Transform wt = cachedTransform;
                mCorners[0] = wt.TransformPoint(pos_min.x, pos_min.y, 0f);
                mCorners[1] = wt.TransformPoint(pos_min.x, pos_max.y, 0f);
                mCorners[2] = wt.TransformPoint(pos_max.x, pos_max.y, 0f);
                mCorners[3] = wt.TransformPoint(pos_max.x, pos_min.y, 0f);
                return mCorners;
            }
            return base.worldCorners;
        }
    }

#if UNITY_EDITOR
    private void LateUpdate()
    {
        if (Application.isPlaying)
        {
            CheckMove();
            if (!isPaused) Simulate(ignoreTimeScale ? RealTime.deltaTime : Time.deltaTime);
        }
    }
#if TOLUA
    [LuaInterface.NoToLua]
#endif
    public void OnEditorUpdate(float deltaTime)
    {
        if (!Application.isPlaying)
        {
            CheckMove();
            if (!isPaused) Simulate(deltaTime);
            if (mChanged) UnityEditor.EditorUtility.SetDirty(this);
            for (int i = 0; i < mChildren.size; i++)
            {
                UIParticle p = mChildren[i] as UIParticle;
                if (p) p.OnEditorUpdate(deltaTime);
            }
        }
    }
#else
    private void LateUpdate()
    {
        CheckMove();
        if (!isPaused) Simulate(ignoreTimeScale ? RealTime.deltaTime  :Time.deltaTime);
    }
#endif

    public override bool canBeAnchored { get { return false; } }

    public UIAtlas atlas
    {
        get { return mAtlas; }
        set
        {
            if (mAtlas != value)
            {
                RemoveFromPanel();

                mAtlas = value;
                mUV = null;
            }
        }
    }

    public string spriteName
    {
        get
        {
            return mSpriteName;
        }
        set
        {
            if (string.IsNullOrEmpty(value))
            {
                if (string.IsNullOrEmpty(mSpriteName)) return;

                mSpriteName = "";
                mUV = null;
                mChanged = true;
            }
            else if (mSpriteName != value)
            {
                mSpriteName = value;
                mUV = null;
                mChanged = true;
            }
        }
    }

    public override Texture mainTexture
    {
        get
        {
            Material mat = material;
            return mat ? mat.mainTexture : mTex;
        }
        set
        {
            if (!mAtlas && mTex != value)
            {
                if (drawCall != null && drawCall.widgetCount == 1 && mMat == null)
                {
                    mTex = value;
                    drawCall.mainTexture = value;
                }
                else
                {
                    RemoveFromPanel();
                    mTex = value;
                    mUV = null;
                    MarkAsChanged();
                }
            }
        }
    }

    public override Material material
    {
        get
        {
            return mAtlas ? mAtlas.spriteMaterial : mMat;
        }
        set
        {
            if (mAtlas) return;
            if (!mAtlas && mMat != value)
            {
                RemoveFromPanel();
                mShader = null;
                mMat = value;
                mUV = null;
                MarkAsChanged();
            }
        }
    }

    public override Shader shader
    {
        get
        {
            Material mat = material;
            if (mat) return mat.shader;
            if (mShader == null) mShader = Shader.Find("Particles/Additive");
            return mShader;
        }
        set
        {
            if (mShader != value)
            {
                if (mAtlas && mAtlas.spriteMaterial)
                {
                    mAtlas.spriteMaterial.shader = value;
                    RemoveFromPanel();
                    MarkAsChanged();
                }
                else if (drawCall != null && drawCall.widgetCount == 1 && mMat == null)
                {
                    mShader = value;
                    drawCall.shader = value;
                }
                else
                {
                    RemoveFromPanel();
                    mShader = value;
                    mMat = null;
                    MarkAsChanged();
                }
            }
        }
    }

    public UIEffectFlip flip
    {
        get { return mFlip; }
        set
        {
            if (mFlip != value)
            {
                mFlip = value;
                mUV = null;
                mChanged = true;
            }
        }
    }

    public void FlipHorizontal(bool withChild = true)
    {
        if (mFlip == UIEffectFlip.Nothing)
        {
            mFlip = UIEffectFlip.Horizontally;
        }
        else if (mFlip == UIEffectFlip.Left)
        {
            mFlip = UIEffectFlip.Right;
        }
        else if (mFlip == UIEffectFlip.Right)
        {
            mFlip = UIEffectFlip.Left;
        }
        else if (mFlip == UIEffectFlip.Horizontally)
        {
            mFlip = UIEffectFlip.Nothing;
        }
        else if (mFlip == UIEffectFlip.Vertically)
        {
            mFlip = UIEffectFlip.Both;
        }
        else if (mFlip == UIEffectFlip.Both)
        {
            mFlip = UIEffectFlip.Vertically;
        }

        if (withChild)
        {
            for (int i = 0; i < mChildren.size; i++)
            {
                UIParticle up = mChildren[i] as UIParticle;
                if (up) up.FlipHorizontal(withChild);
            }
        }
    }

    public void GenUV()
    {
        mUV = null;
        Texture tex = mainTexture;
        if (!tex) return;

        int uv0 = 0, uv1 = 1, uv2 = 2, uv3 = 3;
        if (flip == UIEffectFlip.Left) { uv0 = 1; uv1 = 2; uv2 = 3; uv3 = 0; }
        else if (flip == UIEffectFlip.Right) { uv0 = 3; uv1 = 0; uv2 = 1; uv3 = 2; }
        else if (flip == UIEffectFlip.Horizontally) { uv0 = 3; uv1 = 2; uv2 = 1; uv3 = 0; }
        else if (flip == UIEffectFlip.Vertically) { uv0 = 1; uv1 = 0; uv2 = 3; uv3 = 2; }
        else if (flip == UIEffectFlip.Both) { uv0 = 2; uv1 = 3; uv2 = 0; uv3 = 1; }

        if (atlas)
        {
            if (hasFrameAnimation)
            {
                List<UISpriteData> sprites = new List<UISpriteData>();
                int cnt = atlas.spriteList.Count;
                for (int i = 0; i < cnt; i++)
                {
                    UISpriteData sprite = atlas.spriteList[i];
                    if (string.IsNullOrEmpty(mSpriteName) || sprite.name.StartsWith(mSpriteName))
                    {
                        sprites.Add(sprite);
                    }
                }

                cnt = sprites.Count;
                if (cnt > 0)
                {
                    mUV = new Vector2[cnt, 4];
                    sprites.Sort((x, y) => { return string.Compare(x.name, y.name); });
                    for (int i = 0; i < cnt; i++)
                    {
                        UISpriteData sprite = sprites[i];
                        Rect outer = NGUIMath.ConvertToTexCoords(new Rect(sprite.x, sprite.y, sprite.width, sprite.height), tex.width, tex.height);
                        mUV[i, uv0] = new Vector2(outer.xMin, outer.yMin);
                        mUV[i, uv1] = new Vector2(outer.xMin, outer.yMax);
                        mUV[i, uv2] = new Vector2(outer.xMax, outer.yMax);
                        mUV[i, uv3] = new Vector2(outer.xMax, outer.yMin);
                    }
                }
            }
            else
            {
                UISpriteData sprite = atlas.GetSprite(spriteName);
                if (sprite != null)
                {
                    Rect outer = new Rect(sprite.x, sprite.y, sprite.width, sprite.height);
                    outer = NGUIMath.ConvertToTexCoords(outer, tex.width, tex.height);
                    mUV = new Vector2[1, 4];
                    mUV[0, uv0] = new Vector2(outer.xMin, outer.yMin);
                    mUV[0, uv1] = new Vector2(outer.xMin, outer.yMax);
                    mUV[0, uv2] = new Vector2(outer.xMax, outer.yMax);
                    mUV[0, uv3] = new Vector2(outer.xMax, outer.yMin);
                }
            }
        }
        else
        {
            if (hasFrameAnimation)
            {
                int cnt = mTilesX * mTilesY;
                if (cnt > 0)
                {
                    float dx = 1f / mTilesX, dy = 1f / mTilesY;
                    int ty = mTilesY - 1;
                    mUV = new Vector2[cnt, 4];
                    for (int i = 0; i < mTilesY; i++)
                    {
                        float y = (ty - i) * dy; 
                        for (int j = 0; j < mTilesX; j++)
                        {
                            float x = j * dx;
                            int idx = i * mTilesX + j;
                            mUV[idx, uv0] = new Vector2(x, y);
                            mUV[idx, uv1] = new Vector2(x, y + dy);
                            mUV[idx, uv2] = new Vector2(x + dx, y + dy);
                            mUV[idx, uv3] = new Vector2(x + dx, y);
                        }
                    }
                }
            }
            else
            {
                mUV = new Vector2[1, 4];
                mUV[0, uv0] = new Vector2(0f, 0f);
                mUV[0, uv1] = new Vector2(0f, 1f);
                mUV[0, uv2] = new Vector2(1f, 1f);
                mUV[0, uv3] = new Vector2(1f, 0f);
            }
        }

        if (mUV == null) return;
        int nvMaxIdx = mUV.GetLength(0) - 1;
        if (nvMaxIdx < 0) return;
        int pCnt = particleCount;
        if (pCnt < 1) return;
        for (int i = 0; i < pCnt; i++)
        {
            Particle p = mParticles[i];
            p.animatedFrame = Mathf.Clamp(p.animatedFrame, 0, nvMaxIdx);
            mParticles[i] = p;
        }
    }
    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        int cnt = particleCount;
        if (cnt <= 0) return;
        Texture tex = mainTexture;
        if (tex == null) return;

        if (mUV == null) GenUV();
        if (mUV == null) return;
        
        Color colF = color;
        colF.a = finalAlpha;

        Matrix4x4 matrix = Matrix4x4.identity;
        Vector3 pr = cachedTransform.eulerAngles;

        int offset = verts.Count;

        if (isStretched)
        {
            Vector2 size = new Vector2(width * lengthScale, height * 0.5f);

            for (int i = 0; i < cnt; i++)
            {
                Particle p = mParticles[i];
                Vector3 v = p.velocity + p.animatedVelocity;

                /*******************************/
                //matrix.SetTRS(p.position, Quaternion.Euler(-pr) * Quaternion.FromToRotation(Vector3.right, v), Vector3.one * p.size * p.animatedSize);
                //float vs = v.magnitude * speedScale;
                //v3.x += vs; v4.x += vs;

                //verts.Add(matrix.MultiplyPoint3x4(v1));
                //verts.Add(matrix.MultiplyPoint3x4(v2));
                //verts.Add(matrix.MultiplyPoint3x4(v3));
                //verts.Add(matrix.MultiplyPoint3x4(v4));
                ///////////

                /*******************************/
                Vector3 vd = v.normalized * size.x + v * speedScale;
                Vector3 vv = new Vector3(-v.y, v.x).normalized * size.y;

                matrix.SetTRS(rtl.MultiplyPoint3x4(p.position), Quaternion.identity, Vector3.one * p.size * p.animatedSize);

                verts.Add(matrix.MultiplyPoint3x4(-vv));
                verts.Add(matrix.MultiplyPoint3x4(vv));
                verts.Add(matrix.MultiplyPoint3x4(vd + vv));
                verts.Add(matrix.MultiplyPoint3x4(vd - vv));
                ///////////

                uvs.Add(mUV[p.animatedFrame, 0]);
                uvs.Add(mUV[p.animatedFrame, 1]);
                uvs.Add(mUV[p.animatedFrame, 2]);
                uvs.Add(mUV[p.animatedFrame, 3]);

                Color c = p.color * p.animatedColor * colF;
                cols.Add(c);
                cols.Add(c);
                cols.Add(c);
                cols.Add(c);
            }
        }
        else
        {
            Vector2 halfSize = new Vector2(width, height) * 0.5f;
            Vector3 v1 = new Vector3(-halfSize.x, -halfSize.y);
            Vector3 v2 = new Vector3(-halfSize.x, halfSize.y);
            Vector3 v3 = new Vector3(halfSize.x, halfSize.y);
            Vector3 v4 = new Vector3(halfSize.x, -halfSize.y);

            for (int i = 0; i < cnt; i++)
            {
                Particle p = mParticles[i];
                matrix.SetTRS(rtl.MultiplyPoint3x4(p.position), Quaternion.Euler(-pr.x, -pr.y, -p.rotation - pr.z), Vector3.one * p.size * p.animatedSize);

                verts.Add(matrix.MultiplyPoint3x4(v1));
                verts.Add(matrix.MultiplyPoint3x4(v2));
                verts.Add(matrix.MultiplyPoint3x4(v3));
                verts.Add(matrix.MultiplyPoint3x4(v4));

                uvs.Add(mUV[p.animatedFrame, 0]);
                uvs.Add(mUV[p.animatedFrame, 1]);
                uvs.Add(mUV[p.animatedFrame, 2]);
                uvs.Add(mUV[p.animatedFrame, 3]);

                Color c = p.color * p.animatedColor * colF;
                cols.Add(c);
                cols.Add(c);
                cols.Add(c);
                cols.Add(c);
            }
        }

        if (isActualBounds)
        {
            pos_min = pos_max = Vector3.zero;
            for (int i = offset; i < verts.Count; i++)
            {
                Vector3 v = verts[i];
                pos_min = Vector3.Min(pos_min, v);
                pos_max = Vector3.Max(pos_max, v);
            }
        }

        if (onPostFill != null) onPostFill(this, offset, verts, uvs, cols);
    }



#if UNITY_EDITOR
    void OnDrawGizmosSelected()
    {
        if (hasShape && mShape != null)
        {
            Gizmos.color = Color.cyan;
            Matrix4x4 matrix = new Matrix4x4();
            matrix.SetTRS(cachedTransform.TransformPoint(mShape.center), cachedTransform.rotation * mShape.rotation, cachedTransform.lossyScale);
            Gizmos.matrix = matrix;

            int d = 50;
            float da = Mathf.PI * 2 / d;

            //Gizmos.matrix.SetTRS(Vector3.zero, mShape.rotation, Vector3.one);
            if (mShape.style == ShapeStyle.Sphere)
            {
                Gizmos.DrawWireSphere(Vector3.zero, mShape.radius);
            }
            else if (mShape.style == ShapeStyle.HemiSphere)
            {
                Vector3 last = new Vector3(mShape.radius, 0, 0);
                for (int i = 1; i <= d; i++)
                {
                    float a = i * da;
                    Vector3 temp = new Vector3(Mathf.Cos(a) * mShape.radius, 0, Mathf.Sin(a) * mShape.radius);
                    Gizmos.DrawLine(last, temp);
                    last = temp;
                }

                d /= 2;
                last = new Vector3(mShape.radius, 0, 0);
                for (int i = 1; i <= d; i++)
                {
                    float a = i * da;
                    Vector3 temp = new Vector3(Mathf.Cos(a) * mShape.radius, Mathf.Sin(a) * mShape.radius, 0);
                    Gizmos.DrawLine(last, temp);
                    last = temp;
                }
                //Gizmos.DrawLine(last, new Vector3(mShape.radius, 0, 0));

                last = new Vector3(0, 0, mShape.radius);
                for (int i = 1; i <= d; i++)
                {
                    float a = i * da;
                    Vector3 temp = new Vector3(0, Mathf.Sin(a) * mShape.radius, Mathf.Cos(a) * mShape.radius);
                    Gizmos.DrawLine(last, temp);
                    last = temp;
                }
                //Gizmos.DrawLine(last, new Vector3(0, 0, mShape.radius));
            }
            else if (mShape.style == ShapeStyle.Cone)
            {
                Vector3 last = new Vector3(mShape.radius, 0, 0);
                for (int i = 1; i <= d; i++)
                {
                    float a = i * da;
                    Vector3 temp = new Vector3(Mathf.Cos(a) * mShape.radius, 0, Mathf.Sin(a) * mShape.radius);
                    Gizmos.DrawLine(last, temp);
                    last = temp;
                }

                float r = Mathf.Tan(mShape.angle * Mathf.Deg2Rad) * mShape.length + mShape.radius;
                last = new Vector3(r, mShape.length, 0);
                for (int i = 1; i <= d; i++)
                {
                    float a = i * da;
                    Vector3 temp = new Vector3(Mathf.Cos(a) * r, mShape.length, Mathf.Sin(a) * r);
                    Gizmos.DrawLine(last, temp);
                    last = temp;
                }

                Gizmos.DrawLine(new Vector3(mShape.radius, 0, 0), new Vector3(r, mShape.length, 0));
                Gizmos.DrawLine(new Vector3(0, 0, mShape.radius), new Vector3(0, mShape.length, r));
                Gizmos.DrawLine(new Vector3(-mShape.radius, 0, 0), new Vector3(-r, mShape.length, 0));
                Gizmos.DrawLine(new Vector3(0, 0, -mShape.radius), new Vector3(0, mShape.length, -r));
            }
            else if (mShape.style == ShapeStyle.Box)
            {
                Vector3 half = mShape.box * 0.5f;

                Vector3 v1 = new Vector3(-half.x, -half.y, -half.z);
                Vector3 v2 = new Vector3(-half.x, -half.y, half.z);
                Vector3 v3 = new Vector3(half.x, -half.y, half.z);
                Vector3 v4 = new Vector3(half.x, -half.y, -half.z);
                Vector3 v5 = new Vector3(-half.x, half.y, -half.z);
                Vector3 v6 = new Vector3(-half.x, half.y, half.z);
                Vector3 v7 = new Vector3(half.x, half.y, half.z);
                Vector3 v8 = new Vector3(half.x, half.y, -half.z);

                Gizmos.DrawLine(v1, v2);
                Gizmos.DrawLine(v2, v3);
                Gizmos.DrawLine(v3, v4);
                Gizmos.DrawLine(v4, v1);

                Gizmos.DrawLine(v5, v6);
                Gizmos.DrawLine(v6, v7);
                Gizmos.DrawLine(v7, v8);
                Gizmos.DrawLine(v8, v5);

                Gizmos.DrawLine(v1, v5);
                Gizmos.DrawLine(v2, v6);
                Gizmos.DrawLine(v3, v7);
                Gizmos.DrawLine(v4, v8);
            }
            else if (mShape.style == ShapeStyle.Ellipsoid)
            {
                Vector3 size = mShape.box * 0.5f;
                Vector3 last = new Vector3(size.x, 0, 0);
                for (int i = 1; i <= d; i++)
                {
                    float a = i * da;
                    Vector3 temp = new Vector3(Mathf.Cos(a) * size.x, 0, Mathf.Sin(a) * size.z);
                    Gizmos.DrawLine(last, temp);
                    last = temp;
                }

                last = new Vector3(size.x, 0, 0);
                for (int i = 1; i <= d; i++)
                {
                    float a = i * da;
                    Vector3 temp = new Vector3(Mathf.Cos(a) * size.x, Mathf.Sin(a) * size.y, 0);
                    Gizmos.DrawLine(last, temp);
                    last = temp;
                }
                //Gizmos.DrawLine(last, new Vector3(mShape.radius, 0, 0));

                last = new Vector3(0, 0, size.z);
                for (int i = 1; i <= d; i++)
                {
                    float a = i * da;
                    Vector3 temp = new Vector3(0, Mathf.Sin(a) * size.y, Mathf.Cos(a) * size.z);
                    Gizmos.DrawLine(last, temp);
                    last = temp;
                }
            }
        }

        if (hasSwirl)
        {
            Matrix4x4 matrix = new Matrix4x4();
            matrix.SetTRS(cachedTransform.TransformPoint(swirlCenter), cachedTransform.rotation, cachedTransform.lossyScale);
            Gizmos.matrix = matrix;
            Gizmos.color = Color.magenta;
            Gizmos.DrawWireSphere(Vector3.zero, swirlRadius);
        }
    }
#endif
}