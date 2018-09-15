using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[RequireComponent(typeof(UITexture))]
public class AvatarLoader : MonoBehaviour, IUITextureLoader
{
    [SerializeField] private UITexture mUITexture;
    [SerializeField] private string mAvaUrl;
    [SerializeField] private bool mLoadDefault = true;
    [SerializeField] private bool mUseAnim = true;

    [System.NonSerialized] private Avatar mAvatar;
    [System.NonSerialized] private bool mLoadTex = false;
    [System.NonSerialized] private float mFadeValue = 0f;
    [System.NonSerialized] private UIWidget.OnPostFillCallback mOnFade = null;

    public System.Action<IUITextureLoader> onLoad = null;

    private void Awake()
    {
        if (!mUITexture) mUITexture = GetComponent<UITexture>();
    }

    private void Start()
    {
        if (mAvatar == null)
        {
            if (!string.IsNullOrEmpty(mAvaUrl))
            {
                Load(mAvaUrl);
            }
        }
    }

    private void OnDestroy()
    {
        if (mOnFade != null)
        {
            mUITexture.onPostFill -= mOnFade;
            mOnFade = null;
        }
        Dispose();
    }

    public void Load(string avaUrl)
    {
        if (mUITexture && (mAvatar == null || mAvatar.url != mAvaUrl || (mAvatar != Avatar.undefined && mAvatar.isDone && !mAvatar.texture)))
        {
            Dispose();
            if (string.IsNullOrEmpty(avaUrl))
            {
                if (mLoadDefault)
                {
                    mAvatar = Avatar.undefined;
                    enabled = true;
                }
            }
            else
            {
                mAvaUrl = avaUrl;
                mAvatar = GetAvatar(mAvaUrl, this);
                enabled = true;
                if (IsInvoking("AddLoadingAnim")) CancelInvoke("AddLoadingAnim");
                Invoke("AddLoadingAnim", 0.5f);
            }
        }
    }

    public void Dispose()
    {
        mLoadTex = false;
        mAvaUrl = string.Empty;
        enabled = false;

        if (mUITexture)
        {
            ApplyTexture(null);
            mFadeValue = 0f;
        }

        if (mAvatar != null)
        {
            mAvatar.RemoveLoader(this);
            mAvatar = null;
        }

        UIAssetLoadAnim.Delete(this);
    }

    private void Update()
    {
        if (mUITexture)
        {
            //加载完成
            if (mLoadTex)
            {
                if (texture)
                {
                    if (mFadeValue < 1f)
                    {
                        mFadeValue += Time.unscaledDeltaTime * 3.33f;
                        mUITexture.MarkAsChanged();
                        if (mOnFade == null)
                        {
                            mOnFade = OnFade;
                            mUITexture.onPostFill += mOnFade;
                        }
                    }
                    else
                    {
                        mFadeValue = 1f;
                        enabled = false;
                        if (mOnFade != null)
                        {
                            mUITexture.onPostFill -= mOnFade;
                            mOnFade = null;
                        }
                    }
                }
                else
                {
                    if (mFadeValue > 0f && mUITexture.finalAlpha > 0f)
                    {
                        mFadeValue -= Time.unscaledDeltaTime * 5f / mUITexture.finalAlpha;
                        mUITexture.MarkAsChanged();
                        if (mOnFade == null)
                        {
                            mOnFade = OnFade;
                            mUITexture.onPostFill += mOnFade;
                        }
                    }
                    else
                    {
                        mFadeValue = 0f;
                        //if (mUITexture.mainTexture) mUITexture.mainTexture = null;
                        ApplyTexture(null);
                        enabled = false;
                        if (mOnFade != null)
                        {
                            mUITexture.onPostFill -= mOnFade;
                            mOnFade = null;
                        }
                    }
                }
            }
            else if (mAvatar == null)
            {
                return;
            }
            else if (mAvatar.isDone)
            {
                mLoadTex = true;
                ApplyTexture(texture);
                if (onLoad != null) onLoad(this);
                if (mOnFade == null)
                {
                    mOnFade = OnFade;
                    uiTexture.onPostFill += mOnFade;
                }
            }
            else
            {
                mAvatar.OnLoad();
            }
        }
        else
        {
            enabled = false;
        }
    }
    private void OnFade(UIWidget widget, int bufferOffset, List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        for (int i = bufferOffset; i < cols.Count; i++)
        {
            Color cor = cols[i];
            cor.a *= mFadeValue;
            cols[i] = cor;
        }
    }

    private void AddLoadingAnim()
    {
        if (mUseAnim && mUITexture && mAvatar != null && !mAvatar.isDone)
        {
            UIAssetLoadAnim ula = UIAssetLoadAnim.Creat(this, true);
            if (ula)
            {
                ula.depth = mUITexture.depth;
                ula.secondDepth = 1000;
                ula.width = mUITexture.width;
                ula.height = mUITexture.height;
            }
        }
    }

