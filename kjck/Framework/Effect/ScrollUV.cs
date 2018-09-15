using UnityEngine;

public class ScrollUV : MonoBehaviour
{
    public float scrollSpeed_X = 0.5f;
    public float scrollSpeed_Y = 0.5f;

    [System.NonSerialized] Renderer _renderer;

    void Start()
    {
        _renderer = GetComponent<Renderer>();
        if (!_renderer) enabled = false;
    }

    void Update()
    {
        float offsetX = Time.time * scrollSpeed_X;
        float offsetY = Time.time * scrollSpeed_Y;
        _renderer.material.mainTextureOffset = new Vector2(offsetX, offsetY);
    }
}