using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]
public class WordEffect : MonoBehaviour {
    public enum EffectStyle
    {
        None,
        Upper,
        Right,
        Left,
        UpperRight,
        UpperLeft,
        Amplification,
        Fade,
    }

    [SerializeField] Font font;
    [SerializeField] int fontSize = 24;
    [SerializeField] string text = "";
    [SerializeField] float width = 0;
    [SerializeField] Color color = Color.white;
    [SerializeField] EffectStyle effect = EffectStyle.None;
    [SerializeField] float sleep = 1;
    [SerializeField] float rate = 0.1f;
    [SerializeField] float sTime = 0.3f;
	[SerializeField] UIWidget.Pivot pivot = UIWidget.Pivot.Center;
	[SerializeField] int depth = 0;
    [SerializeField] bool vertical = false;
    [SerializeField] float lineSpace = 0f;

    [SerializeField][HideInInspector] UILabel[] texts;

    private const int BASE_SIZE = 32;

    Transform trans;
    Vector2 size = Vector2.zero;
    bool isPlay = false;
    int playIndex = 0;
    float deltaTime = 0;

    public Font Font
    {
        get
        {
            return font;
        }
        set
        {
            if (font == value) return;
            font = value;
            Change();
        }
    }

    public int FontSize
    {
        get
        {
            return fontSize;
        }
        set
        {
            if (fontSize == value) return;
            fontSize = value;
            Change();
        }
    }

    public float MaxWidth
    {
        get
        {
            return width;
        }
        set
        {
            if (width == value) return;
            width = value;
            Change();
        }
    }

    public float LineSpace
    {
        get
        {
            return lineSpace;
        }
        set
        {
            if (lineSpace == value) return;
            lineSpace = value;
            Change();
        }
    }

    public bool Vertical
    {
        get { return vertical; }
        set
        {
            if (vertical == value) return;
            vertical = value;
            Change();
        }
    }

    public string Text
    {
        get
        {
            return text;
        }
        set
        {
            if (text == value) return;
            text = value;
            Change();
            if (Application.isPlaying) Play();
        }
    }

    public EffectStyle Effect
    {
        get
        {
            return effect;
        }
        set
        {
            if (effect == value) return;
            effect = value;
            Change();
        }
    }

    public Color Color
    {
        get
        {
            return color;
        }
        set
        {
            if (color == value) return;
            color = value;
            if (texts != null) foreach (UILabel lab in texts) if (lab) lab.color = color;
        }
    }

    public float Sleep { get { return sleep; } set { sleep = value; } }
    public float Rate { get { return rate; } set { rate = value; } }
    public float STime { get { return sTime; } set { sTime = value; } }

    public UIWidget.Pivot Pivot
    {
        get
        {
            return pivot;
        }
        set
        {
            if (pivot == value) return;
            pivot = value;
            Change();
        }
    }

    public int Depth
    {
        get
        {
            return depth;
        }
        set
        {
            if (depth == value) return;
            depth = value;
            if (texts != null) foreach (UILabel lab in texts) if (lab) lab.depth = depth;
        }
    }

    public void Play()
    {
        if (string.IsNullOrEmpty(text)) { Clear(); return; }
        if (texts == null) Change();
        StopAllCoroutines();
        if (effect == EffectStyle.None) return;
        foreach (UILabel lab in texts)
        {
            if (!lab) continue;
            UITweener tw = lab.gameObject.GetComponent<UITweener>();
            if (tw != null)
            {
                if (tw is TweenPosition) lab.cachedTransform.localPosition = (tw as TweenPosition).from;
                else if (tw is TweenScale) lab.cachedTransform.localScale = (tw as TweenScale).from;
#if UNITY_EDITOR
                DestroyImmediate(tw);
#else 
                Destroy(tw);
#endif
            }
            AddTween(lab);
        }
        //StartCoroutine(WordAnim());
        playIndex = 0;
        deltaTime = 0;
        isPlay = true;
    }

    IEnumerator WordAnim()
    {
        isPlay = true;
        while (enabled)
        {
            foreach (UILabel lab in texts)
            {
                if (lab)
                {
                    UITweener tw = lab.gameObject.GetComponent<UITweener>();
                    if (tw) tw.Play(true);
                }
                yield return new WaitForSeconds(rate);
            }
            if (sleep > 0)
            {
                yield return new WaitForSeconds(sleep);
                if (effect == EffectStyle.Fade)
                {
                    foreach (UILabel lab in texts)
                    {
                        if (!lab) continue;
                        UITweener tw = lab.GetComponent<UITweener>();
                        tw.ResetToBeginning();
                        tw.enabled = false;
                        lab.color = new Color(color.r, color.g, color.b, 0);
                    }  
                }
            }
            else break;
        }
        isPlay = false;
    }


