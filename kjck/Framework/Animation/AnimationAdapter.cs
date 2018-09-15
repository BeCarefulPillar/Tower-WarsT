using UnityEngine;

public abstract class AnimationAdapter : MonoBehaviour
{
    public System.Action<AnimationAdapter> onFinished;

    public abstract bool isForward { get; }

    public abstract void Reset();

    public abstract void Play();
    public virtual void PlayReverse() { }
    public virtual void Play(int index, bool forward) { }

    public abstract void Pause();
    public virtual void Pause(int index) { }
    public virtual void Pause(string name) { }

    public abstract void Stop();
    public virtual void Stop(int index) { }
    public virtual void Stop(string name) { }

    public abstract bool isPlaying { get; }
    public virtual bool IsPlaying(int index) { return false; }

    public abstract bool isPause { get; }
    public virtual bool IsPause(int index) { return false; }
}
