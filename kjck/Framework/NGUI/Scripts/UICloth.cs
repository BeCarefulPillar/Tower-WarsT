//NGUI Extend Copyright © 何权

using UnityEngine;
using System.Collections.Generic;

[ExecuteInEditMode]
public class UICloth : UIWidget
{
    [System.Serializable]
    public class PointFrame
    {
        [HideInInspector][SerializeField] private int index;
        [HideInInspector][SerializeField] private Vector3 defPos;
        [HideInInspector][SerializeField] private Vector3[] points;
        [HideInInspector][SerializeField] private int[] frames;
        [HideInInspector][SerializeField] private int count = 0;

        public int Index { get { return index; } }

        public PointFrame(int index,Vector3 defPos)
        {
            this.index = index;
            this.defPos = defPos;
        }

        public Vector3 SampleFrame(int frame)
        {
            if (count > 0)
            {
                if (frame >= frames[count - 1]) return points[count - 1];
                if (frame <= frames[0]) return frames[0] > 0 ? Vector3.Lerp(defPos, points[0], (float)frame / (float)frames[0]) : points[0];
                for (int i = 1; i < count; i++)
                {
                    if (frame > frames[i]) continue;
                    return Vector3.Lerp(points[i - 1], points[i], (float)(frame - frames[i - 1]) / (float)(frames[i] - frames[i - 1]));
                }
            }
            return defPos;
        }

        public void SetFramePoint(int frame, Vector3 pos)
        {
            if (points == null)
            {
                points = new Vector3[1] { pos };
                frames = new int[1] { frame };
                count = 1;
            }
            else
            {
                int len = points.Length;
                for (int i = 0; i < len; i++)
                {
                    if (frames[i] == frame)
                    {
                        points[i] = pos;
                        return;
                    }
                }
                count = len + 1;
                System.Array.Resize(ref points, count);
                System.Array.Resize(ref frames, count);
                for (int i = 0; i < len; i++)
                {
                    if (frame > frames[i]) continue;
                    for (int j = len; j > i; j--)
                    {
                        points[j] = points[j - 1];
                        frames[j] = frames[j - 1];
                    }
                    points[i] = pos;
                    frames[i] = frame;
                    return;
                }
                points[len] = pos;
                frames[len] = frame;
            }
        }

        public Vector3? GetFramePoint(int frame)
        {
            if (count > 0)
            {
                for (int i = 0; i < count; i++)
                {
                    if (frame == frames[i]) return (Vector3?)points[i];
                }
            }
            return null;
        }

        public void DeleteFrame(int frame)
        {
            if (count > 0)
            {
                for (int i = 0; i < count; i++)
                {
                    if (frames[i] == frame)
                    {
                        count--;
                        for (int j = i; j < count; j++)
                        {
                            frames[j] = frames[j + 1];
                            points[j] = points[j + 1];
                        }
                        if (count > 0)
                        {
                            System.Array.Resize(ref points, count);
                            System.Array.Resize(ref frames, count);
                        }
                        else
                        {
                            points = null;
                            frames = null;
                        }
                        return;
                    }
                }
            }
        }

        public void DeleteFrameAfter(int frame)
        {
            if (count > 0)
            {
                for (int i = 0; i < count; i++)
                {
                    if (frames[i] > frame)
                    {
                        count = i;
                        if (count > 0)
                        {
                            System.Array.Resize(ref points, count);
                            System.Array.Resize(ref frames, count);
                        }
                        else
                        {
                            points = null;
                            frames = null;
                        }
                        return;
                    }
                }
            }
        }

        public void ClearFrame() { points = null; frames = null; count = 0; }

        public int Count { get { return count; } }

        public override string ToString()
        {
            string fs = "";
            if (count > 0)
            {
                string[] ss = new string[count];
                for (int i = 0; i < count; i++) ss[i] = frames[i].ToString();
                fs = string.Join(",", ss);
            }

            return "index = " + index + "  frames[" + fs + "]  defPos =" + defPos;
        }
    }

