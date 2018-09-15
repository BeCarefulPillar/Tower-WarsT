using UnityEngine;
using System;
using System.Collections.Generic;
#if TOLUA
using LuaInterface;
#endif

public class MessageBox : CoreModule
{
    public delegate void Feedback(Input input);

    public struct Input
    {
        public string button;
        public int buttonIndex;
        public bool[] toggles;
        public string[] inputs;
    }
    private struct Message
    {
        public string message;
        public string[] button;
        public string[] toggles;
        public string[] inputs;

        public Feedback feedback;
#if TOLUA
        public LuaFunction luaFunc;
#endif
        public bool manualExit;

        public bool Equal(Message msg)
        {
            return message == msg.message && manualExit == msg.manualExit && feedback== msg.feedback &&
#if TOLUA
                luaFunc == msg.luaFunc &&
#endif
                button.MatchElement(msg.button) && toggles.MatchElement(msg.toggles) && inputs.MatchElement(msg.inputs);
        }
    }

    /// <summary>
    /// 单例
    /// </summary>
    private static MessageBox _Instance = null;
    /// <summary>
    /// 初始化
    /// </summary>
    public static void Init() { Instance(ref _Instance); if (_Instance) _Instance.InitCheck(); }

    /// <summary>
    /// 消息盒子是否在显示
    /// </summary>
    public static bool IsShow { get { return _Instance && _Instance.mIsShow; } }

    public static void Wait(string message) { if (_Instance)_Instance.ShowBox(message, null, null, null); }

    public static void ShowConfirm(string message, Feedback feedback) { if (_Instance) _Instance.ShowBox(message, L.Sure + "," + L.Cancel, null, null, feedback); }
    public static void Show(string message, Feedback feedback = null) { if (_Instance) _Instance.ShowBox(message, L.Sure, null, null, feedback); }
    public static void Show(string message, string button, Feedback feedback = null, bool manualExit = false) { if (_Instance)_Instance.ShowBox(message, button, null, null, feedback, manualExit); }
    public static void Show(string message, string button, string checkbox, Feedback feedback = null, bool manualExit = false) { if (_Instance)_Instance.ShowBox(message, button, checkbox, null, feedback, manualExit); }
    public static void Show(string message, string button, string checkbox, string input, Feedback feedback = null, bool manualExit = false) { if (_Instance)_Instance.ShowBox(message, button, checkbox, input, feedback, manualExit); }
    public static void Exit() { if (_Instance != null)_Instance.ExitBox(); }

    public static void SetInputValue(int index, string val)
    {
        if (_Instance && _Instance.mUnputs.IndexAvailable(index))
        {
            _Instance.mUnputs[index].value = val;
        }
    }
    public static bool InputHasInvisibleChar(int index)
    {
        if (_Instance && _Instance.mUnputs.IndexAvailable(index))
        {
            UIInput ipt = _Instance.mUnputs[index];
            return ipt.value.HasInvisibleChar(ipt.label.trueTypeFont, ipt.label.fontSize);
        }
        return false;
    }

    [SerializeField] private GameObject mAnchor;
    [SerializeField] private UIWidget mBackground;
    [SerializeField] private UILabel mMsgLabel;
    [SerializeField] private UITweenerAdapter mTween;
    [SerializeField] private GameObject[] mPrefabBtn;
    [SerializeField] private GameObject[] mPrefabToggle;
    [SerializeField] private GameObject[] mPrefabInput;
    //[SerializeField] private int mMaxWidth = 400;              //控件最大宽度
    [SerializeField] private int mControlSpaceV = 30;         //控件垂直间距
    [SerializeField] private Vector4 mFrameSpace = new Vector4(20f, 20f, 20f, 20f);
    [SerializeField] private Vector2 mBtnSpace = new Vector2(20f, 20f);
    [SerializeField] private Vector2 mToggleSpace = new Vector2(30f, 20f);
    // 左 下 右 上
    [SerializeField] private Vector2 mInputSpace = new Vector2(30f, 30f);

    private GameObject[] mButtons;
    private UIToggle[] mToggles;
    private UIInput[] mUnputs;

    private bool mIsShow = false;
    private Message mMessage;
    private Queue<Message> mQueue = new Queue<Message>();

