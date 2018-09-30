using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using UnityEngine;
using UnityEditor;
using System.IO;
 
public class AnimatedGifDrawer : MonoBehaviour
{
    public float speed = 0.2f;
    public Vector2 drawPosition;
    public Object gif;
    public string nm;
 
    public List<Texture2D> gifFrames = new List<Texture2D>();
    private void Awake()
    {
        var gifImage = Image.FromFile(AssetDatabase.GetAssetPath(gif));
        var dimension = new FrameDimension(gifImage.FrameDimensionsList[0]);
        int frameCount = gifImage.GetFrameCount(dimension);
        for (int i = 0; i < frameCount; i++)
        {
            gifImage.SelectActiveFrame(dimension, i);
            var frame = new Bitmap(gifImage.Width, gifImage.Height);
            System.Drawing.Graphics.FromImage(frame).DrawImage(gifImage, Point.Empty);
            var frameTexture = new Texture2D(frame.Width, frame.Height);
            for (int x = 0; x < frame.Width; x++)
                for (int y = 0; y < frame.Height; y++)
                {
                    System.Drawing.Color sourceColor = frame.GetPixel(x, y);
                    //frameTexture.SetPixel(frame.Width - 1 - x, y, new Color32(sourceColor.R, sourceColor.G, sourceColor.B, sourceColor.A));
                    frameTexture.SetPixel(x, frame.Height-1-y, new Color32(sourceColor.R, sourceColor.G, sourceColor.B, sourceColor.A));
                }
            frameTexture.Apply();
            gifFrames.Add(frameTexture);
        }
    }

    [ContextMenu("生成png")]
    private void SaveToPng()
    {
        if(string.IsNullOrEmpty(nm))
            return;
        for (int i = 0; i < gifFrames.Count; ++i)
        {
            var bytes = gifFrames[i].EncodeToPNG();
            var file = File.Open(Application.dataPath + "/" + nm+ (i+1).ToString("00") + ".png", FileMode.Create);
            var binary = new BinaryWriter(file);
            binary.Write(bytes);
            file.Close();
        }
    }
 
    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(drawPosition.x, drawPosition.y, gifFrames[0].width, gifFrames[0].height), gifFrames[(int)(Time.frameCount * speed) % gifFrames.Count]);
    }
}