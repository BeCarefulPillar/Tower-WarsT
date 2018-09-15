using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class UIFragEffect : UIWidget
{
    [SerializeField] private UIWidget mTarget;
    //[SerializeField] private int mSepX = 2;
    //[SerializeField] private int mSepY = 2;
    [SerializeField] public bool destroyWidget = false;

    protected override void OnStart()
    {
        base.OnStart();

        if (!mTarget) mTarget = NGUITools.FindInParents<UIWidget>(cachedGameObject);
        if (mTarget)
        {
            mTarget.onPostFill += OnPostFill;
        }
        else
        {
            enabled = false;
        }
    }

    private void OnPostFill(UIWidget widget, int bufferOffset, List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        verts.RemoveRange(bufferOffset, verts.Count - bufferOffset);
        uvs.RemoveRange(bufferOffset, uvs.Count - bufferOffset);
        cols.RemoveRange(bufferOffset, cols.Count - bufferOffset);
        
    }
}