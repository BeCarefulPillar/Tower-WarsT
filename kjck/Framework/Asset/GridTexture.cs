//Assets Manager Copyright © 何权

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GridTexture : System.IDisposable
{
    private const int MAX_GRID_SIZE = 256;
    private const int MAX_TEX_SIZE = 2048;

    private RenderTexture mTexture;

    private int mCapacity = 0;
    private int mGridSize = 16;
    private List<string> mAssetNames;
    private List<IUITextureLoader> mLoaders;
    private Material mRenderMat = null;

    public RenderTexture texture { get { return mTexture; } }

    public Material renderMat { get { return mRenderMat; } set { mRenderMat = value; } }

    public GridTexture() : this(0, 0) { }
    public GridTexture(int gridSize) : this(gridSize, 0) { }
    public GridTexture(int gridSize, int capacity)
    {
        mGridSize = gridSize > 0 ? Mathf.Clamp(Mathf.ClosestPowerOfTwo(gridSize), 16, MAX_GRID_SIZE) : 128;
        mCapacity = Mathf.Max(capacity, 0);
        mAssetNames = new List<string>(mCapacity);
        mLoaders = new List<IUITextureLoader>(mCapacity);
    }

    public void Repaint()
    {
        mAssetNames.Clear();
        mLoaders.RemoveAll(l => { return l == null || l.Equals(null); });
        List<IUITextureLoader> loaders = mLoaders.FindAll(l => { return l.uiTexture && l.texture; });
        int count = Mathf.Max(loaders.Count, mCapacity);
        if (count <= 0)
        {
            Dispose();
            return;
        }

        //生成Rendertexture
        int temp = Mathf.Clamp(Mathf.NextPowerOfTwo(Mathf.CeilToInt(Mathf.Sqrt(count))) * mGridSize, MAX_GRID_SIZE, MAX_TEX_SIZE);
        if (mTexture && mTexture.width == temp)
        {
            mTexture.DiscardContents();
        }
        else
        {
            if (mTexture)
            {
                RenderTexture.ReleaseTemporary(mTexture);
                //Object.Destroy(mTexture);
            }
            mTexture = RenderTexture.GetTemporary(temp, temp, 0, RenderTextureFormat.ARGB32);
            if (!mTexture.Create())
            {
                Dispose();
                return;
            }
        }

        //写入Rendertexture
        Graphics.Blit(Texture2D.blackTexture, mTexture);
        temp = mTexture.width / mGridSize;
        mCapacity = temp * temp;
        if (loaders.Count > 0)
        {
            float u = 1f / temp;
            GL.PushMatrix();
            GL.LoadPixelMatrix(0f, mTexture.width, mTexture.height, 0f);
            RenderTexture.active = mTexture;
            for (int i = 0; i < loaders.Count; i++)
            {
                int idx = mAssetNames.IndexOf(loaders[i].texture.name);
                if (idx < 0)
                {
                    if (mAssetNames.Count >= mCapacity)
                    {
                        ChangeUITexture(loaders[i].uiTexture, loaders[i].texture, null, new Rect(0f, 0f, 1f, 1f));
                        continue;
                    }
                    idx = mAssetNames.Count;
                    mAssetNames.Add(loaders[i].texture.name);
                    Graphics.DrawTexture(new Rect((idx % temp) * mGridSize, (idx / temp) * mGridSize, mGridSize, mGridSize), loaders[i].texture, mRenderMat);

                }
                ChangeUITexture(loaders[i].uiTexture, mTexture, null, new Rect((idx % temp) * u, 1f - (idx / temp + 1) * u, u, u));
            }
            RenderTexture.active = null;
            GL.PopMatrix();
        }
    }

    public void Add(IUITextureLoader loader)
    {
        if (loader == null || loader.Equals(null)) return;
        loader.SetOnLoad(Add);
        if (!mLoaders.Contains(loader)) mLoaders.Add(loader);
        if (loader.texture)
        {
            //int gridSize = Mathf.Clamp(Mathf.NextPowerOfTwo(Mathf.Max(loader.texture.width, loader.texture.height)), 16, MAX_GRID_SIZE);
            //if (gridSize > mGridSize)
            //{
            //    mGridSize = gridSize;
            //    Repaint();
            //    return;
            //}
            if (!mTexture)
            {
                Repaint();
                return;
            }
            int max;
            int idx = mAssetNames.IndexOf(loader.texture.name);
            if (idx >= 0)
            {
                if (loader.uiTexture)
                {
                    max = mTexture.width / mGridSize;
                    if (idx < max * max)
                    {
                        float u = 1f / max;
                        ChangeUITexture(loader.uiTexture, mTexture, null, new Rect((idx % max) * u, 1f - (idx / max + 1) * u, u, u));
                    }
                }
                return;
            }

            idx = mAssetNames.Count;
            max = mTexture.width / mGridSize;
            if (idx < max * max)
            {
                float u = 1f / max;
                mAssetNames.Add(loader.texture.name);
                GL.PushMatrix();
                GL.LoadPixelMatrix(0f, mTexture.width, mTexture.height, 0f);
                RenderTexture.active = mTexture;
                Graphics.DrawTexture(new Rect((idx % max) * mGridSize, (idx / max) * mGridSize, mGridSize, mGridSize), loader.texture);
                RenderTexture.active = null;
                GL.PopMatrix();
                ChangeUITexture(loader.uiTexture, mTexture, null, new Rect((idx % max) * u, 1f - (idx / max + 1) * u, u, u));
            }
            else
            {
                Repaint();
            }
        }
    }

    public void Clear()
    {
        //mGridSize = 16;
        RestoreUITexture();
        mLoaders.Clear();
        mAssetNames.Clear();
    }

    private void RestoreUITexture()
    {
        if (mLoaders == null) return;
        foreach (IUITextureLoader loader in mLoaders)
        {
            if (loader == null || loader.Equals(null)) continue;
            if (loader.uiTexture)
            {
                ChangeUITexture(loader.uiTexture, loader.texture, null, new Rect(0f, 0f, 1f, 1f));
            }
        }
    }

    public void Dispose()
    {
        mCapacity = 0;
        if (mTexture)
        {
            RenderTexture.ReleaseTemporary(mTexture);
            //Object.Destroy(mTexture);
            mTexture = null;
        }
        Clear();
    }

    private void ChangeUITexture(UITexture utx, Texture tex, Material mat, Rect rect, int sdepth = 0)
    {
        if (utx == null) return;
        utx.mainTexture = tex;
        utx.material = mat;
        utx.parentRect = rect;
        utx.secondDepth = sdepth;
        utx.CreatePanel();
        utx.MarkAsChanged();
    }
}