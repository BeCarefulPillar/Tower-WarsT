using UnityEngine;
using UnityEditor;
using UnityEditor.ProjectWindowCallback;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

public class CreateLuaScriptAsset : EndNameEditAction
{
    public override void Action(int instanceId, string pathName, string resourceFile)
    {
        ProjectWindowUtil.ShowCreatedAsset(CreateScriptAssetFromTemplate(pathName, resourceFile));
    }

    internal static Object CreateScriptAssetFromTemplate(string pathName, string resourceFile)
    {
        string text = "";
        using (StreamReader streamReader = new StreamReader(resourceFile))
            text = streamReader.ReadToEnd();
        text = Regex.Replace(text, "LuaClass", Path.GetFileNameWithoutExtension(pathName));
        using (StreamWriter streamWriter = new StreamWriter(Path.GetFullPath(pathName), false, new UTF8Encoding(true, false)))
            streamWriter.Write(text);
        AssetDatabase.ImportAsset(pathName);//导入指定路径下的资源
        return AssetDatabase.LoadAssetAtPath(pathName, typeof(Object));//返回指定路径下的所有Object对象  
    }
}
