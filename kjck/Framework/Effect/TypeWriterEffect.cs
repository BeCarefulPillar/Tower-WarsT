using UnityEngine;
using System.Text;

/// <summary>
/// Trivial script that fills the label's contents gradually, as if someone was typing.
/// </summary>

[RequireComponent(typeof(UILabel))]
[AddComponentMenu("NGUI/Examples/Typewriter Effect")]
public class TypeWriterEffect : MonoBehaviour
{
    private struct FadeChar
    {
        public float lifeTime;
        public char c;
    }

    /// <summary>
    /// 每秒显示字符数
    /// </summary>
    public int charsPerSecond = 20;
    /// <summary>
    /// 每个字符淡入时间
    /// </summary>
    public float fadeInTime = 0f;
    /// <summary>
    /// 标点的延时
    /// </summary>
    public float delayOnPeriod = 0f;
    /// <summary>
    /// 换行的延时
    /// </summary>
    public float delayOnNewLine = 0f;
    /// <summary>
    /// 忽略时间缩放
    /// </summary>
    public bool ignoreTimeScale = true;
    /// <summary>
    /// 如果设置为“true”，UILabel的尺寸将是完全淡入的内容尺寸
    /// </summary>
    public bool keepFullDimensions = false;
    /// <summary>
    /// 输出完成的回调
    /// </summary>
    public System.Action<TypeWriterEffect> onFinished = null;

    UILabel mLabel;
    BetterList<FadeChar> mText = new BetterList<FadeChar>();

    void Awake()
    {
        Init();
        if (mLabel && mText.size <= 0) TypeText(mLabel.processedText);
    }

    private void Init()
    {
        if (mLabel == null)
        {
            mLabel = GetComponent<UILabel>();
            mLabel.supportEncoding = true;
            mLabel.symbolStyle = NGUIText.SymbolStyle.None;
        }
    }

    public void TypeText(string text)
    {
        if (mLabel == null) Init();
        if (mLabel)
        {
            mText.Clear();
            float dt = 1f / Mathf.Max(1, charsPerSecond);
            float delay = 0;
            char[] chars = text.ToCharArray();
            for (int i = 0; i < chars.Length; i++)
            {
                int idx = i;
                if (NGUIText.ParseSymbol(text, ref idx))
                {
                    for (; i < idx; i++)
                    {
                        FadeChar sfc = new FadeChar();
                        sfc.c = chars[i];
                        sfc.lifeTime = 0f;
                        mText.Add(sfc);
                    }
                    if (i >= chars.Length) break;
                }
                
                char c = chars[i];
                if (c == '\n')
                {
                    delay += delayOnNewLine;
                }
                else if (c == '。' || c == '！' || c == '？' || c == '！' || c == '！' || c == '!' || c == '?' || c == ';' || c == '；')
                {
                    delay += delayOnPeriod * 2f;
                }
                else if (c == ',' || c == '.' || c == '，')
                {
                    delay += delayOnPeriod;
                }

                FadeChar fc = new FadeChar();
                fc.c = c;
                fc.lifeTime = fadeInTime + delay;
                mText.Add(fc);
                delay += dt;
            }
            mLabel.text = "";
            enabled = true;
        }
    }

    void Update()
    {
        StringBuilder sb = new StringBuilder();
        float deltaTime = ignoreTimeScale ? RealTime.deltaTime:Time.deltaTime;
        bool over = true;
        for (int i = 0; i < mText.size; i++)
        {
            FadeChar f = mText[i];
            if (f.lifeTime > 0)
            {
                over = false;
                f.lifeTime -= deltaTime;
                mText[i] = f;
                if (f.lifeTime < fadeInTime)
                {
                    sb.Append('[');
                    sb.Append(NGUIText.EncodeAlpha(1f - f.lifeTime / fadeInTime));
                    sb.Append(']');
                }
                else if (keepFullDimensions)
                {
                    sb.Append("[00]");
                }
                else
                {
                    continue;
                }
            }
            sb.Append(f.c);
        }
        mLabel.text = sb.ToString();
        if (over)
        {
            if (onFinished != null) onFinished(this);
            enabled = false;
        }
    }
}
