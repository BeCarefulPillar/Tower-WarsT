//NGUI Extend Copyright © 何权

using UnityEditor;
using UnityEngine;
using System.Collections;

[CustomEditor(typeof(UICloth), true)]
public class UIClothInspector : UIWidgetInspector
{
    bool showHandle = true;
    int curFrame = 0;
    int copyFrame = -1;
    UICloth mCloth;

    protected override void OnEnable()
    {
        base.OnEnable();
        mCloth = target as UICloth;
    }

    /// <summary>
    /// 字体选择回调
    /// </summary>
    void OnUnityFont(Object obj)
    {
        mCloth.Res = obj;
        NGUISettings.ambigiousFont = obj;
    }

    /// <summary>
    /// 图集选择回调.
    /// </summary>
    void OnSelectAtlas(Object obj)
    {
        mCloth.Res = obj;
        NGUISettings.atlas = obj as UIAtlas;
    }

    /// <summary>
    /// 精灵选择回调.
    /// </summary>
    void SelectSprite(string spriteName)
    {
        mCloth.Str = spriteName;
        NGUISettings.selectedSprite = spriteName;
    }

    /// <summary>
    /// Draw the atlas and sprite selection fields.
    /// </summary>
    protected override bool ShouldDrawProperties()
    {
        if (mCloth.Res == null || mCloth.Res is UIAtlas)
        {
            GUILayout.BeginHorizontal();
            if (NGUIEditorTools.DrawPrefixButton("Atlas", GUILayout.Width(64f))) ComponentSelector.Show<UIAtlas>(OnSelectAtlas);
            mCloth.Res = EditorGUILayout.ObjectField(mCloth.Res, typeof(UIAtlas), false);
            if (GUILayout.Button("Edit", GUILayout.Width(40f)))
            {
                if (mCloth.Res != null)
                {
                    UIAtlas atl = mCloth.Res as UIAtlas;
                    NGUISettings.atlas = atl;
                    NGUIEditorTools.Select(atl.gameObject);
                }
            }
            GUILayout.EndHorizontal();
            NGUIEditorTools.DrawAdvancedSpriteField(mCloth.Res as UIAtlas, mCloth.Str, SelectSprite, false);
        }
        if (mCloth.Res == null || mCloth.Res is Font)
        {
            GUILayout.BeginHorizontal();
            if (NGUIEditorTools.DrawPrefixButton("Font", GUILayout.Width(64f))) ComponentSelector.Show<Font>(OnUnityFont, new string[] { ".ttf", ".otf" });
            mCloth.Res = EditorGUILayout.ObjectField(mCloth.Res, typeof(Font), false);
            GUILayout.EndHorizontal();
        }
        if (mCloth.Res == null || mCloth.Res is Texture)
        {
            mCloth.Res = EditorGUILayout.ObjectField("Texture", mCloth.Res, typeof(Texture), false);
        }

        if (mCloth.Res is UIAtlas)
        {

        }
        else if (mCloth.Res is Font)
        {
            GUILayout.BeginHorizontal();
            mCloth.fontSize = EditorGUILayout.IntField("Font Size", mCloth.fontSize, GUILayout.Width(142f));
            //SerializedProperty prop = NGUIEditorTools.DrawProperty("Font Size", serializedObject, "mFontSize", GUILayout.Width(142f));
            NGUISettings.fontSize = mCloth.fontSize;
            NGUIEditorTools.DrawPadding();
            GUILayout.EndHorizontal();

            mCloth.Str = EditorGUILayout.TextField("Char", mCloth.Str);
        }
        else if (mCloth.Res is Texture)
        {

        }

        GUILayout.Space(6f);
        EditorGUILayout.BeginHorizontal();
        {
            bool sh = EditorGUILayout.Toggle("ShowHandle", showHandle);
            if (showHandle != sh)
            {
                showHandle = sh;
                EditorUtility.SetDirty(mCloth);
            }
            if (GUILayout.Button("RebuildMesh")) mCloth.RebuildMesh();
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        {
            mCloth.SepX = EditorGUILayout.IntField("SepX", mCloth.SepX);
            mCloth.SepY = EditorGUILayout.IntField("SepY", mCloth.SepY);
            EditorGUILayout.EndHorizontal();
        }

        return true;
    }

    /// <summary>
    /// Draw all the custom properties such as sprite type, flip setting, fill direction, etc.
    /// </summary>
    protected override void DrawCustomProperties()
    {
        GUILayout.Space(6f);

        EditorGUI.BeginDisabledGroup(mCloth.Res == null);

        GUILayout.BeginHorizontal();
        SerializedProperty gr = NGUIEditorTools.DrawProperty("Gradient", serializedObject, "mApplyGradient", GUILayout.Width(95f));
        EditorGUI.BeginDisabledGroup(!gr.hasMultipleDifferentValues && !gr.boolValue);
        {
            NGUIEditorTools.SetLabelWidth(30f);
            NGUIEditorTools.DrawProperty("Top", serializedObject, "mGradientTop", GUILayout.MinWidth(40f));
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            NGUIEditorTools.SetLabelWidth(50f);
            GUILayout.Space(79f);
            NGUIEditorTools.DrawProperty("Bottom", serializedObject, "mGradientBottom", GUILayout.MinWidth(40f));
            NGUIEditorTools.SetLabelWidth(80f);
        }
        EditorGUI.EndDisabledGroup();
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        GUILayout.Label("Effect", GUILayout.Width(76f));
        SerializedProperty sp = NGUIEditorTools.DrawProperty("", serializedObject, "mEffectStyle", GUILayout.MinWidth(16f));

        EditorGUI.BeginDisabledGroup(!sp.hasMultipleDifferentValues && !sp.boolValue);
        {
            NGUIEditorTools.DrawProperty("", serializedObject, "mEffectColor", GUILayout.MinWidth(10f));
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Label(" ", GUILayout.Width(56f));
            NGUIEditorTools.SetLabelWidth(20f);
            NGUIEditorTools.DrawProperty("X", serializedObject, "mEffectDistance.x", GUILayout.MinWidth(40f));
            NGUIEditorTools.DrawProperty("Y", serializedObject, "mEffectDistance.y", GUILayout.MinWidth(40f));
            NGUIEditorTools.DrawPadding();
            NGUIEditorTools.SetLabelWidth(80f);
            GUILayout.EndHorizontal();
        }

        EditorGUI.EndDisabledGroup();

        base.DrawCustomProperties();

        if (GUI.changed) EditorUtility.SetDirty(mCloth);
    }

    protected override void DrawFinalProperties()
    {
        base.DrawFinalProperties();

        NGUIEditorTools.DrawSeparator();

        GUILayout.BeginHorizontal();
        bool last = mCloth.HasAnimation;
        bool hasAnimation = EditorGUILayout.Toggle("Animation", last);
        if (hasAnimation != last)
        {
            if (hasAnimation) mCloth.CreatAnimation();
            else mCloth.DeleteAnimation();
        }
        if (hasAnimation)
        {
            mCloth.animatChilds = EditorGUILayout.Toggle("AnimChild", mCloth.animatChilds);
        }
        GUILayout.EndHorizontal();

        if (hasAnimation)
        {
            bool changed = false;
            GUILayout.BeginHorizontal();
            mCloth.Loop = EditorGUILayout.Toggle("Loop", mCloth.Loop);
            NGUIEditorTools.SetLabelWidth(100f);
            mCloth.PlayOnAwake = EditorGUILayout.Toggle("PlayOnAwake", mCloth.PlayOnAwake);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            mCloth.TotalPlayTime = EditorGUILayout.FloatField("AnimationTime", mCloth.TotalPlayTime);
            EditorGUILayout.LabelField("60 FPS");

            if (mCloth.animatChilds)
            {
                UICloth[] cloths = mCloth.GetComponentsInChildren<UICloth>();
                if (cloths != null)
                {
                    foreach (UICloth cloth in cloths)
                    {
                        if (cloth && cloth.HasAnimation && cloth != mCloth)
                        {
                            cloth.TotalPlayTime = mCloth.TotalPlayTime;
                        }
                    }
                }
            }

            int px = mCloth.SepX + 1;
            int len = mCloth.Points.GetLength();

            if (GUILayout.Button("Copy" + (copyFrame >= 0 ? "[" + copyFrame + "]" : ""))) copyFrame = curFrame;
            if (copyFrame >=0 && curFrame != copyFrame && GUILayout.Button("Paste"))
            {
                for (int i = 0; i < len; i++)
                {
                    UICloth.PointFrame pf = mCloth.GetKeyFrame(i);
                    if (pf == null) continue;
                    Vector3? nv = pf.GetFramePoint(copyFrame);
                    if (nv != null)
                    {
                        pf.SetFramePoint(curFrame, (Vector3)nv);
                        changed = true;
                    }
                }
            }
            if (GUILayout.Button("Sample"))
            {
                for (int i = 0; i < len; i++)
                {
                    UICloth.PointFrame pf = mCloth.GetKeyFrame(i);
                    if (pf != null)
                    {
                        pf.SetFramePoint(curFrame, pf.SampleFrame(curFrame));
                        changed = true;
                    }
                }
            }

            int totalFrame = Mathf.RoundToInt(mCloth.TotalPlayTime * 60f);

            if (mCloth.animatChilds && GUILayout.Button("ApllyChild"))
            {
                for (int i = 0; i < totalFrame; i++)
                {
                    bool haskeyframe = false;
                    for (int j = 0; j < len; j++)
                    {
                        UICloth.PointFrame pf = mCloth.GetKeyFrame(j);
                        if (pf != null && (pf.GetFramePoint(i) != null)) { haskeyframe = true; break; }
                    }
                    if (haskeyframe) SampleChild(i);
                }
            }
            GUILayout.EndHorizontal();
            NGUIEditorTools.SetLabelWidth(80f);

            int cf = EditorGUILayout.IntSlider(curFrame, 0, totalFrame);
            if (curFrame != cf)
            {
                curFrame = cf;
                mCloth.PlayTime = (float)curFrame / 60f;
                if (mCloth.animatChilds)
                {
                    UICloth[] cloths = mCloth.GetComponentsInChildren<UICloth>();
                    if (cloths != null)
                    {
                        foreach (UICloth cloth in cloths)
                        {
                            if (cloth && cloth.HasAnimation && cloth != mCloth)
                            {
                                cloth.PlayTime = (float)curFrame / 60f;
                                cloth.MarkAsChanged();
                            }
                        }
                    }
                }
                changed = true;
            }
            
            for (int i = 0; i < len; i++)
            {
                UICloth.PointFrame pf = mCloth.GetKeyFrame(i);
                if (pf == null) continue;
                Vector3? nv = pf.GetFramePoint(curFrame);
                if (nv != null)
                {
                    Vector3 v = (Vector3)nv;
                    int ix = pf.Index % px, iy = pf.Index / px;
                    GUILayout.BeginHorizontal();
                    if (GUILayout.Button("×", GUILayout.Width(20)))
                    {
                        mCloth.DeleteKeyFrame(i, curFrame);
                        changed = true;
                    }
                    else
                    {
                        Vector3 v2 = EditorGUILayout.Vector3Field("P[" + ix + "," + iy + "]", v);
                        if (v != v2)
                        {
                            mCloth.AddKeyFrame(i, curFrame, v2);
                            changed = true;
                        }
                    }
                    GUILayout.EndHorizontal();
                }
            }

            if (GUILayout.Button("Log"))
            {
                for (int i = 0; i < len; i++)
                {
                    Debug.Log(mCloth.GetKeyFrame(i));
                }
            }

            if (changed)
            {
                //if (mCloth.animatChilds) SampleChild();
                mCloth.MarkAsChanged();
            }
        }
    }

    /// <summary>
    /// All widgets have a preview.
    /// </summary>
    public override bool HasPreviewGUI()
    {
        return (Selection.activeGameObject == null || Selection.gameObjects.Length == 1);
    }

    /// <summary>
    /// Draw the sprite preview.
    /// </summary>
    public override void OnPreviewGUI(Rect rect, GUIStyle background)
    {
        if (mCloth == null || mCloth.spriteData == null) return;

        Texture2D tex = mCloth.mainTexture as Texture2D;
        if (tex == null) return;

        UISpriteData sd = mCloth.spriteData;
        if (sd != null)//add by kiol 2015.11.17
        {
            if (mCloth.material.IsMergeShader())
            {
                int idx = sd.x / tex.width;
                if (idx > 0)
                {
                    tex = mCloth.material.GetMergeTexture(idx) as Texture2D;
                    if (tex)
                    {
                        UISpriteData sp = new UISpriteData();
                        sp.CopyFrom(sd);
                        sp.x %= tex.width;
                        sd = sp;
                    }
                }
            }
        }

        NGUIEditorTools.DrawSprite(tex, rect, sd, mCloth.color);
    }

    public new void OnSceneGUI()
    {
        if (showHandle && mCloth.Points.GetLength() > 0)
        {
            Undo.RecordObject(mCloth, "Cloth Adjust Point");
            Transform trans = mCloth.transform;

            Vector4 draw = mCloth.drawingDimensions;
            bool changed = false;
            int px = mCloth.SepX + 1;

            if (mCloth.HasAnimation)
            {
                for (int i = 0; i <= mCloth.SepY; i++)
                {
                    int d = i * px;
                    for (int j = 0; j <= mCloth.SepX; j++)
                    {
                        int idx = d + j;
                        UICloth.PointFrame pf = mCloth.GetKeyFrame(idx);
                        Vector3 o = pf != null ? pf.SampleFrame(curFrame) : mCloth.Points[idx];
                        Vector3 v = o;
                        v.x = draw.x + v.x * mCloth.width;
                        v.y = draw.y + v.y * mCloth.height;

                        v = trans.TransformPoint(v);
                        Handles.Label(v, "P" + "(" + j + "," + i + ")");
                        v = trans.InverseTransformPoint(Handles.PositionHandle(v, Quaternion.identity));

                        v.x = (v.x - draw.x) / mCloth.width;
                        v.y = (v.y - draw.y) / mCloth.height;

                        if (j > 0)
                        {
                            pf = mCloth.GetKeyFrame(idx - 1);
                            v.x = Mathf.Max(v.x, pf != null ? pf.SampleFrame(curFrame).x : mCloth.Points[idx - 1].x);
                        }
                        if (j < mCloth.SepX)
                        {
                            pf = mCloth.GetKeyFrame(idx + 1);
                            v.x = Mathf.Min(v.x, pf != null ? pf.SampleFrame(curFrame).x : mCloth.Points[idx + 1].x);
                        }
                        if (i > 0)
                        {
                            pf = mCloth.GetKeyFrame(idx - px);
                            v.y = Mathf.Max(v.y, pf != null ? pf.SampleFrame(curFrame).y : mCloth.Points[idx - px].y);
                        }
                        if (i < mCloth.SepY)
                        {
                            pf = mCloth.GetKeyFrame(idx + px);
                            v.y = Mathf.Min(v.y, pf != null ? pf.SampleFrame(curFrame).y : mCloth.Points[idx + px].y);
                        }
                        if (o != v)
                        {
                            mCloth.AddKeyFrame(idx, curFrame, v);
                            changed = true;
                        }
                    }
                }
            }
            else
            {
                for (int i = 0; i <= mCloth.SepY; i++)
                {
                    int d = i * px;
                    for (int j = 0; j <= mCloth.SepX; j++)
                    {
                        int idx = d + j;
                        Vector3 v = mCloth.Points[idx];
                        v.x = draw.x + v.x * mCloth.width;
                        v.y = draw.y + v.y * mCloth.height;

                        v = trans.TransformPoint(v);
                        Handles.Label(v, "P" + "(" + j + "," + i + ")");
                        v = trans.InverseTransformPoint(Handles.PositionHandle(v, Quaternion.identity));

                        v.x = (v.x - draw.x) / mCloth.width;
                        v.y = (v.y - draw.y) / mCloth.height;

                        if (j > 0) v.x = Mathf.Max(v.x, mCloth.Points[idx - 1].x);
                        if (j < mCloth.SepX) v.x = Mathf.Min(v.x, mCloth.Points[idx + 1].x);
                        if (i > 0) v.y = Mathf.Max(v.y, mCloth.Points[idx - px].y);
                        if (i < mCloth.SepY) v.y = Mathf.Min(v.y, mCloth.Points[idx + px].y);

                        if (mCloth.Points[idx] != v)
                        {
                            mCloth.Points[idx] = v;
                            changed = true;
                        }
                    }
                }
            }

            if (changed)
            {
                //if (mCloth.animatChilds) SampleChild();
                mCloth.MarkAsChanged();
            }
        }
    }

    void SampleChild(int frame)
    {
        if (!mCloth.HasAnimation) return;
        int len = mCloth.Points.GetLength();
        if (len < 4) return;

        Vector3[] mapPos = new Vector3[len];
        for (int i = 0; i < len; i++)
        {
            UICloth.PointFrame pf = mCloth.GetKeyFrame(i);
            mapPos[i] = pf != null ? pf.SampleFrame(frame) : mCloth.Points[i];
            mapPos[i].x = mapPos[i].x;
            mapPos[i].y = mapPos[i].y;
        }

        int ppx = mCloth.SepX + 1;
        float pdw = 1f / mCloth.SepX;
        float pdh = 1f / mCloth.SepY;


        UICloth[] cloths = mCloth.GetComponentsInChildren<UICloth>();
        if (cloths != null)
        {
            foreach (UICloth cloth in cloths)
            {
                if (cloth == null || cloth == mCloth) continue;
                if (cloth.HasAnimation)
                {
                    int clen = cloth.Points.GetLength();
                    if (len > 3 && clen > 3)
                    {
                        bool changed = false;

                        int px = cloth.SepX + 1;

                        Vector3 op = mCloth.localCorners[0] - (cloth.localCorners[0] + cloth.cachedTransform.localPosition);
                        op.x /= cloth.width;
                        op.y /= cloth.height;
                        float rx = (float)mCloth.width / (float)cloth.width;
                        float ry = (float)mCloth.height / (float)cloth.height;

                        float dw = 1f / cloth.SepX;
                        float dh = 1f / cloth.SepY;
                        for (int i = 0; i < mCloth.SepY; i++)
                        {
                            int d = i * ppx;
                            for (int j = 0; j < mCloth.SepX; j++)
                            {
                                int idx = d + j;
                                //三角形
                                Vector2 p0 = new Vector2(j * pdw * rx + op.x, i * pdh * ry + op.y);
                                Vector2 p2 = new Vector2((j + 1) * pdw * rx + op.x, (i + 1) * pdh * ry + op.y);
                                Vector2 p1 = new Vector2(p0.x, p2.y);
                                Vector2 p3 = new Vector2(p2.x, p0.y);

                                Vector2 mp0 = mapPos[idx];
                                Vector2 mp1 = mapPos[idx + ppx];
                                Vector2 mp2 = mapPos[idx + ppx + 1];
                                Vector2 mp3 = mapPos[idx + 1];

                                for (int k = 0; k < clen; k++)
                                {
                                    Vector3 p = new Vector3((k % px) * dw, k / px * dh);
                                    Vector3 npos;
                                    if (MathEx.PointInTrangle(p, p0, p1, p2))
                                    {
                                        Vector3 ov = new Vector3(Mathf.Abs((p.x - p1.x) / (p2.x - p1.x)), Mathf.Abs((p.y - p1.y) / (p0.y - p1.y)));
                                        npos = (mp2 - mp1) * ov.x + (mp0 - mp1) * ov.y + mp1;
                                    }
                                    else if (MathEx.PointInTrangle(p, p0, p2, p3))
                                    {
                                        Vector3 ov = new Vector3(Mathf.Abs((p.x - p3.x) / (p0.x - p3.x)), Mathf.Abs((p.y - p3.y) / (p2.y - p3.y)));
                                        npos = (mp0 - mp3) * ov.x + (mp2 - mp3) * ov.y + mp3;
                                    }
                                    else continue;

                                    npos.x = npos.x * rx + op.x;
                                    npos.y = npos.y * ry + op.y;
                                    npos.z = 0;

                                    //if (npos != p)
                                    if (!Mathf.Approximately(p.x, npos.x) || !Mathf.Approximately(p.y, npos.y))
                                    {
                                        cloth.AddKeyFrame(k, frame, npos);
                                        changed = true;
                                    }
                                }
                            }
                        }
                        if (changed)
                        {
                            cloth.MarkAsChanged();
                        }
                    }
                }
            }
        }
    }
}
