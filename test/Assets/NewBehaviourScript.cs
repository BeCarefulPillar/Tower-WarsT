using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class NewBehaviourScript : MonoBehaviour
{
    public RawImage ri;
    public Asset asset;

    void Start()
    {
        asset = new Asset("dialog");
        asset.Load();
        asset.AddRef(gameObject);
        ri.texture = asset.prefab.GetComponent<UIAtlas>().texture;
        StartCoroutine(Fun());
    }

    private IEnumerator Fun()
    {
        yield return new WaitForSeconds(3);

        Debug.Log(asset.NeedDispose);
        asset.Dispose();
    }

    void Update()
    {
    }
}