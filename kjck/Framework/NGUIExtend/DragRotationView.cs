using UnityEngine;
using System.Collections.Generic;

[ExecuteInEditMode]
[AddComponentMenu("Game/Other/Drag Rotation View")]
public class DragRotationView : MonoBehaviour
{
    public enum DragEffect
    {
        None,
        Align,
        Momentum,
    }
    public enum ViewAxis
    {
        X,
        Y,
        Z,
    }

    //public MouseEventForward dragMask;

    [SerializeField] float angle = 0;
    [Range(0f,1f)][SerializeField] public float dragScale = 1f;
    [SerializeField] float radius = 300;
    [SerializeField] float focalLength = 500;
    [SerializeField] ViewAxis axis = ViewAxis.Y;
    [SerializeField] DragEffect dragEffect = DragEffect.Momentum;
    [SerializeField] public float posOffset = 0;
    [Range(1,int.MaxValue)][SerializeField] public int widgetDepthOffset = 1;
    [SerializeField] float momentumAmount = 35f;
    [SerializeField] int childCount = 0;
    [SerializeField] List<Transform> mChilds;

    public System.Action onStopMove = null;

    Transform pressTag = null;
    Transform mTrans;
    float mMomentum = 0;
    //bool mPressed = false;
    bool isDrag = false;
    bool isPressed = false;
    bool moveFlag = false;

    void Start()
    {
        //if (dragMask != null)
        //{
        //    dragMask.SetPress(OnPress);
        //    dragMask.SetDrag(OnDrag);
        //}
        //CheckChilds();
    }

    /// <summary>
    /// ��������Ӽ������¼����ʼλ�ò���ӵ��б�
    /// </summary>
    public void CheckChilds()
    {
        childCount = Trans.childCount;
        if (childCount > 0)
        {
            List<Transform> tempChilds = new List<Transform>();
            for (int i = 0; i < childCount; i++) tempChilds.Add(mTrans.GetChild(i));
            tempChilds.Sort((a, b) => { return string.Compare(a.name, b.name); });
            float angle = Mathf.PI * 2 / childCount;
            for (int i = 0; i < childCount; i++)
            {
                Transform t = tempChilds[i];
                if(axis==ViewAxis.X)
                    t.localPosition = new Vector3(0, Mathf.Sin(angle * i) * radius, -Mathf.Cos(angle * i) * radius);
                else if (axis == ViewAxis.Y)
                    t.localPosition = new Vector3(Mathf.Sin(angle * i) * radius, 0, -Mathf.Cos(angle * i) * radius);
                else
                    t.localPosition = new Vector3(Mathf.Sin(angle * i) * radius, Mathf.Cos(angle * i) * radius, 0);
                DragRotationContents drc = (t.GetComponent<DragRotationContents>() ?? t.gameObject.AddComponent<DragRotationContents>());
                drc.dragView = this;
            }
            mChilds = tempChilds;
            UpdateAngle();
        }
    }

    //����ŷ���ǣ��Ѿ��Ӽ���ͬ�����
    void UpdateAngle()
    {
        //����ŷ����
        if (axis == ViewAxis.X)
            Trans.localRotation = Quaternion.Euler(new Vector3(angle, 0, 0));
        else if (axis == ViewAxis.Y)
            Trans.localRotation = Quaternion.Euler(new Vector3(0, -angle, 0));
        else
            Trans.localRotation = Quaternion.Euler(new Vector3(0, 0, -angle));

        //�����Ӽ�
        if (mChilds == null) return;
        for (int i = 0; i < childCount; i++)
        {
            Transform child = mChilds[i];
            child.localEulerAngles = -Trans.localEulerAngles;
            child.localScale = Vector3.one * GetScale(mChilds[i]);
            float a = axis == ViewAxis.Z ? 1 : 1 - Mathf.Abs(RoundAngle(GetChildAngle(i) + Angle) / 360);
            if (posOffset != 0)
            {
                Vector3 pos = child.localPosition;
                if (axis == ViewAxis.Y) pos.y = posOffset * (a - 0.75f) * 2;
                else if (axis == ViewAxis.X) pos.x = posOffset * (a - 0.75f) * 2;
                child.localPosition = pos;
            }
            Color cor = new Color(a, a, a, 1);
            UIWidget[] ws = mChilds[i].GetComponentsInChildren<UIWidget>(true);
            if (ws != null)
            {
                foreach (UIWidget w in ws)
                {
                    BindWidgetColor bwc = w.GetComponent<BindWidgetColor>();
                    if (!bwc) w.color = cor;//û�а���ɫ�Ĳ�������ɫ
                }
            }
        }
        mChilds.Sort((x, y) => { if (x.position.z <= y.position.z)return 1; return -1; });
        for (int i = 0; i < childCount; i++)
        {
            UIPanel panel = mChilds[i].GetComponent<UIPanel>();
            if (panel != null)
            {
                panel.depth = panel.depth % widgetDepthOffset + i * widgetDepthOffset;
            }
            else
            {
                UIWidget[] ws = mChilds[i].GetComponentsInChildren<UIWidget>(true);
                if (ws != null)
                {
                    foreach (UIWidget w in ws)
                    {
                        BindWidgetDepth bwd = w.GetComponent<BindWidgetDepth>();
                        if(!bwd) w.depth = w.depth % widgetDepthOffset + i * widgetDepthOffset;
                    }
                }
            }
        }
    }

