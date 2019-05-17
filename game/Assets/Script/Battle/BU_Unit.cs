using UnityEngine;

/// <summary>
/// 战场显示单位
/// </summary>
public class BU_Unit : MonoBehaviour
{
    private BU_Map mMap;
    private BD_Unit mDat;

    private Transform mTrans;
    private GameObject mGo;

    public void Init(BU_Map map, BD_Unit dat)
    {
        mMap = map;
        mDat = dat;
        mDat.body = this;
    }

    public void Dispose()
    {
    }

    public Transform cachedTransform { get { if (mTrans == null) mTrans = transform; return mTrans; } }
    public GameObject cachedGameObject { get { if (mGo == null) mGo = gameObject; return mGo; } }
}