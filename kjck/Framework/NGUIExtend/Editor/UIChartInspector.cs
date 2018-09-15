using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

/// <summary>
/// Inspector class used to edit HeroChart.
/// </summary>

[CustomEditor(typeof(UIChart))]
public class UIChartInspector : UIWidgetInspector
{
    protected UIChart mChart;

	/// <summary>
	/// Atlas selection callback.
	/// </summary>

	void OnSelectAtlas (Object obj)
	{
		if (mChart != null)
		{
			NGUIEditorTools.RegisterUndo("Atlas Selection", mChart);
			bool resize = (mChart.atlas == null);
			mChart.atlas = obj as UIAtlas;
			if (resize) mChart.MakePixelPerfect();
			EditorUtility.SetDirty(mChart.gameObject);
		}
	}

	/// <summary>
	/// Sprite selection callback function.
	/// </summary>

	void SelectSprite (string spriteName)
	{
		if (mChart != null && mChart.spriteName != spriteName)
		{
			NGUIEditorTools.RegisterUndo("Sprite Change", mChart);
			mChart.spriteName = spriteName;
			mChart.MakePixelPerfect();
			EditorUtility.SetDirty(mChart.gameObject);
		}
	}

	/// <summary>
	/// Draw the atlas and sprite selection fields.
	/// </summary>

    override protected bool ShouldDrawProperties()
	{
        mChart = mWidget as UIChart;
        ComponentSelector.Draw<UIAtlas>(mChart.atlas, OnSelectAtlas, true);
		if (mChart.atlas == null) return false;
        NGUIEditorTools.DrawAdvancedSpriteField(mChart.atlas, mChart.spriteName, SelectSprite, false);
		return true;
	}

	/// <summary>
	/// Sprites's custom properties based on the type.
	/// </summary>

    override protected void DrawCustomProperties()
	{
		NGUIEditorTools.DrawSeparator();

        int vers = EditorGUILayout.IntField("Vertices", mChart.Vertices);
        vers = Mathf.Max(3, vers);
        if (vers != mChart.Vertices)
        {
            NGUIEditorTools.RegisterUndo("Vertices Change", mChart);
            mChart.Vertices = vers;
            EditorUtility.SetDirty(mChart.gameObject);
        }

        bool changeVal = false;
        for (int i = 0; i < mChart.VertexValues.Length; i++)
        {
            float val = EditorGUILayout.FloatField("Ver Value " + (i + 1), mChart.VertexValues[i]);
            val = Mathf.Clamp01(val);
            if (mChart.VertexValues[i] != val)
            {
                mChart.VertexValues[i] = val;
                changeVal = true;
            }
        }
        if (changeVal) mChart.MarkAsChanged();

		GUILayout.Space(4f);

        base.DrawCustomProperties();
	}

	/// <summary>
	/// All widgets have a preview.
	/// </summary>

	public override bool HasPreviewGUI () { return true; }

	/// <summary>
	/// Draw the sprite preview.
	/// </summary>

	public override void OnPreviewGUI (Rect rect, GUIStyle background)
	{
		if (mChart == null || !mChart.isValid) return;

		Texture2D tex = mChart.mainTexture as Texture2D;
		if (tex == null) return;

        UISpriteData sd = mChart.atlas.GetSprite(mChart.spriteName);
        if (sd != null)//add by kiol 2015.11.17
        {
            if (mChart.atlas.spriteMaterial.IsMergeShader())
            {
                int idx = sd.x / tex.width;
                if (idx > 0)
                {
                    tex = mChart.atlas.spriteMaterial.GetMergeTexture(idx) as Texture2D;
                    if (tex)
                    {
                        UISpriteData sp = new UISpriteData();
                        sp.CopyFrom(sd);
                        sp.x %= tex.width;
                        sd = sp;
                    }
                }
            }
        }
        NGUIEditorTools.DrawSprite(tex, rect, sd, mChart.color);
	}
}

