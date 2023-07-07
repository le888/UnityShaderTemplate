
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
    }
}    

