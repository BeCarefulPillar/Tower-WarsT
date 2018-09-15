using UnityEngine;
using System.Collections.Generic;

[RequireComponent(typeof(AudioSource))]
public class BGM : MonoBehaviour
{
    private static BGM _Instance;

    public static void Init()
    {
        if (_Instance == null)
        {
            AudioListener al = FindObjectOfType<AudioListener>();
            if (al != null)
            {
                _Instance = FindObjectOfType<BGM>();
                if (_Instance == null)
                {
                    _Instance = new GameObject().AddComponent<BGM>();
                }
                _Instance.gameObject.name = "BGM";
                Transform t = _Instance.transform;
                t.parent = al.transform;
                t.localPosition = Vector3.zero;
                t.localRotation = Quaternion.identity;
                t.localScale = Vector3.one;
                _Instance.gameObject.layer = al.gameObject.layer;
                AudioSource source = _Instance.gameObject.GetComponent<AudioSource>() ?? _Instance.gameObject.AddComponent<AudioSource>();
                source.volume = _Volume;
                source.playOnAwake = false;
                _Instance.mSource = source;

                DontDestroyOnLoad(t.root);
            }
            else
            {
                Debug.LogWarning("BGM need [AudioListener], But the scene not contain!");
            }
        }
    }

    public static bool mute
    {
        get
        {
            return _Instance == null || !_Instance.enabled || !_Instance.mSource.enabled;
        }
        set
        {
            if (_Instance && mute != value)
            {
                PlayerPrefs.SetInt("Mute", value ? 1 : 0);
                value = !value;
                _Instance.enabled = value;
                _Instance.mSource.enabled = value;
            }
        }
    }
    public static float volume
    {
        get { return _Volume; }
        set
        {
            if (_Instance)
            {
                value = Mathf.Clamp01(value);
                if (_Volume == value) return;
                _Volume = value;
                if (!_Instance.mIsChanging) _Instance.mSource.volume = _Volume;
                PlayerPrefs.SetFloat("Music", _Volume);
                _Instance.enabled = _Volume > 0;
                _Instance.mSource.enabled = _Volume > 0;
            }
        }
    }

    public static void Play(params string[] bgms) { if (_Instance) _Instance.PlayMusic(bgms); }

    public static void Quite(float time)
    {
        if (time > 0)
        {
            _Quite = Time.realtimeSinceStartup + time;
            AudioListener.pause = true;
        }
        else
        {
            _Quite = 0f;
            AudioListener.pause = false;
        }
    }

    public AudioSource mSource;

    private static float _Volume = 0.5f;
    private static float _Quite = 0f;

    private string[] mAnthology;
    private string mCurrent = "";
    private bool mIsChanging = false;

    void Awake()
    {
        if (_Instance == null)
        {
            _Instance = this;
            DontDestroyOnLoad(_Instance.transform.root);
        }
        else if (_Instance != this)
        {
            this.DestructIfOnly();
        }
    }

    void Start()
    {
        _Volume = PlayerPrefs.GetFloat("Music", 0.5f);
        mute = PlayerPrefs.GetInt("Mute", 0) == 1;
    }

    void Update()
    {
        if (_Quite > 0f && _Quite < Time.realtimeSinceStartup)
        {
            AudioListener.pause = false;
            _Quite = 0f;
        }
        if (enabled && mSource.enabled)
        {
            if (mIsChanging)
            {
                if (mSource.clip == null || mSource.clip.name != mCurrent)
                {
                    if (mSource.volume > 0f)
                    {
                        if (mSource.isPlaying) mSource.volume -= Time.deltaTime * 0.4f;
                        else mSource.volume = 0f;
                        return;
                    }

                    mSource.volume = 0f;
                    mSource.Stop();
                    mSource.clip = string.IsNullOrEmpty(mCurrent) ? null : AssetManager.Load<AudioClip>(mCurrent);

                    if (mSource.clip == null || mSource.clip.name != mCurrent)
                    {
                        mAnthology = null;
                        mIsChanging = false;
                    }
                    else mSource.Play();
                }
                else
                {
                    if (!mSource.isPlaying) mSource.Play();
                    if (mSource.volume < _Volume) mSource.volume += Time.deltaTime * 0.4f;
                    else
                    {
                        mSource.volume = _Volume;
                        mIsChanging = false;
                    }
                }
            }
            else if (!mSource.isPlaying && mAnthology != null && mAnthology.Length > 0)
            {
                mSource.volume = 0f;
                mCurrent = mAnthology[Random.Range(0, mAnthology.Length)];
                Debug.Log("begin bgm :" + mCurrent);
                mIsChanging = true;
            }
        }
    }

    public void PlayMusic(params string[] bgms)
    {
        if (EqualBgms(mAnthology, bgms)) return;
        mCurrent = "";
        mAnthology = bgms;
        if (mAnthology != null)
        {
            int len = mAnthology.Length;
            if (len > 0) mCurrent = mAnthology[Random.Range(0, len)];
            else mAnthology = null;
        }
        mIsChanging = true;
    }

    private bool EqualBgms(string[] l, string[] r)
    {
        if (l == null || r == null || l.Length != r.Length) return false;
        for (int i = 0; i < l.Length; i++)
        {
            if (l[i] != r[i]) return false;
        }
        return true;
    }
}