    private static BetterList<UICloth> mList = new BetterList<UICloth>();

    [HideInInspector][SerializeField] Object mRes;
	[HideInInspector][SerializeField] string mStr;

	[HideInInspector][SerializeField] int sepX = 1;
	[HideInInspector][SerializeField] int sepY = 1;
    [HideInInspector][SerializeField] Vector3[] mPoints;

    [HideInInspector][SerializeField] int mFontSize = 32;
    [HideInInspector][SerializeField] UILabel.Effect mEffectStyle = UILabel.Effect.None;
    [HideInInspector][SerializeField] Color mEffectColor = Color.black;
    [HideInInspector][SerializeField] Vector2 mEffectDistance = Vector2.one;
    [HideInInspector][SerializeField] bool mApplyGradient = false;
	[HideInInspector][SerializeField] Color mGradientTop = Color.white;
	[HideInInspector][SerializeField] Color mGradientBottom = new Color(0.7f, 0.7f, 0.7f);

    [HideInInspector][SerializeField] float totalPlayTime = 0f;
    [HideInInspector][SerializeField] PointFrame[] mFrames = null;
    [HideInInspector][SerializeField] int[] mFrameIndexs = null;
    [HideInInspector][SerializeField] bool loop = false;
    [HideInInspector][SerializeField] bool playOnAwake = true;

    [System.NonSerialized] private UISpriteData mSprite;
    [System.NonSerialized] private Vector2[,] mUVPoints;
    [System.NonSerialized] private bool mResUpdate = true;
    [System.NonSerialized] private bool isPlay = false;
    [System.NonSerialized] private float playTime = 0f;

    public float playScale = 1f;

    static UICloth() { Font.textureRebuilt += OnFontRebuild; }

    private static void OnFontRebuild(Font font)
    {
        for (int i = 0; i < mList.size; ++i)
        {
            UICloth ucf = mList[i];

            if (ucf && ucf.mRes == font)
            {
                (ucf.mRes as Font).RequestCharactersInTexture(ucf.mStr, ucf.mFontSize);
                ucf.RemoveFromPanel();
                ucf.CreatePanel();
            }
        }
    }

    public void Play()
    {
        isPlay = true;
    }
    public void Pause()
    {
        isPlay = false;
    }
    public void Stop()
    {
        isPlay = false;
        playTime = 0f;
    }

    public bool HasAnimation { get { return mFrameIndexs.GetLength() > 0; } }

    public PointFrame GetKeyFrame(int index) { if (mFrameIndexs.IndexAvailable(index)) { int idx = mFrameIndexs[index]; return idx < 0 ? null : mFrames[idx]; } return null; }

    public void AddKeyFrame(int index, int frame, Vector3 pos)
    {
        if (mPoints != null && mFrameIndexs.IndexAvailable(index))
        {
            int idx = mFrameIndexs[index];
            if (idx < 0)
            {
                if (mFrames == null)
                {
                    idx = 0;
                    mFrames = new PointFrame[1] { new PointFrame(index, mPoints[index]) };
                }
                else
                {
                    int len = mFrames.Length;
                    System.Array.Resize(ref mFrames, len + 1);
                    mFrames[len] = new PointFrame(index, mPoints[index]);
                    idx = len;
                }
                mFrameIndexs[index] = idx;
            }
            mFrames[idx].SetFramePoint(frame, pos);
            
        }
    }
    public void DeleteKeyFrame(int index, int frame)
    {
        if (mPoints != null && mFrameIndexs.IndexAvailable(index))
        {
            int idx = mFrameIndexs[index];
            if (idx >= 0)
            {
                mFrames[idx].DeleteFrame(frame);
                if (mFrames[idx].Count <= 0) TrimPointFrame();
            }
        }
    }
    public void CreatAnimation()
    {
        if (mFrameIndexs.GetLength() <= 0)
        {
            int len = mPoints.Length;
            mFrames = null;
            mFrameIndexs = new int[len];
            for (int i = 0; i < len; i++) mFrameIndexs[i] = -1;
        }
    }
    public void DeleteAnimation() { Stop(); mFrames = null; mFrameIndexs = null; totalPlayTime = 0; MarkAsChanged(); }

