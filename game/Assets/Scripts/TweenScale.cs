using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class TweenScale : MonoBehaviour
{
    public Vector3 from = Vector3.zero;
    public Vector3 to = Vector3.one;
    public float tm = 1.0f;
    public Ease ease = Ease.Unset;
    public RectTransform rt;
    private void Start()
    {
        if (rt == null)
            return;
        rt.localScale = from;
        Tweener t = rt.DOScale(to, tm);
        t.SetEase(ease);
    }
}