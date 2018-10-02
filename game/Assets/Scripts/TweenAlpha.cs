using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class TweenAlpha : MonoBehaviour
{
    public float from = 0.0f;
    public float to = 1.0f;
    public float tm = 1.0f;
    public Ease ease = Ease.Unset;
    public CanvasGroup cg;
    private void Start()
    {
        if (cg == null)
            return;
        cg.alpha = from;
        Tweener t = cg.DOFade(to, tm);
        t.SetEase(ease);
    }
}