    private void TrimPointFrame()
    {
        if (mFrameIndexs.GetLength() > 0)
        {
            int len = mFrames.GetLength();
            if (len > 0)
            {
                int newLen = len;
                int idx = 0;
                for (int i = 0; i < len; i++)
                {
                    if (mFrames[i] != null)
                    {
                        if (mFrames[i].Count > 0)
                        {
                            if (idx != i)
                            {
                                mFrames[idx] = mFrames[i];
                                mFrames[i] = null;
                                mFrameIndexs[mFrames[idx].Index] = idx;
                            }
                            idx++;
                        }
                        else
                        {
                            mFrameIndexs[mFrames[i].Index] = -1;
                            mFrames[i] = null;
                            newLen--;
                        }
                    }
                    else newLen--;
                }
                
                if (newLen != len)
                {
                    if (newLen == 0) mFrames = null;
                    else System.Array.Resize(ref mFrames, newLen);
                }
            }
        }
    }

    /// <summary>
    /// X点数
    /// </summary>
    public int SepX
    {
        get { return sepX; }
        set
        {
            value = Mathf.Max(1, value);
            if (sepX != value)
            {
                sepX = value;
                mPoints = null;
            }
        }
    }
    /// <summary>
    /// Y点数
    /// </summary>
    public int SepY
    {
        get { return sepY; }
        set
        {
            value = Mathf.Max(1, value);
            if (sepY != value)
            {
                sepY = value;
                mPoints = null;
            }
        }
    }

    /// <summary>
    /// 重建网格,将清除动画数据
    /// </summary>
    public void RebuildMesh()
    {
        int px = sepX + 1;
        mPoints = new Vector3[px * (sepY + 1)];
        
        float dw = 1f / sepX;
        float dh = 1f / sepY;
        for (int i = 0; i <= sepY; i++)
        {
            int d = i * px;
            for (int j = 0; j <= sepX; j++)
            {
                mPoints[d + j] = new Vector3(j * dw, i * dh);
            }
        }

        DeleteAnimation();
        mUVPoints = null;
        MarkAsChanged();
    }
    /// <summary>
    /// 更新资源
    /// </summary>
    [ContextMenu("Update")]
    private void UpdateRes()
    {
        if (mRes is UIAtlas)
        {
            UIAtlas atlas = mRes as UIAtlas;
            mSprite = atlas.GetSprite(mStr);
            if (mSprite == null) mStr = "";
        }
        else if (mRes is Font)
        {
            Font fnt = mRes as Font;
            mStr = (!string.IsNullOrEmpty(mStr) && mStr.Length > 1) ? mStr.Substring(0, 1) : mStr;
            char c = string.IsNullOrEmpty(mStr) ? '\0' : mStr[0];
            CharacterInfo ci;
            if (!fnt.GetCharacterInfo(c, out ci, mFontSize)) fnt.RequestCharactersInTexture(mStr, mFontSize);

        }
        else if (mRes is Texture)
        {

        }
        mUVPoints = null;
        MarkAsChanged();
    }

    /// <summary>
    /// 网格点
    /// </summary>
    public Vector3[] Points { get { return mPoints; } }
    /// <summary>
    /// 播放总时间
    /// </summary>
    public float TotalPlayTime
    {
        get { return totalPlayTime; }
        set
        {
            value = Mathf.Max(0, value);
            if (totalPlayTime == value) return;
            totalPlayTime = value;
            if (mFrames != null)
            {
                bool trim = false;
                int maxFrame = Mathf.RoundToInt(totalPlayTime * 60f);
                foreach (PointFrame pf in mFrames)
                {
                    if (pf != null)
                    {
                        pf.DeleteFrameAfter(maxFrame);
                        if (pf.Count > 0) continue;
                        trim = true;
                    }
                }
                if (trim) TrimPointFrame();
            }
        }
    }

#if UNITY_EDITOR
#if TOLUA
    [LuaInterface.NoToLua]
#endif
    public float PlayTime
    {
        get { return playTime; }
        set
        {
            playTime = Mathf.Clamp(value, 0, totalPlayTime);
        }
    }
#endif

