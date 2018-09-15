using UnityEngine;

//[RequireComponent(typeof(UIDragObject))]
public class AdvisorTagDrag : MonoBehaviour
{
    [SerializeField] private UIPanel panel;
    [SerializeField] Vector3 offect = Vector3.zero;
    [SerializeField] Vector2 itemSize = Vector2.zero;
    [SerializeField] private Transform[] heros;

    UIDragObject drag;
    UIWidget widget;
    int mIndex = 0;

    public bool HasAdvisor { get; set; }

    private Vector3[] mPositions;
#if TOLUA
    [LuaInterface.NoToLua]
#endif
    public Vector3[] positions {
        get {
            if (mPositions != null) return mPositions;
            mPositions = new Vector3[heros.Length];
            for (int i = 0; i < heros.Length; i++) mPositions[i] = heros[i].localPosition;
            return mPositions;
        }
    }

    void Awake()
    {
        drag = GetComponent<UIDragObject>() ?? gameObject.AddComponent<UIDragObject>();
        widget = GetComponent<UIWidget>() ?? gameObject.AddComponent<UISprite>();
        drag.target = widget.cachedTransform;
        drag.onDragStatus = OnDragStatus;
    }

    void OnDragStatus(UIDragObject drag, int status)
    {
        switch (status)
        {
            case 0:
                UIPanel p = widget.GetComponent<UIPanel>() ?? widget.gameObject.AddComponent<UIPanel>();
                p.depth = panel.depth + 10;
                widget.ParentHasChanged();
                break;
            case 1:

                break;
            case 2:
                //case 3:
                int near = -1;
                Vector3 pos = drag.target.localPosition;
                Vector2 size = itemSize * 0.5f;
                for (int i = 0; i < positions.Length; i++)
                {
                    if (heros[i].tag == "HeroSelected")
                    {
                        Vector3 ipos = positions[i];
                        if (pos.x > ipos.x - size.x && pos.x < ipos.x + size.x && pos.y > ipos.y - size.y && pos.y < ipos.y + size.y)
                        {
                            near = i;
                            break;
                        }
                    }
                }

                if (near >= 0 && near != mIndex) mIndex = near;
                if (mIndex >= 0 && mIndex < positions.Length)
                {
                    SpringPosition.Begin(gameObject, positions[mIndex] + offect, 13f).onFinished = OnSpringPosEnd;
                }
                else
                {
                    OnSpringPosEnd();
                    gameObject.SetActive(false);
                    transform.localPosition = positions[0] + offect;
                }
                break;
        }
    }

    void OnSpringPosEnd()
    {
        UIPanel p = GetComponent<UIPanel>();
        if (p) Destroy(p);
        widget.ChangePanel(panel);
    }

    public void CheckBelong()
    {
        if (!HasAdvisor) mIndex = -1;
        else if (mIndex <= 0 || heros[mIndex].tag != "HeroSelected")
        {
            mIndex = -1;
            for (int i = 0; i < positions.Length; i++)
            {
                if (heros[i].tag == "HeroSelected")
                {
                    mIndex = i;
                    if (gameObject.activeSelf)
                    {
                        SpringPosition.Begin(gameObject, positions[i] + offect, 13f).onFinished = null;
                    }
                    else
                    {
                        transform.localPosition = positions[i] + offect;
                        gameObject.SetActive(true);
                    }
                    break;
                }
            }
        }
        if (mIndex < 0)
        {
            DisableSpring();
            gameObject.SetActive(false);
            transform.localPosition = positions[0] + offect;
        }
    }
#if TOLUA
    [LuaInterface.NoToLua]
#endif
    public void DisableSpring()
    {
        SpringPosition sp = GetComponent<SpringPosition>();
        if (sp) sp.enabled = false;
    }

    public int CurSelect
    {
        get
        {
            CheckBelong();
            return mIndex;
        }
        set
        {
            if (value >= 0 && value < heros.Length && HasAdvisor)
            {
                mIndex = value;
                if (gameObject.activeSelf)
                {
                    SpringPosition.Begin(gameObject, positions[mIndex] + offect, 13f).onFinished = null;
                }
                else
                {
                    transform.localPosition = positions[mIndex] + offect;
                    gameObject.SetActive(true);
                }
            }
        }
    }
}
