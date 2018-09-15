//NGUI Extend Copyright © 何权

using UnityEngine;
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(UITrail), true)]
public class UITrailEditor : UIWidgetInspector
{
    UITrail mTrail;

    protected override void OnEnable()
    {
        base.OnEnable();
        mTrail = target as UITrail;
        //lastTicks = System.DateTime.Now.Ticks;
        //EditorApplication.update += OnUpdate;
    }

    /// <summary>
    /// 图集选择回调.
    /// </summary>
    void OnSelectAtlas(Object obj)
    {
        mTrail.atlas = obj as UIAtlas;
        NGUITools.SetDirty(serializedObject.targetObject);
        NGUISettings.atlas = obj as UIAtlas;
    }

    /// <summary>
    /// 精灵选择回调.
    /// </summary>
    void SelectSprite(string spriteName)
    {
        mTrail.spriteName = spriteName;
        NGUITools.SetDirty(serializedObject.targetObject);
        NGUISettings.selectedSprite = spriteName;
    }

    protected override bool ShouldDrawProperties()
    {
        if (!mTrail.mainTexture || mTrail.atlas)
        {
            GUILayout.BeginHorizontal();
            if (NGUIEditorTools.DrawPrefixButton("Atlas", GUILayout.Width(64f))) ComponentSelector.Show<UIAtlas>(OnSelectAtlas);
            mTrail.atlas = EditorGUILayout.ObjectField(mTrail.atlas, typeof(UIAtlas), false) as UIAtlas;
            if (GUILayout.Button("Edit", GUILayout.Width(40f)))
            {
                if (mTrail.atlas)
                {
                    NGUISettings.atlas = mTrail.atlas;
                    NGUIEditorTools.Select(mTrail.atlas.gameObject);
                }
            }
            GUILayout.EndHorizontal();
            NGUIEditorTools.DrawAdvancedSpriteField(mTrail.atlas, mTrail.spriteName, SelectSprite, false);
        }
        if ((!mTrail.mainTexture && !mTrail.atlas) || mTrail.material)
        {
            mTrail.material = EditorGUILayout.ObjectField("Material", mTrail.material, typeof(Material), false) as Material;
        }
        if (!mTrail.material && !mTrail.atlas)
        {
            mTrail.mainTexture = EditorGUILayout.ObjectField("Texture", mTrail.mainTexture, typeof(Texture), false) as Texture;
            mTrail.shader = EditorGUILayout.ObjectField("Shader", mTrail.shader, typeof(Shader), false) as Shader;
        }

        mTrail.flip = (UIEffectFlip)EditorGUILayout.EnumPopup("Flip", mTrail.flip);
        mTrail.isActualBounds = EditorGUILayout.Toggle("ActualBound", mTrail.isActualBounds);

        NGUIEditorTools.DrawSeparator();

        return mTrail.mainTexture;
    }

    protected override void DrawCustomProperties()
    {
        GUILayout.Space(6f);
        EditorGUIUtility.labelWidth = 124;

        mTrail.Relative = EditorGUILayout.ObjectField("Relative", mTrail.Relative, typeof(Transform), true) as Transform;

        mTrail.LifeTime = EditorGUILayout.FloatField("Life Time", mTrail.LifeTime);
        mTrail.StartWidth = EditorGUILayout.FloatField("Start Width", mTrail.StartWidth);
        mTrail.EndWidth = EditorGUILayout.FloatField("End Width", mTrail.EndWidth);
        mTrail.MinVertexDistance = EditorGUILayout.FloatField("Min Vertex Distance", mTrail.MinVertexDistance);

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("Color", GUILayout.Width(120f));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("mGradient"), GUIContent.none, GUILayout.MinWidth(80), GUILayout.MaxWidth(240));
        EditorGUILayout.EndHorizontal();

        base.DrawCustomProperties();
    }
}
