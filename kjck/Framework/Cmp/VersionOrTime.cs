using UnityEngine;

public class VersionOrTime : MonoBehaviour
{
    [SerializeField] bool isVersion;
    [System.NonSerialized] UILabel lab;

    void Start()
    {
        lab = GetComponent<UILabel>();
        if (lab)
        {
            if (isVersion)
            {
                lab.text = "V " + ENV.BundleVersion;
                this.DestructIfOnly();
            }
        }
        else
        {
            this.DestructIfOnly();
        }
    }

    void Update()
    {
        lab.text = System.DateTime.Now.ToString("HH:mm:ss");
    }
}
