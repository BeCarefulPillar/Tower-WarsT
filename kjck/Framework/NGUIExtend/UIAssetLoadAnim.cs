using UnityEngine;
using System.Collections.Generic;

public class UIAssetLoadAnim : UIWidget 
{
    //public static Color32 colorFrom = new Color32(255, 255, 255, 205);
    //public static Color32 colorTo = new Color32(128, 128, 128, 205);
    //public static Color32 colorBg = new Color32(128, 128, 128, 154);

    public static Color colorFrom = new Color(1f, 1f, 1f, 0.8f);
    public static Color colorTo = new Color(1f, 1f, 1f, 0.2f);
    public static Color colorBg = new Color(0f, 0f, 0f, 0.33f);

    public static int dotNum = 8;
    //public static float length = 0.7f;

    private static int _LastFrame = -1;
    private static Vector3[] _Verts = new Vector3[0];
    private static Color[] _Cols = new Color[dotNum * 4];
    private static Vector2[] _BgUV = new Vector2[4] { new Vector2(0.4375f, 0.5625f), new Vector2(0.4375f, 0.4375f), new Vector2(0.5625f, 0.4375f), new Vector2(0.5625f, 0.5625f) };
    private static Vector2[] _UV = new Vector2[4] { new Vector2(0f, 1f), new Vector2(0f, 0f), new Vector2(1f, 0f), new Vector2(1f, 1f) };

    private static void Fill(UIAssetLoadAnim target, List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        float alpha = target.alpha;
        Color cor;
        if (target.showMask)
        {
            cor = colorBg; cor.a *= alpha;
            float wf = target.width * 0.5f, hf = target.height * 0.5f;
            verts.Add(new Vector3(-wf, -hf, 0f));
            verts.Add(new Vector3(-wf, hf, 0f));
            verts.Add(new Vector3(wf, hf, 0f));
            verts.Add(new Vector3(wf, -hf, 0f));
            uvs.Add(_BgUV[0]); uvs.Add(_BgUV[1]); uvs.Add(_BgUV[2]); uvs.Add(_BgUV[3]);
            cols.Add(cor); cols.Add(cor); cols.Add(cor); cols.Add(cor);
        }

        if (_LastFrame != Time.frameCount)
        {
            _LastFrame = Time.frameCount;
            int len = dotNum * 4;
            //int index = (int)(Time.realtimeSinceStartup * dotNum) % dotNum;
            float index = (Time.realtimeSinceStartup * dotNum) % dotNum;
            if (_Cols.Length != len) System.Array.Resize(ref _Cols, len);
            if (_Verts.Length != len)
            {
                System.Array.Resize(ref _Verts, len);

                float r = 18f, s = 16;
                float sf = s * 0.5f;
                float dar = 2f * Mathf.PI / dotNum;
                float dad = dar * Mathf.Rad2Deg;
                Matrix4x4 matrix = Matrix4x4.identity;
                Vector3 v1 = new Vector3(-sf, -sf);
                Vector3 v2 = new Vector3(-sf, sf);
                Vector3 v3 = new Vector3(sf, sf);
                Vector3 v4 = new Vector3(sf, -sf);
                for (int i = 0; i < dotNum; i++)
                {
                    matrix.SetTRS(new Vector3(-r * Mathf.Cos(dar * i), r * Mathf.Sin(dar * i)), Quaternion.Euler(0f, 0f, 90f - dad * i), Vector3.one);
                    _Verts[i * 4] = matrix.MultiplyPoint3x4(v1);
                    _Verts[i * 4 + 1] = matrix.MultiplyPoint3x4(v2);
                    _Verts[i * 4 + 2] = matrix.MultiplyPoint3x4(v3);
                    _Verts[i * 4 + 3] = matrix.MultiplyPoint3x4(v4);
                }
            }
            
            index += dotNum;
            for (int i = 0; i < dotNum; i++)
            {
                cor = Color.Lerp(colorFrom, colorTo, ((index - i) % dotNum) / (float)dotNum);
                _Cols[i * 4] = cor;
                _Cols[i * 4 + 1] = cor;
                _Cols[i * 4 + 2] = cor;
                _Cols[i * 4 + 3] = cor;
            }
        }

        float rate = Mathf.Clamp01(Mathf.Min(target.width, target.height) * 0.01f);

        for (int i = 0; i < _Verts.Length; i++) verts.Add(_Verts[i] * rate);
        for (int i = 0; i < dotNum; i++) { uvs.Add(_UV[0]); uvs.Add(_UV[1]); uvs.Add(_UV[2]); uvs.Add(_UV[3]); }
        for (int i = 0; i < _Cols.Length; i++)
        {
            cor = _Cols[i];
            cor.a *= alpha;
            cols.Add(cor);
        }
    }

    public static UIAssetLoadAnim Creat(AssetLoader loader, bool showMask = false)
    {
        if (!loader || loader.isDone) return null;

        UIAssetLoadAnim ual = loader.GetComponentInAllChild<UIAssetLoadAnim>();
        if (!ual)
        {
            ual = loader.gameObject.AddWidget<UIAssetLoadAnim>("asset_loader_anim");
            ual.hideFlags = HideFlags.HideAndDontSave;
            ual._alpha = 0f;
        }
        ual._loader = loader;
        ual.showMask = showMask;
        return ual;
    }
    public static UIAssetLoadAnim Creat(AvatarLoader loader, bool showMask = false)
    {
        if (!loader || loader.isDone) return null;

        UIAssetLoadAnim ual = loader.GetComponentInAllChild<UIAssetLoadAnim>();
        if (!ual)
        {
            ual = loader.gameObject.AddWidget<UIAssetLoadAnim>("asset_loader_anim");
            ual.hideFlags = HideFlags.HideAndDontSave;
            ual._alpha = 0f;
        }
        ual._loader = loader;
        ual.showMask = showMask;
        return ual;
    }

    public static void Delete(AssetLoader loader) { if (loader)loader.GetComponentInAllChild<UIAssetLoadAnim>().DestructIfOnly(); }
    public static void Delete(AvatarLoader loader) { if (loader)loader.GetComponentInAllChild<UIAssetLoadAnim>().DestructIfOnly(); }

    [System.NonSerialized] public bool showMask = true;
    [System.NonSerialized] private IProgress _loader;
    [System.NonSerialized] private float _alpha = 0f;

    public override Texture mainTexture { get { return AssetManager.loadingTexture; } set { } }

    public override Material material { get { return null; } set { } }

    public override Shader shader { get { return AssetManager.commonShader; } set { } }

    public override float alpha { get { return _alpha; } set { } }

    protected override void OnUpdate()
    {
        if (_loader == null || _loader.Equals(null))
        {
            this.DestructIfOnly();
        }
        else
        {
            base.OnUpdate();
            mChanged = true;

            if (_loader.isDone)
            {
                if (_alpha > 0f)
                {
                    _alpha -= Time.unscaledDeltaTime * 5f;
                }
                else
                {
                    this.DestructIfOnly();
                }
            }
            else if(_alpha < 1f)
            {
                _alpha += Time.unscaledDeltaTime * 5f;
            }
        }
    }

    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        Fill(this, verts, uvs, cols);
    }
}