    public bool Loop { get { return loop; } set { loop = value; } }

    public bool PlayOnAwake { get { return playOnAwake; } set { playOnAwake = value; } }

    public override Material material
    {
        get
        {
            if (mRes is UIAtlas) return (mRes as UIAtlas).spriteMaterial;
            if (mRes is Font) return (mRes as Font).material;
            if (mRes is Texture2D)
            {
                if (mMat == null)
                {
                    mMat = new Material(Shader.Find("Unlit/Transparent Colored"));
                    mMat.mainTexture = mRes as Texture2D;
                }
                return mMat;
            }
            return null;
        }
    }

    public Object Res
    {
        get
        {
            return mRes;
        }
        set
        {
            if (mRes != value)
            {
                if (value)
                {
                    if (value is UIAtlas || value is Font || value is Texture)
                    {
                        mRes = value;
                        mResUpdate = true;
                    }
                }
                else
                {
                    mRes = null;
                    mResUpdate = true;
                }
            }
        }
    }

    public string Str { get { return mStr; } set { if (mStr != value) { mStr = value; mResUpdate = true; } } }

    public int fontSize
    {
        get
        {
            return mFontSize;
        }
        set
        {
            value = Mathf.Clamp(value, 0, 256);
            if (mFontSize != value)
            {
                mFontSize = value; 
                if (mRes is Font) mResUpdate = true;
            }
        }
    }

    public bool applyGradient { get { return mApplyGradient; } set { if (mApplyGradient != value) { mApplyGradient = value; MarkAsChanged(); } } }

    public Color gradientTop { get { return mGradientTop; } set { if (mGradientTop != value) mGradientTop = value; if (mApplyGradient) MarkAsChanged(); } }

    public Color gradientBottom { get { return mGradientBottom; } set { if (mGradientBottom != value) mGradientBottom = value; if (mApplyGradient) MarkAsChanged(); } }

    public UILabel.Effect effectStyle { get { return mEffectStyle; } set { if (mEffectStyle != value) { mEffectStyle = value; MarkAsChanged(); } } }

    public Color effectColor { get { return mEffectColor; } set { if (mEffectColor != value) { mEffectColor = value; if (mEffectStyle != UILabel.Effect.None) MarkAsChanged(); } } }

    public Vector2 effectDistance { get { return mEffectDistance; } set { if (mEffectDistance != value) { mEffectDistance = value; if (mEffectStyle != UILabel.Effect.None) MarkAsChanged(); } } }

    public UISpriteData spriteData { get { return mSprite; } }


    protected override void OnStart()
    {
        base.OnStart();
        if (playOnAwake) isPlay = true;
    }

    protected override void OnInit()
    {
        base.OnInit();
        mList.Add(this);
    }

    protected override void OnDisable()
    {
        mList.Remove(this);
        base.OnDisable();
    }

    /// <summary>
    /// Adjust the scale of the widget to make it pixel-perfect.
    /// </summary>
    public override void MakePixelPerfect()
    {
        base.MakePixelPerfect();

        if (mRes is UIAtlas)
        {
            UIAtlas atlas = mRes as UIAtlas;
            UISpriteData sp = atlas.GetSprite(mStr);
            if (sp == null) return;

            Texture tex = mainTexture;
            if (tex == null) return;

            int x = Mathf.RoundToInt(atlas.pixelSize * sp.width);
            int y = Mathf.RoundToInt(atlas.pixelSize * sp.height);

            if ((x & 1) == 1) ++x;
            if ((y & 1) == 1) ++y;

            width = x;
            height = y;
        }
        else if (mRes is Font)
        {
            Font fnt = mRes as Font;
            char c = string.IsNullOrEmpty(mStr) ? '\0' : mStr[0];
            CharacterInfo ci;
            if (fnt.GetCharacterInfo(c, out ci, mFontSize))
            {
                width = (int)ci.advance;
                height = ci.size;
            }
            else fnt.RequestCharactersInTexture(mStr, mFontSize);
        }
        else if (mRes is Texture)
        {

        }

        UpdateRes();
    }