    void Update()
    {
        if (!isPlay || texts == null) return;
        if (playIndex < texts.Length)
        {
            if (deltaTime < rate) deltaTime += Time.deltaTime;
            else
            {
                deltaTime = 0;
                UILabel lab = texts[playIndex++];
                if (lab)
                {
                    UITweener tw = lab.gameObject.GetComponent<UITweener>();
                    if (tw) tw.Play(true);
                }
            }
        }
        else if (sleep > 0)
        {
            if (deltaTime < rate + sleep) deltaTime += Time.deltaTime;
            else
            {
                deltaTime = 0;
                playIndex = 0;
                if (effect == EffectStyle.Fade)
                {
                    foreach (UILabel lab in texts)
                    {
                        if (!lab) continue;
                        UITweener tw = lab.GetComponent<UITweener>();
                        tw.ResetToBeginning();
                        tw.enabled = false;
                        lab.color = new Color(color.r, color.g, color.b, 0);
                    }
                }
            }
        }
        else isPlay = false;
    }

    void Change()
    {
        if (font == null || string.IsNullOrEmpty(text)) { Clear(); return; }
        Dispose();
        if (effect == EffectStyle.None)
        {
            texts = new UILabel[1];

            UILabel lab = texts[0] = gameObject.AddWidget<UILabel>("text");
            if (MaxWidth > 0)
            {
                lab.overflowMethod = UILabel.Overflow.ResizeHeight;
                lab.width = (int)MaxWidth;
            }
            else lab.overflowMethod = UILabel.Overflow.ResizeFreely;
            lab.trueTypeFont = font;
            lab.fontSize = fontSize;
            lab.supportEncoding = false;
            lab.color = color;
            lab.depth = depth;
            lab.pivot = pivot;
            lab.width = (int)MaxWidth;
            lab.text = text;
            lab.cachedTransform.localPosition = Vector3.zero;
            lab.MarkAsChanged();
            size = lab.printedSize;
            return;
        }
        //string txt = text.Replace("\n", "");
        int len = text.Length;
        texts = new UILabel[len];

        Vector2[] positions = vertical ? GetLayoutVertical() : GetLayout();
        for (int i = 0; i < len; i++)
        {
            char c = text[i];
            if (c == '\n' || c == '\0') continue;
            UILabel lab = texts[i] = gameObject.AddWidget<UILabel>("word_" + i);
            lab.overflowMethod = UILabel.Overflow.ShrinkContent;
            lab.trueTypeFont = font;
            lab.fontSize = BASE_SIZE;
            lab.supportEncoding = false;
            lab.maxLineCount = 1;
            lab.color = color;
            lab.depth = depth;
            lab.height = lab.width = fontSize;
            lab.cachedTransform.localPosition = positions[i];
            lab.text = c.ToString();
            lab.MarkAsChanged();
        }
        if (Application.isPlaying && isPlay) Play();
    }

