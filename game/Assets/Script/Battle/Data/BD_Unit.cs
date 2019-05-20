using System;
using UnityEngine;

public abstract class BD_Unit
{
    private BD_Map mMap;
    private static int _gid = 1;
    private int mID;
    private int mBirthFrame;
    private int mDeathFrame;
    private Vector3 mPos;
    private BU_Unit mBody;

    public BD_Unit(BD_Map map)
    {
        if (map == null)
            throw new Exception("map is null");
        mMap = map;
        mID = _gid++;
        //mBirthFrame = 0;
        //mDeathFrame = 0;
        //mMap.Add(this);
    }

    public virtual void Update()
    {
    }

    public BU_Unit body { get { return mBody; } set { if (value != mBody) mBody = value; } }
}