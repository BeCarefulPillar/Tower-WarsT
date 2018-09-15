using UnityEngine;
using System.Collections;

public class TurnSprite : MonoBehaviour
{
    [System.NonSerialized] UISprite sprite;
    [System.NonSerialized] Transform mTrans;
    [System.NonSerialized] string toSpName;
    [System.NonSerialized] bool notTurn = true;
    [System.NonSerialized] float lifeTime = 0f;

    void Start()
    {
        if (!sprite) sprite = GetComponent<UISprite>();
        if (sprite)
        {
            notTurn = true;
            mTrans = sprite.cachedTransform;
        }
        else
        {
            Destroy(this);
        }
    }

    void Update()
    {
        if (lifeTime > 0)
        {
            lifeTime -= Time.deltaTime;
            if (mTrans && notTurn && mTrans.localEulerAngles.y > 90) return;
        }
        notTurn = false;
        sprite.spriteName = toSpName;
        Destroy(this);
    }

    void OnDestroy()
    {
        if (sprite)
        {
            sprite.spriteName = toSpName;
        }
    }

    public static TurnSprite Begin(UISprite sp, string toSpName, float lt = 0.3f)
    {
        if (sp)
        {
            TurnSprite ts = sp.GetComponent<TurnSprite>() ?? sp.cachedGameObject.AddComponent<TurnSprite>();
            ts.sprite = sp;
            ts.mTrans = sp.cachedTransform;
            ts.notTurn = true;
            ts.toSpName = toSpName;
            ts.lifeTime = lt;
            return ts;
        }
        return null;
    }
}
