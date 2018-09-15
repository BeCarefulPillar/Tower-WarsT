using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIMesh : UIWidget
{
    [HideInInspector][SerializeField] Texture mTexture;
    [HideInInspector][SerializeField] Shader mShader;
    [HideInInspector][SerializeField] Mesh mMesh;
    [HideInInspector][SerializeField] Rect mRect = new Rect(0f, 0f, 1f, 1f);

    [System.NonSerialized] int mPMA = -1;
    [System.NonSerialized] List<int> mCache = null;

    public override Texture mainTexture
    {
        get
        {
            if (mTexture) return mTexture;
            if (mMat) return mMat.mainTexture;
            return null;
        }
        set
        {
            if (mTexture != value)
            {
                if (drawCall != null && drawCall.widgetCount == 1 && mMat == null)
                {
                    mTexture = value;
                    drawCall.mainTexture = value;
                }
                else
                {
                    RemoveFromPanel();
                    mTexture = value;
                    mPMA = -1;
                    MarkAsChanged();
                }
            }
        }
    }

    public override Material material
    {
        get
        {
            return mMat;
        }
        set
        {
            if (mMat != value)
            {
                RemoveFromPanel();
                mShader = null;
                mMat = value;
                mPMA = -1;
                MarkAsChanged();
            }
        }
    }

    public override Shader shader
    {
        get
        {
            if (mMat != null) return mMat.shader;
            if (mShader == null) mShader = Shader.Find("Unlit/Transparent Colored");
            return mShader;
        }
        set
        {
            if (mShader != value)
            {
                if (drawCall != null && drawCall.widgetCount == 1 && mMat == null)
                {
                    mShader = value;
                    drawCall.shader = value;
                }
                else
                {
                    RemoveFromPanel();
                    mShader = value;
                    mPMA = -1;
                    mMat = null;
                    MarkAsChanged();
                }
            }
        }
    }

    public Mesh mesh
    {
        get
        {
            return mMesh;
        }
        set
        {
            if (mMesh == value) return;
            mMesh = value;
            mCache = null;
        }
    }

    public Rect uvRect
    {
        get
        {
            return mRect;
        }
        set
        {
            if (mRect != value)
            {
                mRect = value;
                MarkAsChanged();
            }
        }
    }

    public bool premultipliedAlpha
    {
        get
        {
            if (mPMA == -1)
            {
                Material mat = material;
                mPMA = (mat != null && mat.shader != null && mat.shader.name.Contains("Premultiplied")) ? 1 : 0;
            }
            return mPMA == 1;
        }
    }

    private Color drawingColor
    {
        get
        {
            Color colF = color;
            colF.a = finalAlpha;
            if (premultipliedAlpha) colF = NGUITools.ApplyPMA(colF);
            return colF;
        }
    }

    public override void MakePixelPerfect()
    {
        base.MakePixelPerfect();
        if (mMesh)
        {
            Vector3 size = mMesh.bounds.size;
            float min = Mathf.Min(size.x, size.y);
            if (min != 0 && min < 100)
            {
                size *= 100 / min;
            }
            width = Mathf.RoundToInt(size.x);
            height = Mathf.RoundToInt(size.y);
        }
    }

#if UNITY_EDITOR
    public void ReBuild()
    {
        mCache = null;
    }
#endif

    private void Cache()
    {
        if (mCache != null) return;
        if (mMesh == null || mMesh.triangles.Length < 3) return;
        if (mMesh.triangles.Length > 6400)
        {
#if UNITY_EDITOR
            Debug.LogWarning("Mesh to manay triangles");
#endif
            return;
        }
        int[] tmp = new int[mMesh.triangles.Length];
        int[] tr1 = new int[5];
        int[] tr2 = new int[5];
        mMesh.triangles.CopyTo(tmp, 0);
        mCache = new List<int>(tmp.Length);
        for (int i = 0; i < tmp.Length; i += 3)
        {
            if (tmp[i] < 0) continue;
            tr1[0] = tmp[i]; tr1[1] = tmp[i + 1]; tr1[2] = tmp[i + 2];
            tr1[3] = tr1[0]; tr1[4] = tr1[1];
            for (int j = i + 3; j < tmp.Length; j += 3)
            {
                if (tmp[j] < 0) continue;
                tr2[0] = tmp[j]; tr2[1] = tmp[j + 1]; tr2[2] = tmp[j + 2];
                tr2[3] = tr2[0]; tr2[4] = tr2[1];
                for (int l = 0; l < 3; l++)
                {
                    for (int m = 0; m < 3; m++)
                    {
                        if (tr1[l] == tr2[m + 1] && tr1[l + 1] == tr2[m])
                        {
                            mCache.Add(tr1[l]);
                            mCache.Add(tr1[l + 2]);
                            mCache.Add(tr1[l + 1]);
                            mCache.Add(tr2[m + 2]);
                            tmp[i] = -1; tmp[j] = -1;
                            break;
                        }
                    }
                    if (tmp[i] < 0) break;
                }
                if (tmp[i] < 0) break;
            }
            if (tmp[i] < 0) continue;
            mCache.Add(tr1[2]);
            mCache.Add(tr1[1]);
            mCache.Add(tr1[0]);
            mCache.Add(tr1[0]);
        }
    }

    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        if (mMesh == null) return;
        Texture tex = mainTexture;
        if (tex == null) return;
        Cache();
        if (mCache == null) return;
        if (mCache.Count > 8000)
        {
#if UNITY_EDITOR
            Debug.LogWarning("too many verts in mesh");
#endif
            return;
        }

        int offset = verts.Count;
        Color col = drawingColor;

        Matrix4x4 matrix = new Matrix4x4();
        matrix.SetTRS(Vector3.zero, Quaternion.identity, new Vector3(mWidth, mHeight, (mWidth + mHeight) * 0.5f));
        Matrix4x4 uvMatrix = new Matrix4x4();
        uvMatrix.SetTRS(mRect.position, Quaternion.identity, mRect.size);

        if (mMesh.colors.Length == mMesh.vertexCount)
        {
            for (int i = 0; i < mCache.Count; i++)
            {
                verts.Add(matrix.MultiplyPoint3x4(mMesh.vertices[mCache[i]]));
                uvs.Add(uvMatrix.MultiplyPoint3x4(mMesh.uv[mCache[i]]));
                cols.Add(mMesh.colors[mCache[i]] * col);
            }
        }
        else
        {
            for (int i = 0; i < mCache.Count; i++)
            {
                verts.Add(matrix.MultiplyPoint3x4(mMesh.vertices[mCache[i]]));
                uvs.Add(uvMatrix.MultiplyPoint3x4(mMesh.uv[mCache[i]]));
                cols.Add(col);
            }
        }

        if (onPostFill == null) return;
        onPostFill(this, offset, verts, uvs, cols);
    }
}
