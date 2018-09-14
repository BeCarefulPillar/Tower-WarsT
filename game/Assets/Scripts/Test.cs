using UnityEngine;

public class Test : MonoBehaviour
{
    public enum eTransform
    {
        Reduce,     //减少
        Add,        //增加
        Loop,       //往复
    }

    public int c = 20;
    private int idx = 0;

    public float speed = 0.04f;

    private int dir = -1;

    public eTransform etf = eTransform.Loop;

    private float max;
    private float min;

    private void Awake()
    {
        max = Mathf.Max(new[] { transform.localScale.x, transform.localScale.y, transform.localScale.z });
        min = 0.0001f;
    }

    private void Update()
    {
        if (idx < c)
        {
            switch (etf)
            {
                case eTransform.Reduce:
                    {
                        transform.localScale -= Vector3.one * speed;
                        if (transform.localScale.x <= min)
                        {
                            transform.localScale = Vector3.one * max;
                            ++idx;
                        }
                    }
                    break;
                case eTransform.Add:
                    transform.localScale += Vector3.one * speed;
                    if (transform.localScale.x >= max)
                    {
                        transform.localScale = Vector3.one * min;
                        ++idx;
                    }
                    break;
                case eTransform.Loop:
                    {
                        transform.localScale += dir * Vector3.one * speed;
                        if (transform.localScale.x > max)
                        {
                            transform.localScale = Vector3.one * max;
                            dir *= -1;
                            ++idx;
                        }
                        else if (transform.localScale.x < min)
                        {
                            transform.localScale = Vector3.one * min;
                            dir *= -1;
                            ++idx;
                        }
                    }
                    break;
            }
        }
    }
}