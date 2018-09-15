using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(UIWrapGrid), true)]
public class UIWrapGridEditor : Editor
{
    public void DrawSeparator()
    {
        GUILayout.Space(12f);

        if (Event.current.type == EventType.Repaint)
        {
            Texture2D tex = EditorGUIUtility.whiteTexture;
            Rect rect = GUILayoutUtility.GetLastRect();
            GUI.color = new Color(0f, 0f, 0f, 0.25f);
            //GUI.DrawTexture(new Rect(0f, rect.yMin + 6f, Screen.width, 4f), tex);
            //GUI.DrawTexture(new Rect(0f, rect.yMin + 6f, Screen.width, 1f), tex);
            GUI.DrawTexture(new Rect(0f, rect.yMin + 9f, Screen.width, 1f), tex);
            GUI.color = Color.white;
        }
    }

    public override void OnInspectorGUI()
    {
        GUILayout.Space(6f);
        NGUIEditorTools.SetLabelWidth(90f);

        if (Application.isPlaying)
        {
            UIWrapGrid wgrid = target as UIWrapGrid;

            SerializedProperty sp = serializedObject.FindProperty("mPanel");
            Object src = sp.objectReferenceValue;
            UIScrollView sv = src is UIPanel ? (src as UIPanel).GetComponent<UIScrollView>() : null;
            EditorGUILayout.PropertyField(sp, new GUIContent("Panel"), GUILayout.Width(240f));
            if (src != sp.objectReferenceValue) wgrid.needReset = true;

            sp = serializedObject.FindProperty("mHolderObject");
            src = sp.objectReferenceValue;
#if UNITY_4_6 || UNITY_4_7
            EditorGUILayout.ObjectField("Holder", src, typeof(IWrapGridHolder), true, GUILayout.Width(240f));
            if (src != sp.objectReferenceValue)
            {
                if (sp.objectReferenceValue is IWrapGridHolder)
                {
                    wgrid.holder = sp.objectReferenceValue as IWrapGridHolder;
                }
                else if (sp.objectReferenceValue is GameObject)
                {
                    sp.objectReferenceValue = GetWrapGridHolder(sp.objectReferenceValue as GameObject);
                    wgrid.holder = sp.objectReferenceValue as IWrapGridHolder;
                }
                if (sp.objectReferenceValue is Component)
                {
                    sp.objectReferenceValue = GetWrapGridHolder(sp.objectReferenceValue as Component);
                    wgrid.holder = sp.objectReferenceValue as IWrapGridHolder;
                }
                else
                {
                    sp.objectReferenceValue = null;
                    wgrid.holder = null;
                }
            }
#else
            EditorGUILayout.ObjectField(sp, new GUIContent("Holder"), GUILayout.Width(240f));
            if (src != sp.objectReferenceValue)
            {
                if (sp.objectReferenceValue is IWrapGridHolder)
                {
                    wgrid.holder = sp.objectReferenceValue as IWrapGridHolder;
                }
                else if (sp.objectReferenceValue is GameObject)
                {
                    sp.objectReferenceValue = (sp.objectReferenceValue as GameObject).GetComponent<IWrapGridHolder>() as Component;
                    wgrid.holder = sp.objectReferenceValue as IWrapGridHolder;
                }
                if (sp.objectReferenceValue is Component)
                {
                    sp.objectReferenceValue = (sp.objectReferenceValue as Component).GetComponent<IWrapGridHolder>() as Component;
                    wgrid.holder = sp.objectReferenceValue as IWrapGridHolder;
                }
                else
                {
                    sp.objectReferenceValue = null;
                    wgrid.holder = null;
                }
            }
#endif


            wgrid.itemPrefab = EditorGUILayout.ObjectField("ItemPrefab", wgrid.itemPrefab, typeof(GameObject), true, GUILayout.Width(240f)) as GameObject;

            GUILayout.Space(8f);

#if TOLUA
            wgrid.luaContainer = EditorGUILayout.ObjectField("LuaContainer", wgrid.luaContainer, typeof(LuaContainer), true, GUILayout.Width(240f)) as LuaContainer;
            EditorGUILayout.Toggle("TransferSelf", wgrid.transferSelf, GUILayout.Width(240f));
            EditorGUILayout.TextField("OnItemInit", wgrid.onItemInit, GUILayout.Width(240f));
            EditorGUILayout.TextField("OnItemAlign", wgrid.onItemAlign, GUILayout.Width(240f));
            EditorGUILayout.TextField("OnRequestCount", wgrid.onRequestCount, GUILayout.Width(240f));

            DrawSeparator();
#endif

            wgrid.itemCacheSize = EditorGUILayout.IntField("ItemSize", wgrid.itemCacheSize, GUILayout.Width(240f));
            wgrid.requestTimeOut = EditorGUILayout.FloatField("RequestTime", wgrid.requestTimeOut, GUILayout.Width(240f));
            wgrid.cullItem = EditorGUILayout.Toggle("CullItem", wgrid.cullItem, GUILayout.Width(240f));
            wgrid.animateSmoothly = EditorGUILayout.Toggle("Smoothly", wgrid.animateSmoothly, GUILayout.Width(240f));
            wgrid.addItemWaitTime = EditorGUILayout.FloatField("ItemWaitTime", wgrid.addItemWaitTime, GUILayout.Width(240f));

            DrawSeparator();
            EditorGUILayout.BeginHorizontal();
            wgrid.isHorizontal = EditorGUILayout.Toggle("Horizontal", wgrid.isHorizontal, GUILayout.Width(160f));
            if (sv)
            {
                if (sv.movement == UIScrollView.Movement.Horizontal)
                {
                    wgrid.isHorizontal = true;
                }
                else if (sv.movement == UIScrollView.Movement.Vertical)
                {
                    wgrid.isHorizontal = false;
                }
                else
                {
                    EditorGUILayout.BeginVertical();
                    EditorGUILayout.HelpBox("UIScrollView 的滑动方式只能水平或垂直", MessageType.Error);
                    EditorGUILayout.EndVertical();
                }
            }
            wgrid.orginAlign = (UIWrapGrid.Align)EditorGUILayout.EnumPopup("OrginAlign", wgrid.orginAlign, GUILayout.Width(200f));
            EditorGUILayout.EndHorizontal();
            wgrid.orginOffset = EditorGUILayout.Vector3Field("OrginOffset", wgrid.orginOffset, GUILayout.Width(396f));
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Grid", GUILayout.Width(85f));
            NGUIEditorTools.SetLabelWidth(40f);
            wgrid.gridWidth = EditorGUILayout.FloatField("Width", wgrid.gridWidth, GUILayout.Width(100f));
            wgrid.gridHeight = EditorGUILayout.FloatField("Height", wgrid.gridHeight, GUILayout.Width(100f));
            wgrid.gridCountPerLine = EditorGUILayout.IntField("Count", wgrid.gridCountPerLine, GUILayout.Width(100f));
            EditorGUILayout.EndHorizontal();

            DrawSeparator();
            NGUIEditorTools.SetLabelWidth(90f);
            wgrid.alignItem = EditorGUILayout.Toggle("AlignItem", wgrid.alignItem, GUILayout.Width(240f));
            if (wgrid.alignItem)
            {
                wgrid.alignOffset = EditorGUILayout.FloatField("AlignOffset", wgrid.alignOffset, GUILayout.Width(240f));
            }
        }
        else
        {
            SerializedProperty sp = serializedObject.FindProperty("mPanel");
            EditorGUILayout.PropertyField(sp, new GUIContent("Panel"), GUILayout.Width(240f));
            UIScrollView sv = sp.objectReferenceValue is UIPanel ? (sp.objectReferenceValue as UIPanel).GetComponent<UIScrollView>() : null;
            sp = serializedObject.FindProperty("mHolderObject");
#if UNITY_4_6 || UNITY_4_7
            EditorGUILayout.ObjectField("Holder", sp.objectReferenceValue, typeof(IWrapGridHolder), true, GUILayout.Width(240f));
            if (!(sp.objectReferenceValue is IWrapGridHolder))
            {
                if (sp.objectReferenceValue is GameObject)
                {
                    sp.objectReferenceValue = GetWrapGridHolder(sp.objectReferenceValue as GameObject);

                }
                if (sp.objectReferenceValue is Component)
                {
                    sp.objectReferenceValue = GetWrapGridHolder(sp.objectReferenceValue as Component);

                }
                else
                {
                    sp.objectReferenceValue = null;
                }
            }
#else
            EditorGUILayout.ObjectField(sp, new GUIContent("Holder"), GUILayout.Width(240f));
            if (!(sp.objectReferenceValue is IWrapGridHolder))
            {
                if (sp.objectReferenceValue is GameObject)
                {
                    sp.objectReferenceValue = (sp.objectReferenceValue as GameObject).GetComponent<IWrapGridHolder>() as Component;
                }
                if (sp.objectReferenceValue is Component)
                {
                    sp.objectReferenceValue = (sp.objectReferenceValue as Component).GetComponent<IWrapGridHolder>() as Component;
                }
                else
                {
                    sp.objectReferenceValue = null;
                }
            }
#endif

            EditorGUILayout.PropertyField(serializedObject.FindProperty("mItemPrefab"), new GUIContent("ItemPrefab"), GUILayout.Width(240f));

            GUILayout.Space(8f);

#if TOLUA
            sp = serializedObject.FindProperty("mLuaContainer");
            sp.objectReferenceValue = EditorGUILayout.ObjectField("LuaContainer", sp.objectReferenceValue, typeof(LuaContainer), true, GUILayout.Width(240f));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("transferSelf"), new GUIContent("transferSelf"), GUILayout.Width(240f));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("onItemInit"), new GUIContent("OnItemInit"), GUILayout.Width(240f));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("onItemAlign"), new GUIContent("OnItemAlign"), GUILayout.Width(240f));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("onRequestCount"), new GUIContent("OnRequestCount"), GUILayout.Width(240f));

            DrawSeparator();
