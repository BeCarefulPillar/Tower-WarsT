using UnityEngine;
using System.Collections;

[RequireComponent(typeof(UILabel))]
public class Localize : MonoBehaviour
{
    public string key = "";

    private void Start()
    {
        if (string.IsNullOrEmpty(key)) return;
        UILabel label = GetComponent<UILabel>();
        if (label) label.text = L.Get(key);
        Destroy(this);
    }
}