    Vector2[] GetLayoutVertical()
    {
        if (string.IsNullOrEmpty(text)) return new Vector2[] { Vector2.zero };
        List<List<float>> layout = new List<List<float>>();
        layout.Add(new List<float>());
        int line = 0;
        float h = 0;
        size = Vector2.zero;
        char[] chars = text.ToCharArray();
        foreach (char c in chars)
        {
            if (c == '\n')
            {
                size.y = Mathf.Max(size.y, h);
                layout[line].Add(0);
                layout[line].Add(h);
                line++;
                h = 0;
                layout.Add(new List<float>());
                continue;
            }
            float ch = (float)fontSize;
            layout[line].Add(ch);
            if (width > 0 && h + ch > width)
            {
                size.y = h;
                layout[line].Add(h);
                line++;
                h = 0;
                layout.Add(new List<float>());
            }
            h += ch;
        }
        size.y = Mathf.Max(size.y, h);
        layout[line].Add(h);
        line++;

        List<Vector2> result = new List<Vector2>();
        size.x = line * fontSize + (line - 1) * lineSpace;
        for (int i = 0; i < line; i++)
        {
            float[] hs = layout[i].ToArray();
            int len = hs.Length - 1;
            float lh = hs[len];
            Vector2 pos = InitVerticalPos(size.x, lh, i);
            for (int j = 0; j < len; j++)
            {
                pos.y -= hs[j] * 0.5f;
                result.Add(pos);
                pos.y -= hs[j] * 0.5f;
            }
        }
        return result.ToArray();
    }
    Vector2 InitVerticalPos(float width, float height, int lineIdx)
    {
        switch (pivot)
        {
            default:
            case UIWidget.Pivot.Center:
                return new Vector2(-width * 0.5f + (lineIdx + 0.5f) * fontSize + lineIdx * lineSpace, height * 0.5f);
            case UIWidget.Pivot.Left:
                return new Vector2((lineIdx + 0.5f) * fontSize + lineIdx * lineSpace, height * 0.5f);
            case UIWidget.Pivot.TopLeft:
                return new Vector2((lineIdx + 0.5f) * fontSize + lineIdx * lineSpace, 0);
            case UIWidget.Pivot.Top:
                return new Vector2(-width * 0.5f + (lineIdx + 0.5f) * fontSize + lineIdx * lineSpace, 0);
            case UIWidget.Pivot.TopRight:
                return new Vector2(-width + (lineIdx + 0.5f) * fontSize + lineIdx * lineSpace, 0);
            case UIWidget.Pivot.Right:
                return new Vector2(-width + (lineIdx + 0.5f) * fontSize + lineIdx * lineSpace, height * 0.5f);
            case UIWidget.Pivot.Bottom:
                return new Vector2(-width * 0.5f + (lineIdx + 0.5f) * fontSize + lineIdx * lineSpace, height);
            case UIWidget.Pivot.BottomLeft:
                return new Vector2((lineIdx + 0.5f) * fontSize + lineIdx * lineSpace, height);
            case UIWidget.Pivot.BottomRight:
                return new Vector2(-width + (lineIdx + 0.5f) * fontSize + lineIdx * lineSpace, height);
        }
    }
    Vector2[] GetLayout()
    {
        if (string.IsNullOrEmpty(text)) return new Vector2[] { Vector2.zero };
        List<List<float>> layout = new List<List<float>>();
        layout.Add(new List<float>());
        int line = 0;
        float w = 0;
        size = Vector2.zero;
        char[] chars = text.ToCharArray();
        foreach (char c in chars)
        {
            if (c == '\n')
            {
                size.x = Mathf.Max(size.x, w);
                layout[line].Add(0);
                layout[line].Add(w);
                line++;
                w = 0;
                layout.Add(new List<float>());
                continue;
            }
            else if (c == '\0')
            {
                layout[line].Add(0);
                continue;
            }
            CharacterInfo ci;
            float cw = 0;
            if (font.GetCharacterInfo(c, out ci, BASE_SIZE))
            {
                //cw = ci.width;
                cw = ci.advance * fontSize / BASE_SIZE;
            }
            else
            {
                font.RequestCharactersInTexture(text.Replace("\0", ""), BASE_SIZE);
                if (font.GetCharacterInfo(c, out ci, BASE_SIZE))
                {
                    //cw = ci.width;
                    cw = ci.advance * fontSize / BASE_SIZE;
                }
            }
            layout[line].Add(cw);
            if (width > 0 && w + cw > width)
            {
                size.x = w;
                layout[line].Add(w);
                line++;
                w = 0;
                layout.Add(new List<float>());
            }
            w += cw;
        }
        size.x = Mathf.Max(size.x, w);
        layout[line].Add(w);
        line++;

        List<Vector2> result = new List<Vector2>();
        size.y = line * fontSize + (line - 1) * lineSpace;
        for (int i = 0; i < line; i++)
        {
            float[] ws = layout[i].ToArray();
            int len = ws.Length - 1;
            float lw = ws[len];
            Vector2 pos = InitPos(lw, size.y, i);
            for (int j = 0; j < len; j++)
            {
                pos.x += ws[j] * 0.5f;
                result.Add(pos);
                pos.x += ws[j] * 0.5f;
            }
        }
        return result.ToArray();
    }
    Vector2 InitPos(float lineWidth, float height, int lineIdx)
    {
        switch (pivot)
        {
            default:
            case UIWidget.Pivot.Center:
                return new Vector2(-lineWidth * 0.5f, height * 0.5f - (lineIdx + 0.5f) * fontSize - lineIdx * lineSpace);
            case UIWidget.Pivot.Left:
                return new Vector2(0, height * 0.5f - (lineIdx + 0.5f) * fontSize - lineIdx * lineSpace);
            case UIWidget.Pivot.TopLeft:
                return new Vector2(0, -(lineIdx + 0.5f) * fontSize - lineIdx * lineSpace);
            case UIWidget.Pivot.Top:
                return new Vector2(-lineWidth * 0.5f, -(lineIdx + 0.5f) * fontSize - lineIdx * lineSpace);
            case UIWidget.Pivot.TopRight:
                return new Vector2(-lineWidth, -(lineIdx + 0.5f) * fontSize - lineIdx * lineSpace);
            case UIWidget.Pivot.Right:
                return new Vector2(-lineWidth, height * 0.5f - (lineIdx + 0.5f) * fontSize - lineIdx * lineSpace);
            case UIWidget.Pivot.Bottom:
                return new Vector2(-lineWidth * 0.5f, height - (lineIdx + 0.5f) * fontSize - lineIdx * lineSpace);
            case UIWidget.Pivot.BottomLeft:
                return new Vector2(0, height - (lineIdx + 0.5f) * fontSize - lineIdx * lineSpace);
            case UIWidget.Pivot.BottomRight:
                return new Vector2(-lineWidth, height - (lineIdx + 0.5f) * fontSize - lineIdx * lineSpace);
        }
    }

