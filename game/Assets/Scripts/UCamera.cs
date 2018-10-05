using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UCamera : MonoBehaviour
{
    public RectTransform canvas_rect;
    public CanvasScaler canvas_scaler;
    public RectTransform uicam_rect;
    public Camera uicam;

    [ContextMenu("Init")]
    private void Awake()
    {
        Vector2 s = new Vector2(uicam.pixelWidth, uicam.pixelHeight);
        uicam.orthographicSize = uicam.pixelHeight / 200;
        canvas_scaler.referenceResolution = s;
        uicam_rect.sizeDelta = s;
        canvas_rect.sizeDelta = s;
    }
}