    //�Ʊ�
    void LateUpdate()
    {
        if (Mathf.Abs(mMomentum) > 0.0001f)
        {
            float offset = SpringDampen(Mathf.Min(Time.deltaTime, 0.04f));
            if (pressTag == null && dragEffect != DragEffect.None) Angle += offset;
            if (moveFlag) return;
            moveFlag = true;
        }
        else
        {
            mMomentum = 0;
            if (moveFlag)
            {
                moveFlag = false;
                if (pressTag == null && onStopMove != null) onStopMove();
            }
        }
    }

    //ĳ�Ӽ�������/�ͷ�ʱ
    public void OnPress(Transform child, bool pressed)
    {
        isPressed = pressed;
        if (pressed)
        {
            pressTag = child;
            mMomentum = 0;
            isDrag = false;
        }
        else
        {
            pressTag = null;
            if (dragEffect == DragEffect.Align)
            {
                float a = Mathf.Abs(mMomentum) > 0.0001f ? (mMomentum - 0.0000991f) / 0.15f : 0;
                mMomentum = 0.15f * (Mathf.Round((Angle + a) * mChilds.Count / 360f) * 360f / mChilds.Count - Angle) + 0.0000991f;
            }
        }
    }

    //ĳ�Ӽ������ʱ
    //void OnClickChild(MouseEventForward mef)
    //{
    //    if (isDrag) return;
    //    int index = (int)mef.Param;
    //    CurIndex = index;
    //}

    //ĳ�Ӽ����϶�ʱ
    public void Drag(Vector2 delta)
    {
        isDrag = true;
        delta = delta * dragScale;
        if (axis == ViewAxis.X)
        {
            Angle += delta.y;
            mMomentum = Mathf.Lerp(mMomentum, mMomentum + delta.y * (0.01f * momentumAmount), 0.67f);
        }
        else if (axis == ViewAxis.Y)
        {
            Angle += delta.x;
            mMomentum = Mathf.Lerp(mMomentum, mMomentum + delta.x * (0.01f * momentumAmount), 0.67f);
        }
        else
        {
            float a = DegToRad(RoundAngle(Angle + GetChildAngle(pressTag)));
            Vector2 v1 = new Vector2(Mathf.Sin(a), Mathf.Cos(a));
            float offset = (Vector2.Dot(new Vector2(Mathf.Cos(a), -Mathf.Sin(a)), delta) < 0 ? -1 : 1) * Mathf.Sin(DegToRad(Vector2.Angle(v1, delta))) * delta.magnitude;
            Angle += offset;
            mMomentum = Mathf.Lerp(mMomentum, mMomentum + offset * (0.01f * momentumAmount), 0.67f);
        }
    }

    //�Ƶ�˥��ת��Ϊŷ���ǵı���
    float SpringDampen(float deltaTime)
    {
        // Dampening factor applied each millisecond
        if (deltaTime > 1f) deltaTime = 1f;
        float dampeningFactor = 0.991f;
        int ms = Mathf.RoundToInt(deltaTime * 1000f);
        float offset = 0;

        // Apply the offset for each millisecond
        for (int i = 0; i < ms; ++i)
        {
            // Mimic 60 FPS the editor runs at
            offset += mMomentum * 0.06f;
            mMomentum *= dampeningFactor;
        }
        return offset;
    }

