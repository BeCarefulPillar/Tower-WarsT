using UnityEngine;

public class HUDFPS : MonoBehaviour
{
    public float updateInterval = 0.5f;

    private float accum = 0; // FPS accumulated over the interval
    private int frames = 0; // Frames drawn over the interval
    private float timeleft; // Left time for current interval

    UILabel lab;

    void OnEnabled()
    {
        timeleft = updateInterval;
        if (lab) lab.text = "";
    }

    void Start()
    {
        lab = GetComponent<UILabel>();
        if (!lab)
        {
            Debug.Log("HUDFPS needs a UILabel component!");
            enabled = false;
            return;
        }
    }

    void Update()
    {
        float delta = Time.unscaledDeltaTime;

        timeleft -= delta;
        accum += delta;
        ++frames;

        // Interval ended - update GUI text and start new interval
        if (timeleft <= 0f)
        {

            // display two fractional digits (f2 format)
            float fps = frames / accum;
            lab.text = System.String.Format("{0:F2} FPS Root={1} Panel={2} Camera={3}", fps, UIRoot.list.Count, UIPanel.list.Count, Camera.allCamerasCount);

            if (fps < 30) lab.color = Color.yellow;
            else if (fps < 10) lab.color = Color.red;
            else lab.color = Color.green;

            //  DebugConsole.Log(format,level);
            timeleft = updateInterval;
            accum = 0.0F;
            frames = 0;
        }
    }
}