    private void InitCheck()
    {
        if (mPrefabBtn != null && mPrefabBtn.Length > 0 && mPrefabBtn[0])
        {
            if (!mIsShow) gameObject.SetActive(false);

            if (mBackground)
            {
                mBackground.pivot = UIWidget.Pivot.Top;
            }
            if (mMsgLabel)
            {
                mMsgLabel.pivot = UIWidget.Pivot.Top;
                mMsgLabel.cachedTransform.localPosition = Vector3.zero;
            }

            if (mTween) mTween.onFinished = OnDisappear;
        }
        else
        {
            Debug.LogError("MessageBox need buttons prefab");
        }
    }

    private void Start()
    {
        if (_Instance == null)
        {
            _Instance = this;
            MoveToGame(_Instance.gameObject);
        }
        else if (_Instance != this)
        {
            this.DestructIfOnly();
            return;
        }
    }

#if TOLUA
    /// <summary>
    /// 显示消息提示框
    /// </summary>
    /// <param name="content">消息内容</param>
    /// <param name="button">按钮 用','分隔</param>
    /// <param name="checkbox">选项 用','分隔</param>
    /// <param name="input">输入 用','分隔</param>
    /// <param name="callback">消息框回调</param>
    /// <param name="verify">消息框需要回调函数验证才能退出</param>
    public static void ShowBox(string content, string button, string checkbox, string input, LuaFunction feedback, bool manualExit = false)
    {
        if (!_Instance) return;
        Message message = new Message();
        message.message = content;
        message.button = string.IsNullOrEmpty(button) ? null : button.Split(',');
        message.toggles = string.IsNullOrEmpty(checkbox) ? null : checkbox.Split(',');
        message.inputs = string.IsNullOrEmpty(input) ? null : input.Split(',');
        message.feedback = null;
        message.luaFunc = feedback;
        message.manualExit = manualExit;
        _Instance.ShowBox(message);
    }
#endif
    /// <summary>
    /// 显示消息提示框
    /// </summary>
    /// <param name="content">消息内容</param>
    /// <param name="button">按钮 用','分隔</param>
    /// <param name="checkbox">选项 用','分隔</param>
    /// <param name="input">输入 用','分隔</param>
    /// <param name="feedback">消息框回调</param>
    /// <param name="manualExit">消息框需要回调函数验证才能退出</param>
    private void ShowBox(string content, string button, string checkbox, string input, Feedback feedback = null, bool manualExit = false)
    {
        Message message = new Message();
        message.message = content;
        message.button = string.IsNullOrEmpty(button) ? null : button.Split(',');
        message.toggles = string.IsNullOrEmpty(checkbox) ? null : checkbox.Split(',');
        message.inputs = string.IsNullOrEmpty(input) ? null : input.Split(',');
        message.feedback = feedback;
        message.manualExit = manualExit;

        ShowBox(message);
    }
    /// <summary>
    /// 显示消息盒子，队列模式
    /// </summary>
    /// <param name="message">消息</param>
    private void ShowBox(Message message)
    {
        if (mIsShow)
        {
            if (this.mMessage.Equal(message)) return;
            foreach (Message msg in mQueue) if (message.Equal(msg)) return;
            mQueue.Enqueue(message);
            return;
        }

        ClearControl();
        gameObject.SetActive(true);

        mMessage = message;
        mIsShow = true;

        int btnNum = message.button == null ? 0 : message.button.Length;//按钮个数
        int tglNum = message.toggles == null ? 0 : message.toggles.Length;//选项个数
        int iptNum = message.inputs == null ? 0 : message.inputs.Length;//输入个数

        mMsgLabel.text = message.message;//赋予消息文本
        float maxWidth = mMsgLabel.width;
        float maxHeight = mMsgLabel.height;
        
        if (btnNum > 0)
        {
            int lineQty = btnNum;
            int elmWidth = 0;
            int elmHeight = 0;
            List<Bounds> bounds = new List<Bounds>(Mathf.Max(btnNum, tglNum, iptNum));
            Vector3 pos = new Vector3(0f, -mMsgLabel.height - mControlSpaceV, 0f);
            Vector3 space;

            if (iptNum > 0)
            {
                lineQty = iptNum;
                elmWidth = 0;
                elmHeight = 0;
                mUnputs = new UIInput[iptNum];
                for (int i = 0; i < iptNum; i++)
                {
                    mUnputs[i] = BuildInput(i, message.inputs[i]);
                    bounds.Add(NGUIMath.CalculateRelativeWidgetBounds(mUnputs[i].transform));
                    elmWidth = Mathf.CeilToInt(Mathf.Max(elmWidth, bounds[i].size.x));
                    elmHeight = Mathf.CeilToInt(Mathf.Max(elmHeight, bounds[i].size.y));
                }
                if (elmWidth * iptNum + mInputSpace.x * (iptNum - 1) > mMsgLabel.overflowWidth)
                {
                    lineQty = Mathf.Clamp(Mathf.FloorToInt((mMsgLabel.overflowWidth + mInputSpace.x) / (elmWidth + mInputSpace.x)), 1, iptNum);
                }
                space = new Vector3(elmWidth + mInputSpace.x, -elmHeight - mInputSpace.y);
                pos.x = elmWidth * lineQty + mInputSpace.x * (lineQty - 1);
                maxWidth = Mathf.Max(maxWidth, Mathf.CeilToInt(pos.x));
                pos.x = -pos.x * 0.5f;
                for (int i = 0; i < iptNum; i++)
                {
                    mUnputs[i].transform.localPosition = pos - new Vector3(bounds[i].max.x - space.x * (i % lineQty) - elmWidth, bounds[i].center.y - space.y * (i / lineQty) + elmHeight * 0.5f, bounds[i].center.z);
                }

                lineQty = iptNum % lineQty == 0 ? iptNum / lineQty : ((iptNum / lineQty) + 1);
                pos.y -= lineQty * elmHeight + mInputSpace.y * (lineQty - 1) + mControlSpaceV;
            }

            if (tglNum > 0)
            {
                lineQty = tglNum;
                elmWidth = 0;
                elmHeight = 0;
                bounds.Clear();
                mToggles = new UIToggle[tglNum];
                for (int i = 0; i < tglNum; i++)
                {
                    mToggles[i] = BuildToggle(i, message.toggles[i]);
                    Bounds b = NGUIMath.CalculateRelativeWidgetBounds(mToggles[i].transform);
                    bounds.Add(b);
                    elmWidth = Mathf.CeilToInt(Mathf.Max(elmWidth, bounds[i].size.x));
                    elmHeight = Mathf.CeilToInt(Mathf.Max(elmHeight, bounds[i].size.y));

                    BoxCollider box = mToggles[i].GetComponent<BoxCollider>() ?? mToggles[i].gameObject.AddComponent<BoxCollider>();
                    box.center = b.center;
                    box.size = new Vector3(b.size.x, b.size.y, 0f);
                }
                if (elmWidth * tglNum + mToggleSpace.x * (tglNum - 1) > mMsgLabel.overflowWidth)
                {
                    lineQty = Mathf.Clamp(Mathf.FloorToInt((mMsgLabel.overflowWidth + mToggleSpace.x) / (elmWidth + mToggleSpace.x)), 1, tglNum);
                }
                space = new Vector3(elmWidth + mToggleSpace.x, -elmHeight - mToggleSpace.y);
                pos.x = elmWidth * lineQty + mToggleSpace.x * (lineQty - 1);
                maxWidth = Mathf.Max(maxWidth, Mathf.CeilToInt(pos.x));
                pos.x = -pos.x * 0.5f;
                for (int i = 0; i < tglNum; i++)
                {
                    mToggles[i].transform.localPosition = pos - new Vector3(bounds[i].min.x - space.x * (i % lineQty), bounds[i].center.y - space.y * (i / lineQty) + elmHeight * 0.5f, bounds[i].center.z);
                }

                maxWidth = Mathf.Max(maxWidth, lineQty * elmWidth);
                lineQty = tglNum % lineQty == 0 ? tglNum / lineQty : ((tglNum / lineQty) + 1);
                pos.y -= lineQty * elmHeight + mToggleSpace.y * (lineQty - 1) + mControlSpaceV;
            }

            lineQty = btnNum;
            elmWidth = 0;
            elmHeight = 0;
            bounds.Clear();
            mButtons = new GameObject[btnNum];
            for (int i = 0; i < btnNum; i++)
            {
                mButtons[i] = BuildButton(i, message.button[i]);
                bounds.Add(NGUIMath.CalculateRelativeWidgetBounds(mButtons[i].transform));
                elmWidth = Mathf.CeilToInt(Mathf.Max(elmWidth, bounds[i].size.x));
                elmHeight = Mathf.CeilToInt(Mathf.Max(elmHeight, bounds[i].size.y));
            }
            if (elmWidth * btnNum + mBtnSpace.x * (btnNum - 1) > mMsgLabel.overflowWidth)
            {
                lineQty = Mathf.Clamp(Mathf.FloorToInt((mMsgLabel.overflowWidth + mBtnSpace.x) / (elmWidth + mBtnSpace.x)), 1, btnNum);
            }

            Vector3 center = new Vector3(elmWidth * 0.5f, -elmHeight * 0.5f, 0f);
            space = new Vector3(elmWidth + mBtnSpace.x, -elmHeight - mBtnSpace.y);
            pos.x = elmWidth * lineQty + mBtnSpace.x * (lineQty - 1);
            maxWidth = Mathf.Max(maxWidth, Mathf.CeilToInt(pos.x));
            pos.x = -pos.x * 0.5f;
            for (int i = 0; i < btnNum; i++)
            {
                mButtons[i].transform.localPosition = pos + center + new Vector3(space.x * (i % lineQty), space.y * (i / lineQty), 0f) - bounds[i].center;
            }

            maxWidth = Mathf.Max(maxWidth, lineQty * elmWidth);
            lineQty = btnNum % lineQty == 0 ? btnNum / lineQty : ((btnNum / lineQty) + 1);
            // pos.y -= lineQty * elmHeight + btnSpace.y * (lineQty - 1) + CONTROL_SPACE_V;
            maxHeight = Mathf.CeilToInt(Mathf.Abs(pos.y - (lineQty * elmHeight + mBtnSpace.y * (lineQty - 1))));
            
        }
        else if (string.IsNullOrEmpty(message.message))
        {
            Dispose();
            return;
        }

        // Bounds b = NGUIMath.CalculateRelativeWidgetBounds(anchor.transform);
        mBackground.width = Mathf.CeilToInt(maxWidth + mFrameSpace.x + mFrameSpace.z);
        mBackground.height = Mathf.CeilToInt(maxHeight + mFrameSpace.y + mFrameSpace.w);
        mBackground.cachedTransform.localPosition = new Vector3((mFrameSpace.z - mFrameSpace.x) * 0.5f, mFrameSpace.w, 0f);
        mAnchor.transform.localPosition = new Vector3((mFrameSpace.x - mFrameSpace.z) * 0.5f, (mFrameSpace.w - mFrameSpace.y + maxHeight) * 0.5f, 0f);

        if (mTween) mTween.Play();
    }
    /// <summary>
    /// 消息框退出
    /// </summary>
    public void ExitBox()
    {
        if (mIsShow)
        {
            if (mTween)
            {
                mTween.PlayReverse();
            }
            else
            {
                Dispose();
            }
        }
        //else Dispose();
    }
    //按钮点击事件
    private void OnClickButtton(MouseEventForward mef)
    {
        Input input = new Input();
        input.buttonIndex = (int)mef.Param;
        input.button = mMessage.button.IndexAvailable(input.buttonIndex) ? mMessage.button[input.buttonIndex] : "";
        if (mToggles != null)
        {
            int len = mToggles.Length;
            input.toggles = new bool[len];
            for (int i = 0; i < len; i++) input.toggles[i] = mToggles[i] ? mToggles[i].value : false;
        }
        if (mUnputs != null)
        {
            int len = mUnputs.Length;
            input.inputs = new string[len];
            for (int i = 0; i < len; i++) input.inputs[i] = mUnputs[i] ? mUnputs[i].value : null;
        }
        if (mMessage.feedback != null)
        {
            mMessage.feedback(input);
            if (!mMessage.manualExit) mMessage.feedback = null;
        }
#if TOLUA
        if (mMessage.luaFunc != null && mMessage.luaFunc.IsAlive)
        {
            mMessage.luaFunc.BeginPCall();
            //message.luaFunc.Push(input.button);
            mMessage.luaFunc.Push(input.buttonIndex);
            if (input.toggles.GetLength() > 0) mMessage.luaFunc.Push(input.toggles);
            if (input.inputs.GetLength() > 0) mMessage.luaFunc.Push(input.inputs);
            mMessage.luaFunc.PCall();
            if (mMessage.manualExit)
            {
                if (mMessage.luaFunc.GetLuaState().LuaGetTop() > 1 && mMessage.luaFunc.CheckBoolean())
                {
                    mMessage.luaFunc.EndPCall();
                    mMessage.luaFunc.Dispose();
                    mMessage.luaFunc = null;
                    mMessage.manualExit = false;
                }
                else
                {
                    mMessage.luaFunc.EndPCall();
                }
            }
            else
            {
                mMessage.luaFunc.EndPCall();
                mMessage.luaFunc.Dispose();
                mMessage.luaFunc = null;
            }
        }
#endif
        else mMessage.manualExit = false;
        if (!mMessage.manualExit) ExitBox();
    }
    /// <summary>
    /// 消息盒子淡出
    /// </summary>
    private void OnDisappear(AnimationAdapter aa)
    {
        if (aa.isForward) return;
        Dispose();
    }
    /// <summary>
    /// 创建一个按钮
    /// </summary>
    /// <param name="index">按钮的索引</param>
    /// <param name="label">按钮的标签</param>
    private GameObject BuildButton(int index, string label)
    {
        int btnIdx = 0;

        if (string.IsNullOrEmpty(label))
        {
            label = index.ToString();
        }
        else
        {
            if (label[0] == '{')
            {
                int idx = label.IndexOf('}', 1);
                if (idx > 0 && int.TryParse(label.Substring(1, idx - 1), out btnIdx))
                {
                    label = label.Substring(idx + 1);
                    btnIdx = Mathf.Clamp(btnIdx, 0, mPrefabBtn.Length - 1);
                    if (string.IsNullOrEmpty(label))
                    {
                        label = index.ToString();
                    }
                }
                else
                {
                    btnIdx = 0;
                }
            }
        }

        GameObject go = mAnchor.AddChild(mPrefabBtn.IndexAvailable(btnIdx) ? mPrefabBtn[btnIdx] : mPrefabBtn[0], "btn_" + index);
        if (!go.GetComponent<Collider>()) NGUITools.AddWidgetCollider(go);
        (go.GetComponent<MouseEventForward>() ?? go.AddComponent<MouseEventForward>()).SetClick(OnClickButtton, index);
        Transform labTrans = go.transform.FindChild("lbl_btn");
        if (labTrans)
        {
            UILabel lab = labTrans.GetComponent<UILabel>();
            if (lab)
            {
                lab.text = label;
            }
        }
        go.SetActive(true);

        return go;
    }
    /// <summary>
    /// 创建一个选择盒
    /// </summary>
    private UIToggle BuildToggle(int index, string label)
    {
        bool check = false;
        int grop = 0;
        int tglIdx = 0;
        if (!string.IsNullOrEmpty(label))
        {
            if (label[0] == '{')
            {
                int idx = label.IndexOf('}');
                if (idx > 0)
                {
                    string[] prefix = label.Substring(1, idx - 1).Split(' ');
                    label = label.Substring(idx + 1);

                    foreach (string p in prefix)
                    {
                        if (p.Equals("t", StringComparison.OrdinalIgnoreCase))
                        {
                            check = true;
                        }
                        else if (p.Equals("g", StringComparison.OrdinalIgnoreCase))
                        {
                            grop = 1;
                        }
                        else if (p.Length > 1)
                        {
                            if(p.StartsWith("s", StringComparison.OrdinalIgnoreCase))
                            {
                                if (int.TryParse(p.Substring(1), out tglIdx))
                                {
                                    tglIdx = Mathf.Clamp(tglIdx, 0, mPrefabToggle.Length - 1);
                                }
                            }
                        }
                    }
                }
            }
        }

        GameObject go = mAnchor.AddChild(mPrefabToggle.IndexAvailable(tglIdx) ? mPrefabToggle[tglIdx] : mPrefabBtn[0], "tgl_" + index);
        UIToggle tgl = go.GetComponent<UIToggle>();
        if (tgl)
        {
            tgl.value = check;
            tgl.group = grop;
        }

        Transform labTrans = go.transform.FindChild("lbl_tgl");
        if (labTrans)
        {
            UILabel lab = labTrans.GetComponent<UILabel>();
            if (lab)
            {
                lab.text = label;
            }
        }
        go.SetActive(true);

        return tgl;
    }
    /// <summary>
    /// 创建一个输入控件
    /// </summary>
    private UIInput BuildInput(int index, string label)
    {
        bool isPassword = false;
        bool maxCharIsByte = false;
        int maxChars = 0;
        int iptIdx = 0;

        if (!string.IsNullOrEmpty(label) && label[0] == '{')
        {
            int idx = label.IndexOf('}');
            if (idx > 0)
            {
                string[] prefix = label.Substring(1, idx - 1).Split(' ');
                label = label.Substring(idx + 1);

                foreach (string p in prefix)
                {
                    if (p.Equals("*", StringComparison.OrdinalIgnoreCase))
                    {
                        isPassword = true;
                    }
                    else if (p.Length > 1)
                    {
                        if (p.StartsWith("b", StringComparison.OrdinalIgnoreCase))
                        {
                            maxCharIsByte = true;
                            int.TryParse(p.Substring(1), out maxChars);
                        }
                        else if (p.StartsWith("c", StringComparison.OrdinalIgnoreCase))
                        {
                            maxCharIsByte = false;
                            int.TryParse(p.Substring(1), out maxChars);
                        }
                        else if (p.StartsWith("s", StringComparison.OrdinalIgnoreCase))
                        {
                            if (int.TryParse(p.Substring(1), out iptIdx))
                            {
                                iptIdx = Mathf.Clamp(iptIdx, 0, mPrefabInput.Length - 1);
                            }
                        }
                    }
                }
            }
        }

        GameObject go = mAnchor.AddChild(mPrefabInput.IndexAvailable(iptIdx) ? mPrefabInput[iptIdx] : mPrefabBtn[0], "ipt_" + index);

        UIInput ipt = go.GetComponent<UIInput>();
        UIInputLogic iplg = null;
        if (isPassword)
        {
            iplg = go.GetComponent<UIInputLogic>() ?? go.AddComponent<UIInputLogic>();
            iplg.disableCN = true;
            ipt.inputType = UIInput.InputType.Password;
            ipt.keyboardType = UIInput.KeyboardType.ASCIICapable;

        }
        if (maxCharIsByte)
        {
            iplg = go.GetComponent<UIInputLogic>() ?? go.AddComponent<UIInputLogic>();
            iplg.byteLimit = maxChars;
        }
        else
        {
            ipt.characterLimit = maxChars;
        }
        Transform labTrans = go.transform.FindChild("lbl_tit");
        if (labTrans)
        {
            UILabel lab = labTrans.GetComponent<UILabel>();
            if (lab)
            {
                lab.text = label;
            }
        }
        labTrans = go.transform.FindChild("lbl_ipt");
        if (labTrans)
        {
            UILabel lab = labTrans.GetComponent<UILabel>();
            if (lab)
            {
                lab.text = L.P_Input + label;
            }
        }
        go.SetActive(true);
        return ipt;
    }
    //清除控件
    private void ClearControl()
    {
        if (mButtons != null)
        {
            foreach (GameObject go in mButtons) NGUITools.Destroy(go);
            mButtons = null;
        }
        if (mToggles != null)
        {
            foreach (UIToggle toggle in mToggles) if (toggle != null) NGUITools.Destroy(toggle.gameObject);
            mToggles = null;
        }
        if (mUnputs != null)
        {
            foreach (UIInput ipt in mUnputs) if (ipt != null) NGUITools.Destroy(ipt.gameObject);
            mUnputs = null;
        }
    }
    //释放所有资源并检测队列
    private void Dispose()
    {
        mMessage = new Message();
        gameObject.SetActive(false);
        ClearControl();
        mIsShow = false;
        if (mQueue.Count > 0) ShowBox(mQueue.Dequeue());
    }
}
