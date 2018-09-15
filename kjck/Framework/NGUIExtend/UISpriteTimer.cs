using UnityEngine;

public class UISpriteTimer : MonoBehaviour
{
    [SerializeField] UISprite target;
    [SerializeField] float time = 1f;

    private UISprite timer;
    private UIButton enabelBtn;
    private string btnDisabledSprite;
    private Color btnDisabledColor;
    private float beginTime = 0f;
    private float intValue = 1f;

    void Start()
    {
        if (!target) target = GetComponent<UISprite>();
        if (target && target.GetAtlasSprite() != null)
        {
            beginTime = Time.realtimeSinceStartup;
            timer = target.cachedGameObject.AddWidget<UISprite>("sprite_timer");
            timer.atlas = target.atlas;
            timer.depth = target.depth;
            //timer.secondDepth = target.secondDepth + 1;
            timer.width = target.width;
            timer.height = target.height;
            timer.pivot = target.pivot;
            timer.cachedTransform.localPosition = Vector3.zero;

            enabelBtn = target.GetComponent<UIButton>();
            if (enabelBtn && enabelBtn.isEnabled)
            {
                btnDisabledSprite = enabelBtn.disabledSprite;
                btnDisabledColor = enabelBtn.disabledColor;
                if (string.IsNullOrEmpty(btnDisabledSprite))
                {
                    timer.spriteName = target.spriteName;
                }
                else
                {
                    timer.spriteName = btnDisabledSprite;
                    enabelBtn.disabledSprite = enabelBtn.normalSprite;
                }
                if (enabelBtn.defaultColor != btnDisabledColor)
                {
                    timer.color = btnDisabledColor;
                    enabelBtn.disabledColor = enabelBtn.defaultColor;
                }
                else
                {
                    timer.color = btnDisabledColor * 0.5f;
                    timer.alpha = btnDisabledColor.a;
                }
                enabelBtn.isEnabled = false;
            }
            else
            {
                enabelBtn = null;
                timer.spriteName = target.spriteName;
                timer.color = target.color * 0.5f;
                timer.alpha = target.alpha;
            }

            if (target.type == UIBasicSprite.Type.Simple || target.type == UIBasicSprite.Type.Filled)
            {
                intValue = target.type == UIBasicSprite.Type.Filled ? target.fillAmount : 1f;
                timer.type = UIBasicSprite.Type.Filled;
                timer.fillDirection = UISprite.FillDirection.Radial360;
                timer.fillAmount = intValue;
            }
            else
            {
                intValue = timer.alpha;
                timer.type = target.type;
            }
        }
        else
        {
            Destroy(this);
        }
    }

    void Update()
    {
        if (timer)
        {
            float dt = Time.realtimeSinceStartup - beginTime;
            if (dt < time)
            {
                if(timer.type == UIBasicSprite.Type.Filled)
                {
                    timer.fillAmount = intValue * (time - dt) / time;
                }
                else
                {
                    timer.alpha = intValue * (1f - Mathf.Pow(dt / time, 5f));
                }
            }
            else
            {
                End();
            }
        }
        else
        {
            Destroy(this);
        }
    }

    void End()
    {
        if (enabelBtn)
        {
            enabelBtn.disabledSprite = btnDisabledSprite;
            enabelBtn.disabledColor = btnDisabledColor;
            enabelBtn.isEnabled = true;
            
        }
        Destroy(timer.cachedGameObject);
        Destroy(this);
    }

    public static void Begin(UISprite sp, float time, float passTime = 0f)
    {
        if (sp && time > passTime)
        {
            UISpriteTimer spt = sp.GetComponent<UISpriteTimer>() ?? sp.cachedGameObject.AddComponent<UISpriteTimer>();
            spt.beginTime = Time.realtimeSinceStartup - passTime;
            spt.target = sp;
            spt.time = time;
        }
    }

    public static void End(Component cmp)
    {
        if (cmp)
        {
            UISpriteTimer spt = cmp.GetComponent<UISpriteTimer>();
            if (spt) spt.End();
        }
    }
}
