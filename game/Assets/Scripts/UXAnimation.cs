using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Drawing;
using System.Drawing.Imaging;
using UnityEditor;
using UnityEngine.UI;

[System.Serializable]
public class UXAnimationClip
{
    public string name;
    public Object gif;
    public Texture2D[] texs;
}

[RequireComponent(typeof(RawImage))]
public class UXAnimation : MonoBehaviour
{
    private RawImage img;

    public UXAnimationClip[] animations;

    private Queue<UXAnimationClip> queue = new Queue<UXAnimationClip>();

    [Range(0, 10)]
    public float speed = 6.0f;
    private float tm = 0.0f;

    public delegate void UXAnimationEvent(UXAnimationClip clip);
    public UXAnimationEvent begin;
    public UXAnimationEvent end;

    private void Start()
    {
        img = GetComponent<RawImage>();
        foreach (UXAnimationClip clip in animations)
        {
            System.Drawing.Image gif = System.Drawing.Image.FromFile(AssetDatabase.GetAssetPath(clip.gif));
            if (!ImageAnimator.CanAnimate(gif))
            {
                gif.Dispose();
                Debug.LogError("UXAnimation error");
                continue;
            }
            FrameDimension dimension = new FrameDimension(gif.FrameDimensionsList[0]);
            int frameQty = gif.GetFrameCount(dimension);
            clip.texs = new Texture2D[frameQty];
            for (int i = 0; i < frameQty; ++i)
            {
                gif.SelectActiveFrame(dimension, i);
                Bitmap frame = new Bitmap(gif.Width, gif.Height);
                System.Drawing.Graphics.FromImage(frame).DrawImage(gif, Point.Empty);
                Texture2D tex = new Texture2D(frame.Width, frame.Height);
                for (int x = 0; x < frame.Width; ++x)
                {
                    for (int y = 0; y < frame.Height; ++y)
                    {
                        System.Drawing.Color c = frame.GetPixel(x, y);
                        tex.SetPixel(x, frame.Height - 1 - y, new Color32(c.R, c.G, c.B, c.A));
                    }
                }
                tex.Apply();
                clip.texs[i] = tex;
                frame.Dispose();
            }
            gif.Dispose();
        }

        queue.Enqueue(animations[0]);

        begin += Begin;
        end += End;
    }

    private void Update()
    {
        if (img == null || queue.Count==0)
            return;

        UXAnimationClip tmp = queue.Peek();

        int index = (int)(tm * speed) % tmp.texs.Length;
        tm += Time.deltaTime;

        if(index==0)
        {
            if (begin != null)
                begin(tmp);
        }
        else if(index==tmp.texs.Length-1)
        {
            if (end != null)
                end(tmp);
            if (queue.Count > 1)
                queue.Dequeue();
        }

        img.texture = tmp.texs[index];

#if TEST
        if (Input.GetKeyDown(KeyCode.A))
            PlayQueued("a");
        if (Input.GetKeyDown(KeyCode.B))
            PlayQueued("b");
        if (Input.GetKeyDown(KeyCode.C))
            PlayQueued("c");
#endif
    }

    private void Begin(UXAnimationClip clip)
    {
        Debug.Log("begin - "+clip.name);
    }

    private void End(UXAnimationClip clip)
    {
        Debug.Log("end - "+clip.name);
    }

    public void Play(string animation)
    {
        if (string.IsNullOrEmpty(animation))
            return;
        for (int i = 0; i < animations.Length; ++i)
        {
            if (animations[i].name == animation)
            {
                queue.Clear();
                queue.Enqueue(animations[i]);
                tm = 0.0f;
                break;
            }
        }
    }

    public void PlayQueued(string animation)
    {
        if (string.IsNullOrEmpty(animation))
            return;
        for (int i = 0; i < animations.Length; ++i)
        {
            if (animations[i].name == animation)
            {
                queue.Enqueue(animations[i]);
                break;
            }
        }
    }
}