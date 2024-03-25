using Unity.Mathematics;
using UnityEngine;
using UnityEditor;

public class GradientTextureTool : EditorWindow
{
    Color leftColor = Color.black;
    Color rightColor = Color.white;
    int width = 100;
    int height = 2;
    int steps = 10;

    [MenuItem("Tools/Gradient Texture Generator")]
    static void Init()
    {
        GradientTextureTool window = (GradientTextureTool)EditorWindow.GetWindow(typeof(GradientTextureTool));
        window.Show();
    }

    void OnGUI()
    {
        leftColor = EditorGUILayout.ColorField("Start Color", leftColor);
        rightColor = EditorGUILayout.ColorField("End Color", rightColor);
        width = EditorGUILayout.IntField("Width", width);
        height = EditorGUILayout.IntField("Height", height);
        steps = EditorGUILayout.IntField("Steps", steps);

        if (GUILayout.Button("Generate Gradient Texture"))
        {
            Texture2D gradientTexture = CreateGradientTexture(leftColor, rightColor, width, height,steps);
            string path = EditorUtility.SaveFilePanel("Save Gradient Texture", "", "GradientTexture", "png");
            if (!string.IsNullOrEmpty(path))
                System.IO.File.WriteAllBytes(path, gradientTexture.EncodeToPNG());
        }
    }

    Texture2D CreateGradientTexture(Color start, Color end, int width, int height,int steps)
    {
        Texture2D texture = new Texture2D(width, height);

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                float t = (float)x / (width);
                t *= (steps);
                t =  Mathf.Floor(t)/(steps-1);
                Color color = Color.Lerp(start, end, t);
                texture.SetPixel(x, y, color);
            }
        }

        texture.Apply();

        return texture;
    }
}