using UnityEngine;

[RequireComponent(typeof(UITexture))]
public class TextureAnimation : MonoBehaviour
{
    public enum Style
    {
        Once,
        Repeat,
        Loop,
    }
    public Texture2D[] textures;
    public bool autoPlay = false;
    public int framePerSec = 12;
    public Vector2 size = Vector2.zero;
    public Style style = Style.Once;
    public System.Action<TextureAnimation> onFinished;

    UITexture utx;
    int index = 0;
    int direction = 1;
    float dt = 0;

    void Awake() { utx = GetComponent<UITexture>(); if (!utx)utx = gameObject.AddComponent<UITexture>(); }
    void Start() { enabled = autoPlay; }

    void OnEnable() { if (textures == null || textures.Length <= 0) enabled = false; }

    void Update()
    {
        if (dt > 0) dt -= Time.deltaTime;
        else
        {
            dt = 1f / framePerSec;
            int len = textures.Length;
            if (direction == 1)
            {
                if (index >= len)
                {
                    if (style == Style.Repeat) { direction = 1; index = 0; }
                    else if (style == Style.Loop) { direction = -1; index = len - 1; }
                    else
                    {
                        enabled = false;
                        if (onFinished != null) onFinished(this);
                        return;
                    }
                }
            }
            else if (direction == -1)
            {
                if (index < 0)
                {
                    if (style == Style.Loop) { direction = 1; index = 0; }
                    else
                    {
                        enabled = false;
                        if (onFinished != null) onFinished(this);
                        return;
                    }
                }
            }
            else return;
            
            utx.mainTexture = textures[index];
            if (size == Vector2.zero) utx.MakePixelPerfect();
            else
            {
                utx.width = (int)size.x;
                utx.height = (int)size.y;
            }
            index += direction;
        }
    }

    public void Reset() { index = 0; direction = 1; if (utx)utx.mainTexture = textures[index]; }

    public void Play(float time, Style style, Texture2D[] texs)
    {
        if (texs != null || texs.Length > 0) textures = texs;
        if (textures == null || textures.Length <= 0) return;
        this.style = style;
        time = Mathf.Max(time, 0.01f);
        framePerSec = Mathf.CeilToInt(textures.Length / time);
        Reset();
        enabled = true;
    }

    public void Play(int framePerSec, Style style, Texture2D[] texs)
    {
        if (texs != null || texs.Length > 0) textures = texs;
        if (textures == null || textures.Length <= 0) return;
        this.style = style;
        this.framePerSec = framePerSec;
        Reset();
        enabled = true;
    }
}
