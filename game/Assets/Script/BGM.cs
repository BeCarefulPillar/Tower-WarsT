using UnityEngine;

public class BGM : Manager<BGM>
{
    private AudioSource mSource;

    public override void Init()
    {
        base.Init();

        GameObject go = gameObject;
        go.AddCmp<AudioListener>();
        mSource = go.AddCmp<AudioSource>();
        mSource.volume = PlayerPrefs.GetFloat("BGM.volume", 0.5f);
        mSource.playOnAwake = false;
    }

    public float volume
    {
        get
        {
            return mSource.volume;
        }
        set
        {
            if (value != mSource.volume)
            {
                mSource.volume = value;
                PlayerPrefs.SetFloat("BGM.volume", mSource.volume);
            }
        }
    }

    public void PlayMusic(string nm)
    {
    }

    public void PlayMusic(AudioClip clip)
    {
    }

    public void PlaySound(string nm)
    {
    }

    public void PlaySound(AudioClip clip)
    {
    }
}