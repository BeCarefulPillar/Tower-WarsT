using UnityEngine;

public class DragRotationContents : MonoBehaviour
{
    public DragRotationView dragView;

    void Start()
    {
        if (dragView == null) dragView = NGUITools.FindInParents<DragRotationView>(gameObject);
        if (transform.parent != dragView.Trans) enabled = false;
    }


    void OnPress(bool pressed)
    {
        if (dragView.enabled && NGUITools.GetActive(gameObject) && dragView != null)
        {
            dragView.OnPress(transform, pressed);
        }
    }

    void OnDrag(Vector2 delta)
    {
        if (dragView.enabled && NGUITools.GetActive(gameObject) && dragView != null)
        {
            dragView.Drag(delta);
        }
    } 

}
