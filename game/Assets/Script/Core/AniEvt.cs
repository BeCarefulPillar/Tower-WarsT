using System;
using UnityEngine;
using Object = UnityEngine.Object;

/// <summary>
/// 动画事件
/// </summary>
public class AniEvt : MonoBehaviour
{
    /// <summary>
    /// 参数类型
    /// </summary>
    public enum EvtType
    {
        None,
        Float,
        Int,
        String,
        Object,
    }

    [Serializable]
    public struct Evt
    {
        public string cnm;
        public string fnm;
        public float fp;
        public int ip;
        public string sp;
        public Object op;
        public float tm;
        public EvtType type;
    }

    public Evt[] evts;
    public AnimationClip[] clips;

    private void Awake()
    {
        if (clips == null)
        {
            Animator ar = GetComponent<Animator>();
            if (ar)
                clips = ar.runtimeAnimatorController.animationClips;
            Animation an = GetComponent<Animation>();
            int qty = an ? an.GetClipCount() : 0;
            if (qty > 0)
            {
                if (clips != null)
                    Array.Resize(ref clips, clips.Length + qty);
                else
                    clips = new AnimationClip[qty];
                qty = clips.Length - qty;
                foreach (AnimationState e in an)
                    clips[qty++] = e.clip;
            }
        }
        if (evts != null && clips != null)
        {
            for (int i = evts.Length - 1; i >= 0; --i)
            {
                for (int j = clips.Length - 1; j >= 0; --j)
                {
                    if (evts[i].cnm == clips[j].name)
                    {
                        AnimationEvent ae = new AnimationEvent();
                        ae.functionName = evts[i].fnm;
                        ae.time = evts[i].tm;
                        switch (evts[i].type)
                        {
                            case EvtType.None:
                                break;
                            case EvtType.Float:
                                ae.floatParameter = evts[i].fp;
                                break;
                            case EvtType.Int:
                                ae.intParameter = evts[i].ip;
                                break;
                            case EvtType.String:
                                ae.stringParameter = evts[i].sp;
                                break;
                            case EvtType.Object:
                                ae.objectReferenceParameter = evts[i].op;
                                break;
                        }
                        clips[j].AddEvent(ae);
                        break;
                    }
                }
            }
        }
    }
}