using UnityEngine;

public abstract class UMonoBehaviour : MonoBehaviour
{
    protected GameObject mGameObject;
    protected Transform mTransform;

    public GameObject cachedGameObject
    {
        get
        {
            if (mGameObject == null)
                mGameObject = gameObject;
            return mGameObject;
        }
    }

    public Transform cachedTransform
    {
        get
        {
            if (mTransform == null)
                mTransform = transform;
            return mTransform;
        }
    }
}