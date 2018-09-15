using UnityEngine;
using System.Collections.Generic;

public class SOESet : MonoBehaviour
{
    private const char split = '_';
    public int namePart = 0;
    public AudioClip[] clips;

    [System.NonSerialized] Dictionary<string, AudioClip> cache = null;

    private void CheckCache()
    {
        if (cache != null || clips.GetLength() < 1) return;
        cache = new Dictionary<string, AudioClip>(clips.Length);
        for (int i = 0; i < clips.Length; i++)
        {
            if (clips[i])
            {
                cache[GetName(clips[i].name)] = clips[i];
            }
        }
    }

    private string GetName(string nm)
    {
        if (namePart == 0 || string.IsNullOrEmpty(nm)) return nm;
        if (namePart > 0)
        {
            int idx = -1;
            while (namePart > 0)
            {
                idx = nm.IndexOf(split, idx + 1);
                if (idx > 0)
                {
                    namePart--;
                }
                else
                {
                    break;
                }
            }
            return idx > 0 ? nm.Substring(idx + 1) : nm;
        }
        else
        {
            int idx = nm.Length;
            while (namePart < 0)
            {
                idx = nm.LastIndexOf(split, idx - 1);
                if (idx > 0)
                {
                    namePart++;
                }
                else
                {
                    break;
                }
            }
            return idx > 0 ? nm.Substring(0, idx) : nm;
        }
    }

    public AudioClip Get(string clip)
    {
        CheckCache();
        if (cache == null) return null;
        AudioClip ac = null;
        cache.TryGetValue(clip, out ac);
        return ac;
    }
    public AudioClip Get(int index)
    {
        return clips.IndexAvailable(index) ? clips[index] : null;
    }
}