    /// <summary>
    /// Update the UV coordinates.
    /// </summary>
    protected override void OnUpdate()
    {
        base.OnUpdate();

        if (mResUpdate)
        {
            mResUpdate = false;
            UpdateRes();
        }

        if (mPoints == null) RebuildMesh();

        if (isPlay)
        {
            playTime += Time.deltaTime * playScale;
            if (playTime > totalPlayTime)
            {
                if (loop) playTime = 0;
                else Stop();
            }
            mChanged = true;
        }
    }

    /// <summary>
    /// Virtual function called by the UIPanel that fills the buffers.
    /// </summary>
    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        if (mPoints.GetLength() <= 0) RebuildMesh();

        Texture tex = mainTexture;
        if (tex == null) return;

        int px = sepX + 1;
        Color colF = color;
        colF.a = finalAlpha;

        if (mRes is UIAtlas)
        {
            UIAtlas atlas = mRes as UIAtlas;
            if (mSprite == null) mSprite = atlas.GetSprite(mStr);
            if (mSprite == null) return;

            if (atlas.premultipliedAlpha) NGUITools.ApplyPMA(colF);
            if (QualitySettings.activeColorSpace == ColorSpace.Linear)
            {
                colF.r = Mathf.Pow(colF.r, 2.2f);
                colF.g = Mathf.Pow(colF.g, 2.2f);
                colF.b = Mathf.Pow(colF.b, 2.2f);
            }

            Rect outer = NGUIMath.ConvertToTexCoords(new Rect(mSprite.x, mSprite.y, mSprite.width, mSprite.height), tex.width, tex.height);

            if (mUVPoints == null)
            {
                mUVPoints = new Vector2[px, sepY + 1];

                float dw = outer.width / sepX;
                float dh = outer.height / sepY;
                for (int i = 0; i <= sepY; i++)
                {
                    for (int j = 0; j <= sepX; j++)
                    {
                        mUVPoints[j, i] = new Vector3(outer.x + j * dw, outer.y + i * dh);
                    }
                }
            }
        }
        else if (mRes is Font)
        {
            Font fnt = mRes as Font;
            char c = (string.IsNullOrEmpty(mStr) || mStr.Length == 0) ? '\0' : mStr[0];
            CharacterInfo ci;
            if (!fnt.GetCharacterInfo(c, out ci, mFontSize)) fnt.RequestCharactersInTexture(mStr, mFontSize);
            if (!fnt.GetCharacterInfo(c, out ci, mFontSize)) return;

            mUVPoints = new Vector2[px, sepY + 1];
            //if (ci.flipped)
            //{
            //    float dw = ci.uv.width / sepY;
            //    float dh = ci.uv.height / sepX;
            //    for (int i = 0; i <= sepY; i++)
            //    {
            //        for (int j = 0; j <= sepX; j++)
            //        {
            //            mUVPoints[j, i] = new Vector3(ci.uv.x + i * dw, ci.uv.y + j * dh);
            //        }
            //    }
            //}
            //else
            //{
            //    float dw = ci.uv.width / sepX;
            //    float dh = ci.uv.height / sepY;
            //    for (int i = 0; i <= sepY; i++)
            //    {
            //        for (int j = 0; j <= sepX; j++)
            //        {
            //            mUVPoints[j, i] = new Vector3(ci.uv.x + j * dw, ci.uv.y + i * dh);
            //        }
            //    }
            //}
            Vector2 vy1 = (ci.uvTopLeft - ci.uvBottomLeft) / sepY;
            Vector2 vy2 = (ci.uvTopRight - ci.uvBottomRight) / sepY;
            //Vector2 vx1 = (ci.uvBottomRight - ci.uvBottomLeft) / sepX;
            //Vector2 vx2 = (ci.uvTopRight - ci.uvTopLeft) / sepX;

            for (int i = 0; i <= sepY; i++)
            {
                Vector2 op = ci.uvBottomLeft + vy2 * i;
                Vector2 dv = ((ci.uvBottomRight + vy1 * i) - op) / sepX;
                //Vector2 dv = ci.uvTopLeft + vx2 * i - (ci.uvBottomLeft + vx1 * i);
                for (int j = 0; j <= sepX; j++)
                {
                    mUVPoints[j, i] = op + dv * j;
                }
            }
        }
        else if (mRes is Texture)
        {

        }
        else return;
        
