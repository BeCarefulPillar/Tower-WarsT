using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WinBattle : MonoBehaviour
{
    public int glen = 1;//格子边长
    public int xsize = 10;//格子x轴个数
    public int ysize = 5;//格子y轴个数
    public GameObject map;

    [ContextMenu("生成地图")]
    private void Gen()
    {
        if(map)
        {
            for(int i=0;i<ysize;++i)
            {
                for(int j=0;j<xsize;++j)
                {
                    GameObject go = new GameObject("gird_" + (i * glen+ j));
                    BoxCollider2D coll = go.AddComponent<BoxCollider2D>();
                    coll.size = new Vector2(glen, glen);
                    coll.isTrigger = true;
                    go.transform.position = new Vector3(j * glen, i * glen, 0);
                    go.transform.SetParent(map.transform);
                }
            }
        }
    }
    [ContextMenu("删除地图")]
    private void Des()
    {
        if(map)
        {
            Transform[] ts = map.GetComponentsInChildren<Transform>(true);
            Transform m = map.transform;
            for (int i = 0; i < ts.Length; ++i)
                if (ts[i] != null && ts[i] != m)
                    DestroyImmediate(ts[i].gameObject);
        }
    }
    private void Start()
    {
    }
    private void Update()
    {
    }
}