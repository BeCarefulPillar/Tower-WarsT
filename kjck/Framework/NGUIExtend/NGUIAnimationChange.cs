using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(UIWidget))]
public class NGUIAnimationChange : MonoBehaviour
{
    private UIWidget target;

    void Start()
    {
        target = GetComponent<UIWidget>();
    }

    void Update()
    {
        target.MarkAsChanged();
    }
}