#endif

            DrawSeparator();

            EditorGUILayout.PropertyField(serializedObject.FindProperty("mItemCacheSize"), new GUIContent("ItemSize"), GUILayout.Width(240f));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("requestTimeOut"), new GUIContent("RequestTime"), GUILayout.Width(240f));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("mCullItem"), new GUIContent("CullItem"), GUILayout.Width(240f));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("animateSmoothly"), new GUIContent("Smoothly"), GUILayout.Width(240f));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("addItemWaitTime"), new GUIContent("ItemWaitTime"), GUILayout.Width(240f));

            DrawSeparator();
            EditorGUILayout.BeginHorizontal();
            sp = serializedObject.FindProperty("mIsHorizontal");
            EditorGUILayout.PropertyField(sp, new GUIContent("Horizontal"), GUILayout.Width(160f));
            if (sv)
            {
                if (sv.movement == UIScrollView.Movement.Horizontal)
                {
                    sp.boolValue = true;
                }
                else if (sv.movement == UIScrollView.Movement.Vertical)
                {
                    sp.boolValue = false;
                }
                else
                {
                    EditorGUILayout.BeginVertical();
                    EditorGUILayout.HelpBox("UIScrollView 的滑动方式只能水平或垂直", MessageType.Error);
                    EditorGUILayout.EndVertical();
                }
            }
            EditorGUILayout.PropertyField(serializedObject.FindProperty("mOrginAlign"), new GUIContent("OrginAlign"), GUILayout.Width(200f));
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.PropertyField(serializedObject.FindProperty("mOrginOffset"), new GUIContent("OrginOffset"), GUILayout.Width(396f));
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Grid", GUILayout.Width(85f));
            NGUIEditorTools.SetLabelWidth(40f);
            EditorGUILayout.PropertyField(serializedObject.FindProperty("mGridWidth"), new GUIContent("Width"), GUILayout.Width(100f));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("mGridHeight"), new GUIContent("Height"), GUILayout.Width(100f));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("mGridCountPerLine"), new GUIContent("Count"), GUILayout.Width(100f));
            EditorGUILayout.EndHorizontal();

            DrawSeparator();
            NGUIEditorTools.SetLabelWidth(90f);

            sp = serializedObject.FindProperty("mAlignItem");
            EditorGUILayout.PropertyField(sp, new GUIContent("AlignItem"), GUILayout.Width(240f));
            if (sp.boolValue)
            {
                EditorGUILayout.PropertyField(serializedObject.FindProperty("mAlignOffset"), new GUIContent("AlignOffset"), GUILayout.Width(240f));
            }
        }

        serializedObject.ApplyModifiedProperties();
    }

#if UNITY_4_6 || UNITY_4_7
    private MonoBehaviour GetWrapGridHolder(GameObject go)
    {
        MonoBehaviour[] mbs = go.GetComponents<MonoBehaviour>();
        if(mbs != null && mbs .Length > 0)
        {
            for (int i = 0; i < mbs.Length; i++)
            {
                if(mbs[i] is IWrapGridHolder)
                {
                    return mbs[i];
                }
            }
        }
        return null;
    }
    private MonoBehaviour GetWrapGridHolder(Component cmp)
    {
        MonoBehaviour[] mbs = cmp.GetComponents<MonoBehaviour>();
        if (mbs != null && mbs.Length > 0)
        {
            for (int i = 0; i < mbs.Length; i++)
            {
                if (mbs[i] is IWrapGridHolder)
                {
                    return mbs[i];
                }
            }
        }
        return null;
    }
#endif
}
