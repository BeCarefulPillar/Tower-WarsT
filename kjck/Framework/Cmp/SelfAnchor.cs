using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SelfAnchor : MonoBehaviour
{
    public const int SCREEN_WIDTH = 960;
    public const int SCREEN_HEIGHT = 540;

    [SerializeField]
    private UIWidget.Pivot mPivot = UIWidget.Pivot.Center;
    [SerializeField]
    private bool mLocalAnchor = false;
    [SerializeField]
    private bool mUpdateOnTransChanged = false;

    private static Vector3 _Scale = new Vector3(0.5f, 0.5f, 1f);
    private static Vector4 _Side = new Vector4(-SCREEN_WIDTH * 0.5f, SCREEN_HEIGHT * 0.5f, SCREEN_WIDTH * 0.5f, -SCREEN_HEIGHT * 0.5f);
    private static bool _CalcScale = true;

    [System.NonSerialized]
    private Transform mTrans;
    [System.NonSerialized]
    private bool mUpdateAnchors = true;

    public static Vector4 side { get { return _Side; } }

    public UIWidget.Pivot pivot { get { return mPivot; } set { if (mPivot == value) return; mPivot = value; mUpdateAnchors = true; } }

    private static void CalcScale()
    {
        _CalcScale = false;
        float m = (float)SCREEN_WIDTH / (float)SCREEN_HEIGHT;
        float s = (float)Screen.width / (float)Screen.height;
        if (Mathf.Approximately(m, s))
        {
            _Scale = new Vector3(0.5f, 0.5f, 1f);
            _Side = new Vector4(-SCREEN_WIDTH * 0.5f, SCREEN_HEIGHT * 0.5f, SCREEN_WIDTH * 0.5f, -SCREEN_HEIGHT * 0.5f);
        }
        else if (m > s)
        {
            _Scale = new Vector3(0.5f, 0.5f * m / s, 1f);
            _Side = new Vector4(-SCREEN_WIDTH * 0.5f, SCREEN_HEIGHT * _Scale.y, SCREEN_WIDTH * 0.5f, -SCREEN_HEIGHT * _Scale.y);
        }
        else
        {
            _Scale = new Vector3(0.5f * s / m, 0.5f, 1f);
            _Side = new Vector4(-SCREEN_WIDTH * _Scale.x, SCREEN_HEIGHT * 0.5f, SCREEN_WIDTH * _Scale.x, -SCREEN_HEIGHT * 0.5f);
        }
    }

    private void Awake()
    {
        mTrans = transform;
        UICamera.onScreenResize += OnScreenChange;
    }

    private void OnEnable() { UICamera.onScreenResize += OnScreenChange; }
    private void OnDisable() { UICamera.onScreenResize -= OnScreenChange; }

    private void Start() { mUpdateAnchors = true; }

    private void Update()
    {
        if (_CalcScale)
        {
            CalcScale();
        }
        if (mUpdateOnTransChanged && mTrans.hasChanged)
        {
            mTrans.hasChanged = false;
            mUpdateAnchors = true;
        }
        if (mUpdateAnchors)
        {
            CalcAnchor();
        }
    }

    private void OnScreenChange()
    {
        //StartCoroutine(IeScreenChange());
        mUpdateAnchors = true;
        _CalcScale = true;
    }

    //IEnumerator IeScreenChange()
    //{
    //    yield return null;
    //    CalcAnchor();
    //}
#if UNITY_EDITOR
    [ContextMenu("Anchor")]
#endif
    private void CalcAnchor()
    {
        mUpdateAnchors = false;
#if UNITY_EDITOR
        if (!mTrans) mTrans = transform;
#endif
        if (mLocalAnchor)
        {
            Vector3 pos = mTrans.localPosition;

            switch (mPivot)
            {
                case UIWidget.Pivot.BottomLeft: pos.x = -SCREEN_WIDTH; pos.y = -SCREEN_HEIGHT; break;
                case UIWidget.Pivot.BottomRight: pos.x = SCREEN_WIDTH; pos.y = -SCREEN_HEIGHT; break;
                case UIWidget.Pivot.TopRight: pos.x = SCREEN_WIDTH; pos.y = SCREEN_HEIGHT; break;
                case UIWidget.Pivot.TopLeft: pos.x = -SCREEN_WIDTH; pos.y = SCREEN_HEIGHT; break;
                case UIWidget.Pivot.Center: pos.x = 0f; pos.y = 0f; break;
                case UIWidget.Pivot.Left: pos.x = -SCREEN_WIDTH; pos.y = 0f; break;
                case UIWidget.Pivot.Bottom: pos.x = 0f; pos.y = -SCREEN_HEIGHT; break;
                case UIWidget.Pivot.Right: pos.x = SCREEN_WIDTH; pos.y = 0f; break;
                case UIWidget.Pivot.Top: pos.x = 0f; pos.y = SCREEN_HEIGHT; break;
                default: break;
            }

            pos.Scale(_Scale);

            mTrans.localPosition = pos;
        }
        else
        {
            Vector3 pos = mTrans.position;

            switch (mPivot)
            {
                case UIWidget.Pivot.BottomLeft: pos.x = 0f; pos.y = 0f; break;
                case UIWidget.Pivot.BottomRight: pos.x = 1f; pos.y = 0f; break;
                case UIWidget.Pivot.TopRight: pos.x = 1f; pos.y = 1f; break;
                case UIWidget.Pivot.TopLeft: pos.x = 0f; pos.y = 1f; break;
                case UIWidget.Pivot.Center: pos.x = 0.5f; pos.y = 0.5f; break;
                case UIWidget.Pivot.Left: pos.x = 0f; pos.y = 0.5f; break;
                case UIWidget.Pivot.Bottom: pos.x = 0.5f; pos.y = 0f; break;
                case UIWidget.Pivot.Right: pos.x = 1f; pos.y = 0.5f; break;
                case UIWidget.Pivot.Top: pos.x = 0.5f; pos.y = 1f; break;
                default: break;
            }
            if (UICamera.currentCamera)
            {
                pos = UICamera.currentCamera.ViewportToWorldPoint(pos);
            }
            else if (Camera.main)
            {
                pos = Camera.main.ViewportToWorldPoint(pos);
            }
            else
            {
                return;
            }
            mTrans.position = pos;
        }
    }
}