        Vector4 v = drawingDimensions;
        Vector3[,] points = new Vector3[px, sepY + 1];

        if (HasAnimation)
        {
            int frame = Mathf.RoundToInt(playTime * 60f);
            for (int i = 0; i <= sepY; i++)
            {
                int d = i * px;
                for (int j = 0; j <= sepX; j++)
                {
                    int idx = mFrameIndexs[d + j];
                    PointFrame pf = idx < 0 ? null : mFrames[idx];
                    Vector3 p = pf != null ? pf.SampleFrame(frame) : mPoints[d + j];
                    points[j, i] = new Vector3(v.x + p.x * width, v.y + p.y * height, p.z);
                }
            }
        }
        else
        {
            for (int i = 0; i <= sepY; i++)
            {
                int d = i * px;
                for (int j = 0; j <= sepX; j++)
                {
                    Vector3 p = mPoints[d + j];
                    points[j, i] = new Vector3(v.x + p.x * width, v.y + p.y * height, p.z);
                }
            }
        }
        

        int offset = verts.Count;

        if (mEffectStyle == UILabel.Effect.Shadow)
        {
            Color efc = effectColor;
            efc.a *= colF.a;
            Vector3 dev = effectDistance;
            for (int i = 0; i < sepY; i++)
            {
                int minY = i, maxY = i + 1;
                for (int j = 0; j < sepX; j++)
                {
                    int minX = j, maxX = j + 1;
                    verts.Add(points[minX, minY] + dev);
                    verts.Add(points[minX, maxY] + dev);
                    verts.Add(points[maxX, maxY] + dev);
                    verts.Add(points[maxX, minY] + dev);

                    uvs.Add(mUVPoints[minX, minY]);
                    uvs.Add(mUVPoints[minX, maxY]);
                    uvs.Add(mUVPoints[maxX, maxY]);
                    uvs.Add(mUVPoints[maxX, minY]);

                    cols.Add(efc);
                    cols.Add(efc);
                    cols.Add(efc);
                    cols.Add(efc);
                }
            }
        }
        else if (mEffectStyle == UILabel.Effect.Outline)
        {
            Color efc = effectColor;
            efc.a *= colF.a;
            for (int l = 0; l < 4; l++)
            {
                Vector3 dev = effectDistance;
                if (l == 1) dev.x *= -1;
                else if (l == 2) dev.y *= -1;
                else if (l == 3) dev *= -1;
                for (int i = 0; i < sepY; i++)
                {
                    int minY = i, maxY = i + 1;
                    for (int j = 0; j < sepX; j++)
                    {
                        int minX = j, maxX = j + 1;
                        verts.Add(points[minX, minY] + dev);
                        verts.Add(points[minX, maxY] + dev);
                        verts.Add(points[maxX, maxY] + dev);
                        verts.Add(points[maxX, minY] + dev);

                        uvs.Add(mUVPoints[minX, minY]);
                        uvs.Add(mUVPoints[minX, maxY]);
                        uvs.Add(mUVPoints[maxX, maxY]);
                        uvs.Add(mUVPoints[maxX, minY]);

                        cols.Add(efc);
                        cols.Add(efc);
                        cols.Add(efc);
                        cols.Add(efc);
                    }
                }
            }
        }
        