    //��ȡ�Ӽ���Z����
    float GetScale(Transform t)
    {
        float z = (t.position - Trans.parent.position).z / Trans.parent.lossyScale.z;
        if (z <= -focalLength) return float.MaxValue;
        return focalLength / (focalLength + z);
    }

    //��ȡĳ�Ӽ��ĳ�ʼ�Ƕ�
    float GetChildAngle(int index) { return GetChildAngle(mChilds[index]); }
    float GetChildAngle(Transform child)
    {
        Vector3 pos = child.localPosition;
        if (axis == ViewAxis.X)
            return (pos.y < 0 ? -1 : 1) * RadToDeg(Mathf.Acos(-pos.z / radius));
        else if (axis == ViewAxis.Y)
            return (pos.x < 0 ? -1 : 1) * RadToDeg(Mathf.Acos(-pos.z / radius));
        else
            return (pos.y < 0 ? -1 : 1) * RadToDeg(Mathf.Acos(pos.y / radius));
    }

    //���ƽǶ���-180~180֮��
    float RoundAngle(float angle)
    {
        angle = angle % 360;
        if (angle > 180) angle -= 360;
        if (angle <= -180) angle += 360;
        return angle;
    }
    //���ƽǶ���-360~360֮��
    float RoundAngle360(float angle)
    {
        return angle < 0 ? (360 + angle % 360) : angle % 360;
    }
    /// <summary>
    /// �����Ӽ�������
    /// </summary>
    /// <param name="child"></param>
    public void AlignChild(Transform child)
    {
        if (child != null && mChilds.Contains(child))
        {
            mMomentum = -0.15f * RoundAngle(GetChildAngle(child) + Angle) + 0.0000991f;
        }
    }
    /// <summary>
    /// ��ȡ/������ǰ�˵��Ӽ�����
    /// </summary>
    public int CurIndex
    {
        get
        {
            return -Mathf.RoundToInt(Angle * mChilds.Count / 360f - mChilds.Count) % mChilds.Count;
        }
        set
        {
            mMomentum = -0.15f * RoundAngle(GetChildAngle(value) + Angle) + 0.0000991f;
        }
    }
    /// <summary>
    /// ��ȡ/������תŷ����
    /// </summary>
    public float Angle
    {
        get { return angle; }
        set
        {
            value = RoundAngle(value);
            if (angle != value)
            {
                angle = value;
                UpdateAngle();
            }
        }
    }
    /// <summary>
    /// ��ȡ/���ð뾶
    /// </summary>
    public float Radius
    {
        get { return radius; }
        set
        {
            if (radius != value)
            {
                radius = value;
                CheckChilds();
            }
        }
    }
    /// <summary>
    /// ��ȡ/���ý���
    /// </summary>
    public float FocalLength
    {
        get { return focalLength; }
        set
        {
            if (focalLength != value)
            {
                focalLength = value;
                CheckChilds();
            }
        }
    }
    /// <summary>
    /// ��ȡ/������ת��
    /// </summary>
    public ViewAxis Axis
    {
        get { return axis; }
        set
        {
            if (axis != value)
            {
                axis = value;
                CheckChilds();
            }
        }
    }
    //�Ƕ�-���ȵ�ת��
    float RadToDeg(float angle) { return angle * 180 / Mathf.PI; }
    float DegToRad(float angle) { return angle * Mathf.PI / 180; }
    /// <summary>
    /// ��ȡ/�����϶���Ч��
    /// </summary>
    public DragEffect Effect{ get { return dragEffect; } set { dragEffect = value; } }
    /// <summary>
    /// ��ȡ/�����ƵĶ���
    /// </summary>
    public float MomentumAmount { get { return momentumAmount; } set { momentumAmount = value; } }
    public bool IsDrag { get { return isDrag; } }
    public bool IsPressed { get { return isPressed; } }
    public bool isRotating { get { return mMomentum > 0f; } }
    /// <summary>
    /// ��ȡ����ı任
    /// </summary>
    public Transform Trans { get { if (mTrans == null)mTrans = transform; return mTrans; } }
}
