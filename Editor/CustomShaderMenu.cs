
using System;
using System.IO;

namespace UnityEditor.CreateShaderTemplate
{
    public static class CustomShaderMenu
    {
        // 添加一个新的Shader菜单项
        [MenuItem("Assets/Create/ShaderTemple/Custom Shader", priority = 100)]
        public static void CreateCustomShader()
        {
            // 创建一个新的Shader文件
            ProjectWindowUtil.CreateScriptAssetFromTemplateFile("Packages/com.le888.create-shader-template/Editor/CustomShaderTemplate.shader", "NewCustomShader.shader");
        }
        
        [MenuItem("Assets/Create/ShaderTemple/Custom Shader PBR", priority = 200)]
        public static void CreateCustomShaderPBR()
        {
            // 创建一个新的Shader文件
            ProjectWindowUtil.CreateScriptAssetFromTemplateFile("Packages/com.le888.create-shader-template/Editor/CustomShaderTemplatePBR.shader", "NewCustomShader.shader");
        }
        
        [MenuItem("Assets/Create/ShaderTemple/Custom HLSL", priority = 201)]
        public static void CreateCustomHLSL()
        {
            // 创建一个新的Shader文件
            ProjectWindowUtil.CreateScriptAssetFromTemplateFile("Packages/com.le888.create-shader-template/Editor/HLSLTemplate.hlsl", "NewCustomHLSL.hlsl");
        }
        
    }
    
    public class ScriptsInfoEditor : UnityEditor.AssetModificationProcessor
    {
        public const string authorName = "tackor(修改为你自己的名称即可)";

        private static string[] OnWillSaveAssets(string[] paths)
        {

            foreach (var v in paths)
            {
                var path = v;
                path = path.Replace(".meta", "");
                if (path.EndsWith(".hlsl"))
                {
                    string fileName = Path.GetFileName(path);
                    fileName = fileName.Substring(0, fileName.LastIndexOf("."));
                    string str = File.ReadAllText(path);
                    str = str.Replace("#UPPNAME#", fileName.ToUpper());
                    File.WriteAllText(path, str);
                }
            }
            
            

            return paths;
        }

        // private static void OnWillCreateAsset(string path)
        // {
        //     
        //     path = path.Replace(".meta", "");
        //     if (path.EndsWith(".HLSL"))
        //     {
        //         string fileName = Path.GetFileName(path);
        //         fileName = fileName.Substring(0, fileName.LastIndexOf("."));
        //         string str = File.ReadAllText(path);
        //         str = str.Replace("#UPPNAME#", fileName.ToUpper());
        //         File.WriteAllText(path, str);
        //     }
        // }
    }
}    