    void AddTween(UILabel lab)
    {
        switch (effect)
        {
            case EffectStyle.Upper:
                TweenPosition utp = lab.gameObject.AddComponent<TweenPosition>();
                utp.enabled = false;
                utp.duration = STime;
                utp.method = UITweener.Method.EaseInOut;
                utp.style = UITweener.Style.PingPongOnce;
                utp.from = utp.to = lab.cachedTransform.localPosition;
                utp.to.y += 10;
                return;
            case EffectStyle.UpperRight:
                TweenPosition urtp = lab.gameObject.AddComponent<TweenPosition>();
                urtp.enabled = false;
                urtp.duration = STime;
                urtp.method = UITweener.Method.EaseInOut;
                urtp.style = UITweener.Style.PingPongOnce;
                urtp.from = urtp.to = lab.cachedTransform.localPosition;
                urtp.to.y += 10;
                urtp.to.x += 5;
                return;
            case EffectStyle.Left:
                TweenPosition ltp = lab.gameObject.AddComponent<TweenPosition>();
                ltp.enabled = false;
                ltp.duration = STime;
                ltp.method = UITweener.Method.EaseInOut;
                ltp.style = UITweener.Style.PingPongOnce;
                ltp.from = ltp.to = lab.cachedTransform.localPosition;
                ltp.to.x -= 10;
                return;
            case EffectStyle.Right:
                TweenPosition rtp = lab.gameObject.AddComponent<TweenPosition>();
                rtp.enabled = false;
                rtp.duration = STime;
                rtp.method = UITweener.Method.EaseInOut;
                rtp.style = UITweener.Style.PingPongOnce;
                rtp.from = rtp.to = lab.cachedTransform.localPosition;
                rtp.to.x += 10;
                return;
            case EffectStyle.UpperLeft:
                TweenPosition ultp = lab.gameObject.AddComponent<TweenPosition>();
                ultp.enabled = false;
                ultp.duration = STime;
                ultp.method = UITweener.Method.EaseInOut;
                ultp.style = UITweener.Style.PingPongOnce;
                ultp.from = ultp.to = lab.cachedTransform.localPosition;
                ultp.to.x -= 5;
                ultp.to.y += 10;
                return;
            case EffectStyle.Amplification:
                TweenScale ts = lab.gameObject.AddComponent<TweenScale>();
                ts.enabled = false;
                ts.duration = STime;
                ts.method = UITweener.Method.EaseInOut;
                ts.style = UITweener.Style.PingPongOnce;
                ts.from = ts.to = lab.cachedTransform.localScale;
                ts.to.x *= 1.5f;
                ts.to.y *= 1.5f;
                return;
            case EffectStyle.Fade:
                TweenAlpha ta = lab.gameObject.AddComponent<TweenAlpha>();
                ta.enabled = false;
                ta.duration = STime;
                ta.method = UITweener.Method.Linear;
                ta.style = UITweener.Style.Once;
                lab.color = new Color(color.r, color.g, color.b, 0);
                ta.from = 0;
                ta.to = 1;
                return;
        }
    }

    void Dispose()
    {
        StopAllCoroutines();
        size = Vector2.zero;
        if (texts != null)
        {
            CachedTransform.DetachChildren();
            foreach (UILabel lab in texts)
            {
                if (lab)
                {
#if UNITY_EDITOR
                    DestroyImmediate(lab.gameObject);
#else 
                    Destroy(lab.gameObject);
#endif
                }
            }
            texts = null;
        }
    }

    public void Clear()
    {
        Dispose();
        text = "";
    }

    public Transform CachedTransform { get { if (trans == null)trans = transform; return trans; } }
    public Vector2 Size { get { return size; } }
    public UILabel[] Labels { get { return texts; } }
}