    private void ApplyTexture(Texture tex)
    {
        mUITexture.mainTexture = tex;
        mUITexture.material = null;
        mUITexture.parentRect = new Rect(0f, 0f, 1f, 1f);
        mUITexture.CreatePanel();
    }

    public bool isAlive { get { return mUITexture && (texture || (mAvatar != null && !mAvatar.isDone)); } }

    public UITexture uiTexture { get { return mUITexture; } }

    public Texture texture { get { return mAvatar != null && mAvatar.isDone ? mAvatar.texture ?? (mLoadDefault ? AssetManager.defaultAvatar : null) : null; } }

    public void SetOnLoad(System.Action<IUITextureLoader> onload)
    {
        this.onLoad = onload;
    }

    public float process { get { return mAvatar == null ? 0f : mAvatar.process; } }

    public bool isDone { get { return mAvatar != null && mAvatar.isDone; } }

    public bool isTimeOut { get { return mAvatar != null && mAvatar.isTimeOut; } }

    public string processMessage { get { return mAvatar != null ? mAvatar.processMessage : string.Empty; } }

    public static AvatarLoader LoadAvatar(UITexture utex, string avaUrl, bool loadDefault, bool useAnim)
    {
        if (!utex) return null;
        AvatarLoader loader = utex.GetComponent<AvatarLoader>() ?? utex.gameObject.AddComponent<AvatarLoader>();
        loader.mUITexture = utex;
        loader.mLoadDefault = loadDefault;
        loader.mUseAnim = useAnim;
        loader.Load(avaUrl);
        return loader;
    }

    public static void UnLoadAvatar(UITexture utex)
    {
        if (!utex) return;
        AvatarLoader loader = utex.GetComponent<AvatarLoader>();
        if (loader)
        {
            loader.Dispose();
        }
        else
        {
            utex.mainTexture = null;
            utex.material = null;
            utex.parentRect = new Rect(0f, 0f, 1f, 1f);
        }
    }

    private Avatar GetAvatar(string url, AvatarLoader loader)
    {
        if (string.IsNullOrEmpty(url) || !loader) return null;
        Avatar ava = null;
        avatars.TryGetValue(url, out ava);
        if (ava == null)
        {
            ava = new Avatar(url);
            avatars.Add(url, ava);
        }
        ava.AddLoader(loader);
        return ava;
    }

    public static void Release(bool force)
    {
        foreach (Avatar item in avatars.Values)
        {
            item.Dispose(force);
        }
    }

    private static Dictionary<string, Avatar> avatars = new Dictionary<string, Avatar>();

    private class Avatar : IProgress
    {
        public static readonly Avatar undefined = new Avatar(string.Empty);

        private string _url;
        private Texture2D _texture;
        private bool _done = false;
        private WWW www;
        private float lastLoadTime = 0f;

        private List<AvatarLoader> _loaders;

        public Avatar(string url)
        {
            this._url = url;
            if (string.IsNullOrEmpty(url))
            {
                _done = true;
            }
            else
            {
                www = new WWW(url);
            }
        }

        public void OnLoad()
        {
            if (_done || www == null) return;
            if (www.isDone)
            {
                _done = true;
                if (_texture)
                {
                    Object.Destroy(_texture);
                    _texture = null;
                }
                if (string.IsNullOrEmpty(www.error))
                {
                    _texture = www.texture;
                }
                else
                {
                    Debug.Log("Load Avatar Error : " + www.error);
                }
                www.Dispose();
                www = null;
            }
        }

        public void AddLoader(AvatarLoader loader)
        {
            if (loader)
            {
                if (_loaders == null) _loaders = new List<AvatarLoader>(4);
                else if (_loaders.Contains(loader)) return;
                _loaders.Add(loader);
                if (_done && !_texture && !string.IsNullOrEmpty(_url))
                {
                    _done = false;
                    www = new WWW(_url);
                }
                lastLoadTime = Time.realtimeSinceStartup;
            }
        }
        public void RemoveLoader(AvatarLoader loader)
        {
            if (_loaders != null && loader)
            {
                _loaders.Remove(loader);
                lastLoadTime = Time.realtimeSinceStartup;
            }
        }

        public void Dispose(bool force)
        {
            if (unUse && (force || isToLongNotUse))
            {
                if (_texture)
                {
                    Object.Destroy(_texture);
                    _texture = null;
                }
                if (www != null)
                {
                    www.Dispose();
                    www = null;
                }
                if (_loaders != null)
                {
                    _loaders.Clear();
                    _loaders = null;
                }
            }
        }

        public string url { get { return _url; } }

        public Texture texture { get { return _texture; } }

        public bool unUse
        {
            get
            {
                if (_loaders == null) return true;
                for (int i = 0; i < _loaders.Count; i++) if (_loaders[i]) return false;
                return true;
            }
        }

        public bool isToLongNotUse { get { return Time.realtimeSinceStartup - lastLoadTime > 180f; } }

        public float process { get { return _done ? 1f : 0f; } }

        public bool isDone { get { return _done; } }

        public bool isTimeOut { get { return false; } }

        public string processMessage { get { return string.Empty; } }
    }
}