        for (int i = 0; i < sepY; i++)
        {
            int minY = i, maxY = i + 1;
            for (int j = 0; j < sepX; j++)
            {
                int minX = j, maxX = j + 1;
                verts.Add(points[minX, minY]);
                verts.Add(points[minX, maxY]);
                verts.Add(points[maxX, maxY]);
                verts.Add(points[maxX, minY]);

                uvs.Add(mUVPoints[minX, minY]);
                uvs.Add(mUVPoints[minX, maxY]);
                uvs.Add(mUVPoints[maxX, maxY]);
                uvs.Add(mUVPoints[maxX, minY]);

                //cols.Add(colF);
                //cols.Add(colF);
                //cols.Add(colF);
                //cols.Add(colF);
            }
        }

        if (mApplyGradient)
        {
            for (int i = 0; i < sepY; i++)
            {
                int minY = i * px;
                int maxY = minY + px;
                for (int j = 0; j < sepX; j++)
                {
                    int minX = j, maxX = j + 1;
                    cols.Add(Color.Lerp(mGradientBottom, mGradientTop, mPoints[minY + minX].y) * colF);
                    cols.Add(Color.Lerp(mGradientBottom, mGradientTop, mPoints[maxY + minX].y) * colF);
                    cols.Add(Color.Lerp(mGradientBottom, mGradientTop, mPoints[maxY + maxX].y) * colF);
                    cols.Add(Color.Lerp(mGradientBottom, mGradientTop, mPoints[minY + maxX].y) * colF);
                }
            }
        }
        else
        {
            int cc = sepX * sepY * 4;
            for (int i = 0; i < cc; i++) cols.Add(colF);
        }

        if (onPostFill != null) onPostFill(this, offset, verts, uvs, cols);
    }

#if UNITY_EDITOR
#if TOLUA
    [LuaInterface.NoToLua]
#endif
    public bool animatChilds = false;

    void OnDrawGizmos()
    {
        GameObject go = UnityEditor.Selection.activeGameObject;
        if (go != gameObject || mPoints.GetLength() <= 0) return;
        Matrix4x4 ltw = transform.localToWorldMatrix;
        Gizmos.color = Color.green;

        Vector4 draw = drawingDimensions;
        int px = sepX + 1, py = sepY + 1;
        int len = mPoints.Length;
        Vector3[] ps = new Vector3[len];

        if (HasAnimation)
        {
            int frame = Mathf.RoundToInt(playTime * 60f);
            for (int i = 0; i < len; i++)
            {
                int idx = mFrameIndexs[i];
                PointFrame pf = idx < 0 ? null : mFrames[idx];
                Vector3 p = pf != null ? pf.SampleFrame(frame) : mPoints[i];
                p.x = draw.x + p.x * width;
                p.y = draw.y + p.y * height;
                ps[i] = ltw.MultiplyPoint3x4(p);
            }
        }
        else
        {
            for (int i = 0; i < len; i++)
            {
                Vector3 p = mPoints[i];
                p.x = draw.x + p.x * width;
                p.y = draw.y + p.y * height;
                ps[i] = ltw.MultiplyPoint3x4(p);
            }
        }

        for (int i = 0; i < py; i++)
        {
            int d = i * px;
            for (int j = 0; j < sepX; j++)
            {
                Gizmos.DrawLine(ps[d + j], ps[d + j + 1]);
            }
        }
        for (int i = 0; i < px; i++)
        {
            for (int j = 0; j < sepY; j++)
            {
                Gizmos.DrawLine(ps[j * px + i], ps[j * px + px + i]);
            }
        }
    }
#endif
}