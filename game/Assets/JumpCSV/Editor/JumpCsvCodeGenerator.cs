using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.CodeDom;
using System.CodeDom.Compiler;
using System.Linq;
using System.Reflection;
using System.Text;
using Microsoft.CSharp;
using JumpCSV;

public class JumpCsvCodeGenerator {
    static List<CsvSpreadSheet.Record> allRecords = new List<CsvSpreadSheet.Record>();
    private static string GenerateCSharpCode(string fileName,  CodeCompileUnit compileunit)
    {
        // Generate the code with the C# code provider.
        CSharpCodeProvider provider = new CSharpCodeProvider();
        // Build the output file name. 
        string sourceFile = fileName;


        // check directory
        string directory = Path.GetDirectoryName(fileName);
        if(!Directory.Exists(directory)) {
            Directory.CreateDirectory(directory);
        }

        // Create a TextWriter to a StreamWriter to the output file.
        using (StreamWriter sw = new StreamWriter(sourceFile, false))
        {
            IndentedTextWriter tw = new IndentedTextWriter(sw, "    ");

            // Generate source code using the code provider.
            provider.GenerateCodeFromCompileUnit(compileunit, tw,
                new CodeGeneratorOptions());

            // Close the output file.
            tw.Close();
        }
        return sourceFile;
    }

    public static void CreateEmptyCsvManagerSourceFile() {
        // clear ERecordId
        CodeCompileUnit codeUnit = new CodeCompileUnit();
        CodeNamespace   jumpCsvNS = new CodeNamespace("JumpCSV");

        // add import directives used by the namespace.
        jumpCsvNS.Imports.Add(new CodeNamespaceImport("System"));
        jumpCsvNS.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));
        
        codeUnit.Namespaces.Add(jumpCsvNS);

        // add ERecordId enum
        jumpCsvNS.Types.Add(BuildRecordIdDeclaration("ERId", new List<CsvSpreadSheet.Record>()));

        // add CsvManager class
        jumpCsvNS.Types.Add(BuildCsvManagerClass("Assets/Build/CSV/Common/", new string[]{}));
        GenerateCSharpCode( JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvManagerFileName) , codeUnit);         
    }

    public static void CreateAllCsvClassSourceFiles(string targetCsvPath, string defaultCsvPath) {
        string csvManagerFileName;
        List<string> csvFiles;
        try {            
            csvManagerFileName = CreateCsvManagerSourceFile(targetCsvPath, defaultCsvPath);
            csvFiles = CreateAllCsvReadClassSourceFiles(targetCsvPath, defaultCsvPath);
        } catch(Exception e) {
            throw new Exception("Create class source file failed with error " + e.ToString());
        }

        string containsFolder = Path.GetDirectoryName(JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvManagerFileName));

        if(!Directory.Exists(containsFolder)) {
            Directory.CreateDirectory(containsFolder);
        }

        FileUtil.ReplaceFile(csvManagerFileName, JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvManagerFileName));
        FileUtil.DeleteFileOrDirectory(csvManagerFileName);

        string csvReadClassContainsFolder = JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvSourceCodeFileDirectory);
        if(!Directory.Exists(csvReadClassContainsFolder)) {
            Directory.CreateDirectory(csvReadClassContainsFolder);
        }

        var allExpiredCsvFile = JumpCsvEditorHelper.GetAllExpiredCsvFile(); 
        foreach(string f in csvFiles) {
            if(Array.Exists(allExpiredCsvFile, x => Path.GetFileNameWithoutExtension(x) == Path.GetFileNameWithoutExtension(f).Replace(JumpCsvConfig.CsvDataClassPostfixName, ""))) {
                FileUtil.ReplaceFile(f, JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvEditorHelper.PathCombine(JumpCsvConfig.CsvSourceCodeFileDirectory, Path.GetFileName(f))));
            }
            FileUtil.DeleteFileOrDirectory(f);
        }
        AssetDatabase.Refresh();
    }

    public static void CreateAllCsvBinaryFiles() {
        try {
            foreach(string f in JumpCsvEditorHelper.ListAllCsvFilesInCsvFolder()) {
                // get class name 
                string className = JumpCsvEditorHelper.GetCsvDataClassName(f);
                Type classType = CsvHelper.GetType("JumpCSV." + className);
                System.Object obj = System.Reflection.Assembly.GetExecutingAssembly().CreateInstance(className);
                MethodInfo method = classType.GetMethod("Read");
                method.Invoke(obj, new System.Object[]{f});

                MethodInfo serializeMethod = classType.GetMethod("Serialize");
                string binaryFileName = JumpCsvEditorHelper.PathCombine(JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvBinDataDirectory), JumpCsvEditorHelper.GetCsvDataBinaryFileName(f));
                Debug.Log("Create binary csv file " + binaryFileName);
                serializeMethod.Invoke(obj, new System.Object[]{binaryFileName});
            }            
        } catch(Exception e) {
            Debug.LogError("Error: " + e.ToString());
            JumpCsvEditorHelper.CleanAllFiles();
            throw new Exception("Create binary file error");
        }
    }

    private static CodeTypeDeclaration BuildCsvManagerClass(string targetCsvFolder, string[] csvFiles ) {
        CodeTypeDeclaration csvManagerClass = new CodeTypeDeclaration("CsvManager");
        csvManagerClass.IsClass        = true;
        csvManagerClass.TypeAttributes = TypeAttributes.Public;

        csvManagerClass.Members.Add(new CodeSnippetTypeMember("public static bool isInit = false;"));
        csvManagerClass.Members.Add(new CodeSnippetTypeMember("public static bool isAssetBundle = true;"));

        CodeMemberMethod initMethod = new CodeMemberMethod();
        initMethod.Name = "Init";
        initMethod.Parameters.Add( new CodeParameterDeclarationExpression("System.String", "prefix") );
        initMethod.Attributes = MemberAttributes.Public | MemberAttributes.Static;
                
        csvManagerClass.Members.Add(initMethod);

        initMethod.Statements.Add(new CodeSnippetExpression("if(isInit) return"));
        string resourcePath = JumpCsvEditorHelper.PathCombine(Application.dataPath, "Resources");
        foreach(var f in csvFiles) {
            string path = targetCsvFolder + Path.GetFileNameWithoutExtension(f); 

            initMethod.Statements.Add( new CodeMethodInvokeExpression( 
                new CodeVariableReferenceExpression( JumpCsvEditorHelper.GetCsvDataClassName(f)),
                "Read",
                new CodeExpression[]{ new CodeSnippetExpression("prefix + " + "\"" + Path.GetFileNameWithoutExtension(f) + "\"")}
                ) );
        }
        initMethod.Statements.Add(new CodeSnippetExpression("isInit = true"));


        CodeMemberMethod foreachInitMethod = new CodeMemberMethod();
        foreachInitMethod.Name = "ForeachInit";
        foreachInitMethod.ReturnType = new CodeTypeReference(typeof(IEnumerable));
        foreachInitMethod.Attributes = MemberAttributes.Public | MemberAttributes.Static;
                
        csvManagerClass.Members.Add(foreachInitMethod);

        foreach(var f in csvFiles) {
            string path = Path.GetFileNameWithoutExtension(f); 
            foreachInitMethod.Statements.Add( new CodeMethodInvokeExpression( 
                new CodeVariableReferenceExpression( JumpCsvEditorHelper.GetCsvDataClassName(f)),
                "Read",
                new CodeExpression[]{ new CodePrimitiveExpression(path)}
                ) );
            foreachInitMethod.Statements.Add(new CodeSnippetExpression("yield return null"));
        }
        foreachInitMethod.Statements.Add(new CodeSnippetExpression("isInit = true"));


        CodeMemberMethod serializeMethod = new CodeMemberMethod();
        serializeMethod.Name = "Serialize";
        serializeMethod.Attributes = MemberAttributes.Public | MemberAttributes.Static;
        serializeMethod.Parameters.Add( new CodeParameterDeclarationExpression("System.String", "prefix") );
        csvManagerClass.Members.Add(serializeMethod);

        serializeMethod.Statements.Add(new CodeSnippetExpression("Init(prefix)"));
        foreach(var f in csvFiles) {
            string dataPath = JumpCsvEditorHelper.PathCombine("Assets", JumpCsvConfig.CsvBinDataDirectory);
            string binFileName = Path.GetFileNameWithoutExtension(f) + ".bytes";
            string path = JumpCsvEditorHelper.PathCombine(dataPath, binFileName); 

            serializeMethod.Statements.Add( new CodeMethodInvokeExpression( 
                new CodeVariableReferenceExpression( JumpCsvEditorHelper.GetCsvDataClassName(f)),
                "Serialize",
                new CodeExpression[]{ new CodePrimitiveExpression(path)}
                ) );
        }

        CodeMemberMethod deserializeMethod = new CodeMemberMethod();
        deserializeMethod.Name = "Deserialize";
        deserializeMethod.Attributes = MemberAttributes.Public | MemberAttributes.Static;
                
        csvManagerClass.Members.Add(deserializeMethod);

        deserializeMethod.Statements.Add(new CodeSnippetExpression("if(isInit) return"));
        foreach(var f in csvFiles) {
            string csvBinPath = JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvBinDataDirectory);
            string fileWithoutExtension = Path.GetFileNameWithoutExtension(f);
            string path = JumpCsvEditorHelper.MakeRelativePath(resourcePath, JumpCsvEditorHelper.PathCombine(csvBinPath, fileWithoutExtension)); 

            deserializeMethod.Statements.Add( new CodeMethodInvokeExpression( 
                new CodeVariableReferenceExpression( JumpCsvEditorHelper.GetCsvDataClassName(f)),
                "Deserialize",
                new CodeExpression[]{ new CodePrimitiveExpression(path), new CodeSnippetExpression("isAssetBundle")}
                ) );
        }
        deserializeMethod.Statements.Add(new CodeSnippetExpression("isInit = true"));

        CodeMemberMethod foreachDeserializeMethod = new CodeMemberMethod();
        foreachDeserializeMethod.ReturnType = new CodeTypeReference(typeof(IEnumerable));
        foreachDeserializeMethod.Name = "ForeachDeserialize";
        foreachDeserializeMethod.Attributes = MemberAttributes.Public | MemberAttributes.Static;
                
        csvManagerClass.Members.Add(foreachDeserializeMethod);

        foreach(var f in csvFiles) {
            string csvBinPath = JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvBinDataDirectory);
            string fileWithoutExtension = Path.GetFileNameWithoutExtension(f);
            string path = JumpCsvEditorHelper.MakeRelativePath(resourcePath, JumpCsvEditorHelper.PathCombine(csvBinPath, fileWithoutExtension)); 

            foreachDeserializeMethod.Statements.Add( new CodeMethodInvokeExpression( 
                new CodeVariableReferenceExpression( JumpCsvEditorHelper.GetCsvDataClassName(f)),
                "Deserialize",
                new CodeExpression[]{ new CodePrimitiveExpression(path), new CodeSnippetExpression("isAssetBundle")}
                ) );
            foreachDeserializeMethod.Statements.Add(new CodeSnippetExpression("yield return null"));
        }
        foreachDeserializeMethod.Statements.Add(new CodeSnippetExpression("isInit = true"));

        // if(JumpCsvConfig.CsvSourceCodeFileDirectory.Substring("Resources/") == 0 ) { // if csv files save in the Resources folder
        //     Path.GetPathRoot();
        // }
        // }
        // CodeMemberMethod initCsvMethod = new CodeMemberMethod();
        // initCsvMethod.Name = "InitCsv";
        // initCsvMethod.Attributes = MemberAttributes.Public | MemberAttributes.Static;
                
        // csvManagerClass.Members.Add(initCsvMethod);

        return csvManagerClass;
    }

    private static string CreateCsvManagerSourceFile(string targetCsvPath, string defaultCsvPath) {
        allRecords.Clear();
        foreach(var f in JumpCsvEditorHelper.ListAllCsvFilesInCsvFolder()) {
            string path = targetCsvPath + Path.GetFileNameWithoutExtension(f);// JumpCsvEditorHelper.MakeRelativePath(resourcePath, f); 
            CsvSpreadSheet sheet = new CsvSpreadSheet(path.Replace(".csv",""), true);
            if(sheet.Kind == CsvSpreadSheet.EKind.DicRecord) {
                foreach(var t in sheet.Records) {
                    foreach(var k in allRecords) {
                        if(k.KeyName == t.KeyName) {
                            throw new Exception("Duplicate Key Name " + t.KeyName);
                        }
                    }
                    allRecords.Add(t);
                }
            }
        }

        // add localization csv
        CsvSpreadSheet sheet2 = new CsvSpreadSheet("Assets/Build/Localization/Localization", true);
        foreach(var t in sheet2.Records) {
            foreach(var k in allRecords) {
                if(k.KeyName == t.KeyName) {
                    throw new Exception("Duplicate Key Name " + t.KeyName);
                }
            }
            allRecords.Add(t);
        }

        CodeCompileUnit codeUnit = new CodeCompileUnit();
        CodeNamespace   jumpCsvNS = new CodeNamespace("JumpCSV");

        // add import directives used by the namespace.
        jumpCsvNS.Imports.Add(new CodeNamespaceImport("System"));
        jumpCsvNS.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));

        codeUnit.Namespaces.Add(jumpCsvNS);

        // add csv manager class
        jumpCsvNS.Types.Add(BuildCsvManagerClass(targetCsvPath, JumpCsvEditorHelper.ListAllCsvFilesInCsvFolder()));
        // add csv itme type enum 
        jumpCsvNS.Types.Add(BuildRecordIdDeclaration("ERId", allRecords));

        string fileName =  JumpCsvEditorHelper.PathCombine(Application.temporaryCachePath, JumpCsvConfig.CsvManagerFileName);
        GenerateCSharpCode(fileName, codeUnit);
        AssetDatabase.Refresh();
        return fileName;
    }

    private static List<string> CreateAllCsvReadClassSourceFiles(string targetCsvPath, string defaultCsvPath) {
        List<string> files = new List<string>();
        foreach(var f in JumpCsvEditorHelper.ListAllCsvFilesInCsvFolder()) {
            string path = targetCsvPath + Path.GetFileNameWithoutExtension(f);
            CsvSpreadSheet sheet = new CsvSpreadSheet(path.Replace(".csv",""), true);
            files.Add(CreateCsvDataClassSourceFile(sheet));
        }
        AssetDatabase.Refresh();
        return files;
    }

    public static string CreateCsvDataClassSourceFile2(CsvSpreadSheet sheet) {
        CodeCompileUnit codeUnit = new CodeCompileUnit();
        CodeNamespace   jumpCsvNamespace = new CodeNamespace("JumpCSV");

        // add import directives used by the namespace.
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System.IO"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System.Collections"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System.Runtime.Serialization.Formatters.Binary"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("UnityEngine"));
        
        codeUnit.Namespaces.Add(jumpCsvNamespace);
        jumpCsvNamespace.Types.Add(BuildCsvRecordStructDeclaration(sheet));
        jumpCsvNamespace.Types.Add(BuildCsvDataClassDeclarationLocalization(sheet));
        
        string csFileName = JumpCsvEditorHelper.PathCombine(Application.temporaryCachePath,  
                JumpCsvEditorHelper.GetCsvDataClassName(sheet.CsvFileName) + ".cs");
        GenerateCSharpCode( csFileName, codeUnit);
        return csFileName;
    }

    public static string CreateCsvDataClassSourceFile(CsvSpreadSheet sheet) {
        CodeCompileUnit codeUnit = new CodeCompileUnit();
        CodeNamespace   jumpCsvNamespace = new CodeNamespace("JumpCSV");

        // add import directives used by the namespace.
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System.IO"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System.Collections"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System.Runtime.Serialization.Formatters.Binary"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("UnityEngine"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System.Security.Cryptography"));
        jumpCsvNamespace.Imports.Add(new CodeNamespaceImport("System.Text"));
        
        codeUnit.Namespaces.Add(jumpCsvNamespace);
        jumpCsvNamespace.Types.Add(BuildCsvRecordStructDeclaration(sheet));
        jumpCsvNamespace.Types.Add(BuildCsvDataClassDeclaration(sheet));
        
        string csFileName = JumpCsvEditorHelper.PathCombine(Application.temporaryCachePath,  
                JumpCsvEditorHelper.GetCsvDataClassName(sheet.CsvFileName) + ".cs");
        GenerateCSharpCode( csFileName, codeUnit);
        return csFileName;
    }

    private static CodeMemberMethod[] BuildAccessMethods(CsvSpreadSheet sheet) {
        List<CodeMemberMethod> result = new List<CodeMemberMethod>();
        foreach(var header in sheet.Header) {
            CodeMemberMethod method = new CodeMemberMethod();
            method.Attributes       = MemberAttributes.Public | MemberAttributes.Static;
            Type returnType         = header.Type;
            // method name
            if(returnType.IsArray) {
                method.Name = header.Name + "Array";
            }
            else {
                method.Name = header.Name;
            }

            // return type
            method.ReturnType = new CodeTypeReference(returnType);

            // parameters and return statement
            if(sheet.Kind == CsvSpreadSheet.EKind.ListRecord) {
                method.Parameters.Add(new CodeParameterDeclarationExpression(typeof(int) , "index"));
                method.Statements.Add(new CodeMethodReturnStatement( new CodeSnippetExpression(string.Format("Data[index].{0}", header.Name))));
            }
            else if(sheet.Kind == CsvSpreadSheet.EKind.DicRecord) {
                method.Parameters.Add(new CodeParameterDeclarationExpression(typeof(int), "recordId"));
                method.Statements.Add(new CodeMethodReturnStatement( new CodeSnippetExpression(string.Format("GetRecord(recordId).{0}",header.Name))));
            }

            result.Add(method);


            if(returnType.IsArray) {
                CodeMemberMethod itemMethod = new CodeMemberMethod();

                itemMethod.Attributes       = MemberAttributes.Public | MemberAttributes.Static;
                itemMethod.ReturnType       = new CodeTypeReference(returnType.GetElementType());
                itemMethod.Name             = header.Name + "FromArray";
                if(sheet.Kind == CsvSpreadSheet.EKind.ListRecord) {
                    itemMethod.Parameters.Add(new CodeParameterDeclarationExpression(typeof(int), "index"));
                    itemMethod.Parameters.Add(new CodeParameterDeclarationExpression(typeof(int), "arrayIndex"));
                    itemMethod.Statements.Add(new CodeMethodReturnStatement(new CodeSnippetExpression(string.Format("Data[index].{0}[arrayIndex]", header.Name))));
                }
                else if(sheet.Kind == CsvSpreadSheet.EKind.DicRecord) {
                    itemMethod.Parameters.Add(new CodeParameterDeclarationExpression(typeof(int), "recordId"));
                    itemMethod.Parameters.Add(new CodeParameterDeclarationExpression(typeof(int), "arrayIndex"));
                    itemMethod.Statements.Add(new CodeMethodReturnStatement(new CodeSnippetExpression(string.Format("GetRecord(recordId).{0}[arrayIndex]", header.Name))));
                }
                result.Add(itemMethod);
            }
        }
        return result.ToArray();
    } 

    private static CodeTypeDeclaration BuildCsvDataClassDeclarationLocalization(CsvSpreadSheet sheet) {
        string className =   JumpCsvEditorHelper.GetCsvDataClassName(sheet.CsvFileName);
        CodeTypeDeclaration classType = new CodeTypeDeclaration(className);
        classType.IsClass = true;
        classType.TypeAttributes = TypeAttributes.Public;

        classType.Members.Add( new CodeSnippetTypeMember(
            string.Format("public static Dictionary<{0}, {1}> Data = new Dictionary<{0}, {1}>();", "int", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName))));
 
        classType.Members.Add( new CodeSnippetTypeMember(
            string.Format("public static {0} GetRecord(int id)", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName)))); 
        classType.Members.Add( new CodeSnippetTypeMember(
@"{ 
    if(Data.ContainsKey(id)) {
            return Data[id];
        }
        else {
            throw new Exception(""Can not find record by id "" + id);
        }
    }"));

        classType.Members.Add(new CodeSnippetTypeMember(
    @"public static void Serialize(string filename) {
        BinaryFormatter formatter = new BinaryFormatter();
        Stream stream = new FileStream(filename, FileMode.OpenOrCreate, FileAccess.Write, FileShare.None);
        formatter.Serialize(stream, Data);
        stream.Flush();
        stream.Close();
    }"));


        classType.Members.Add(new CodeSnippetTypeMember(
    @"public static void Deserialize(string filename, bool isAssetBundle = false) {
        TextAsset textAsset = null;
        if(isAssetBundle && AssetBundleMgr.ContainsFile(filename, ""bytes"")) {
            textAsset = AssetBundleMgr.Load(filename, ""bytes"") as TextAsset;
        }
        else {
            textAsset = Resources.Load(filename) as TextAsset;
        }
        RecordIdValue.Clear();
        IdRecordValue.Clear();
        Init();
        Init2();
        BinaryFormatter formatter = new BinaryFormatter();
        Stream stream = new MemoryStream(textAsset.bytes);
        " +
        string.Format("Data = formatter.Deserialize(stream) as Dictionary<int, {0}>;", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName))));

        classType.Members.Add(new CodeSnippetTypeMember(
@"    stream.Close();
    }"));

        CodeMemberField dicData = new CodeMemberField("Dictionary<int, string>",  "RecordIdValue");
        dicData.Attributes = MemberAttributes.Static | MemberAttributes.Public;
        String intiString = "new Dictionary<int, string>()";
        dicData.InitExpression  =  new CodeSnippetExpression(intiString);

        classType.Members.Add(dicData);



        // add init
        StringBuilder intiStringBuild = new StringBuilder(1024);
        foreach(var t in sheet.Records) {
            intiStringBuild.Append(string.Format("{2}             RecordIdValue.Add({0},{1});", t.KeyValue, "\""+t.KeyName+"\"", Environment.NewLine));
            //intiStringBuild.Append(string.Format("{2}            {{{0,-3}, {1,-30}}},", t.KeyValue,  "\""+t.KeyName+"\"", Environment.NewLine));
        }


        classType.Members.Add(new CodeSnippetTypeMember(
    "public static void Init() {\n" + intiStringBuild.ToString() + "\n}"
        ));

        //intiStringBuild.Append("new Dictionary<int, string>() {");
 
        StringBuilder intiStringBuild2 = new StringBuilder(1024);
        foreach(var t in sheet.Records) {
            intiStringBuild2.Append(string.Format("{2}             IdRecordValue.Add({0},{1});", "\""+t.KeyName+"\"", t.KeyValue, Environment.NewLine));
            //intiStringBuild.Append(string.Format("{2}            {{{0,-3}, {1,-30}}},", t.KeyValue,  "\""+t.KeyName+"\"", Environment.NewLine));
        }

        classType.Members.Add(new CodeSnippetTypeMember(
    "public static void Init2() {\n" + intiStringBuild2.ToString() + "\n}"
        ));


        dicData = new CodeMemberField("Dictionary<string, int>",  "IdRecordValue");
        dicData.Attributes = MemberAttributes.Static | MemberAttributes.Public;
        intiString = "new Dictionary<string, int>()";
        dicData.InitExpression  =  new CodeSnippetExpression(intiString);

        classType.Members.Add(dicData);

        foreach(var method in BuildAccessMethods(sheet)) {
            classType.Members.Add(method);
        }

        // add check sum
        classType.Members.Add( new CodeSnippetTypeMember(string.Format("public static int mHashCode = {0};", sheet.CalculateHashCode())));
        
        // add read method
        classType.Members.Add(BuildReadMethodLocalization(sheet));
        
        //classType.Members.Add(CreateSerializeMethod(sheet));
        //classType.Members.Add(BuildDeserializeMethod(sheet));

        return classType;           
    }


    private static CodeTypeDeclaration BuildCsvDataClassDeclaration(CsvSpreadSheet sheet) {
        string className =   JumpCsvEditorHelper.GetCsvDataClassName(sheet.CsvFileName);
        CodeTypeDeclaration classType = new CodeTypeDeclaration(className);
        classType.IsClass = true;
        classType.TypeAttributes = TypeAttributes.Public;

        if(sheet.Kind == CsvSpreadSheet.EKind.DicRecord) {

            classType.Members.Add( new CodeSnippetTypeMember(
                string.Format("public static Dictionary<{0}, {1}> Data = new Dictionary<{0}, {1}>();", "int", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName))));

            classType.Members.Add( new CodeSnippetTypeMember(
                string.Format("public static {0} GetRecord(int id)", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName))));
            classType.Members.Add( new CodeSnippetTypeMember(
@"{ 
        if(Data.ContainsKey(id)) {
                return Data[id];
            }
            else {
                throw new Exception(""Can not find record by id "" + id);
            }
        }"));

            classType.Members.Add(new CodeSnippetTypeMember(
        @"public static void Serialize(string filename) {
            BinaryFormatter formatter = new BinaryFormatter();
            Stream stream = new FileStream(filename, FileMode.OpenOrCreate, FileAccess.Write, FileShare.None);
            MemoryStream mstream = new MemoryStream();
            formatter.Serialize(mstream, Data);
            byte[] mbyte = mstream.ToArray();
            byte[] tmp = new byte[mbyte.Length];
            CsvHelper.Encode(mbyte, 0, tmp, 0, tmp.Length, ASCIIEncoding.ASCII.GetBytes(""ABCDEFG2""));
            stream.Write(tmp, 0, tmp.Length);
            mstream.Close();
            stream.Close();
        }"));


            classType.Members.Add(new CodeSnippetTypeMember(
        @"public static void Deserialize(string filename, bool isAssetBundle = false) {
            TextAsset textAsset = null;
            if(isAssetBundle && AssetBundleMgr.ContainsFile(filename, ""bytes"")) {
                textAsset = AssetBundleMgr.Load(filename, ""bytes"") as TextAsset;
            }
            else {
                textAsset = Resources.Load(filename) as TextAsset;
            }
            BinaryFormatter formatter = new BinaryFormatter();
            MemoryStream mstream = new MemoryStream();
            byte[] tmp = new byte[textAsset.bytes.Length];
            CsvHelper.Encode(textAsset.bytes, 0, tmp, 0, tmp.Length, ASCIIEncoding.ASCII.GetBytes(""ABCDEFG2""));
            mstream.Write(tmp, 0, tmp.Length);
            mstream.Position = 0;
            " +
            string.Format("Data = formatter.Deserialize(mstream) as Dictionary<int, {0}>;", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName))));

            classType.Members.Add(new CodeSnippetTypeMember(
@"    mstream.Close();    
        }"));
            classType.Members.Add(BuildRecordIdValueDictinaroy(sheet));
            classType.Members.Add(BuildRecordValue2IdDictinaroy(sheet));
            // add record type value dictionary
        }
        else if(sheet.Kind == CsvSpreadSheet.EKind.ListRecord) {
            classType.Members.Add(new CodeSnippetTypeMember(string.Format("public static List<{0}> Data = new List<{0}>();", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName))));
            classType.Members.Add( new CodeSnippetTypeMember(
                string.Format("public static {0} GetRecord(int index)", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName)))); 
            classType.Members.Add( new CodeSnippetTypeMember(
@"{ 
        if(Data.Count >= index) {
                return Data[index];
            }
            else {
                throw new Exception(""Can not find record by index "" + index);
            }
        }"));

            classType.Members.Add(new CodeSnippetTypeMember(
        @"public static void Serialize(string filename) {
            BinaryFormatter formatter = new BinaryFormatter();
            Stream stream = new FileStream(filename, FileMode.OpenOrCreate, FileAccess.Write, FileShare.None);
            MemoryStream mstream = new MemoryStream();
            formatter.Serialize(mstream, Data);
            byte[] mbyte = mstream.ToArray();
            byte[] tmp = new byte[mbyte.Length];
            CsvHelper.Encode(mbyte, 0, tmp, 0, tmp.Length, ASCIIEncoding.ASCII.GetBytes(""ABCDEFG2""));
            stream.Write(tmp, 0, tmp.Length);
            mstream.Close();
            stream.Close();
        }"));


            classType.Members.Add(new CodeSnippetTypeMember(
        @"public static void Deserialize(string filename, bool isAssetBundle = false) {
            TextAsset textAsset = null;
            if(isAssetBundle && AssetBundleMgr.ContainsFile(filename, ""bytes"")) {
                textAsset = AssetBundleMgr.Load(filename, "".bytes"") as TextAsset;
            }
            else {
                textAsset = Resources.Load(filename) as TextAsset;
            }
            BinaryFormatter formatter = new BinaryFormatter();
            MemoryStream mstream = new MemoryStream();
            byte[] tmp = new byte[textAsset.bytes.Length];
            CsvHelper.Encode(textAsset.bytes, 0, tmp, 0, tmp.Length, ASCIIEncoding.ASCII.GetBytes(""ABCDEFG2""));
            mstream.Write(tmp, 0, tmp.Length);
            mstream.Position = 0;
            " +
            string.Format("Data = formatter.Deserialize(mstream) as List<{0}>;", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName))));

            classType.Members.Add(new CodeSnippetTypeMember(
@"    mstream.Close();    
        }"));
        }


        foreach(var method in BuildAccessMethods(sheet)) {
            classType.Members.Add(method);
        }

        // add check sum
        classType.Members.Add( new CodeSnippetTypeMember(string.Format("public static int mHashCode = {0};", sheet.CalculateHashCode())));
        
        // add read method
        classType.Members.Add(BuildReadMethod(sheet));
        
        //classType.Members.Add(CreateSerializeMethod(sheet));
        //classType.Members.Add(BuildDeserializeMethod(sheet));

        return classType;        
    }

    private static CodeMemberField BuildRecordIdValueDictinaroy(CsvSpreadSheet sheet) {
        CodeMemberField dicData = new CodeMemberField("readonly Dictionary<int, string>",  "RecordIdValue");
        dicData.Attributes = MemberAttributes.Static | MemberAttributes.Public;
        StringBuilder intiString = new StringBuilder(1024);
        intiString.Append("new Dictionary<int, string>() {");
        foreach(var t in sheet.Records) {
            intiString.Append(string.Format("{2}            {{{0,-3}, {1,-30}}},", t.KeyValue,  "\""+t.KeyName+"\"", Environment.NewLine));
        }
        intiString.Append(Environment.NewLine+"        }");

        dicData.InitExpression  =  new CodeSnippetExpression( intiString.ToString());
        return dicData;
    }

    private static CodeMemberField BuildRecordValue2IdDictinaroy(CsvSpreadSheet sheet) {
        CodeMemberField dicData = new CodeMemberField("readonly Dictionary<string, int>",  "IdRecordValue");
        dicData.Attributes = MemberAttributes.Static | MemberAttributes.Public;
        StringBuilder intiString = new StringBuilder(1024);
        intiString.Append("new Dictionary<string, int>() {");
        foreach(var t in sheet.Records) {
            intiString.Append(string.Format("{2}            {{{0,-30}, {1,-3}}},", "\""+t.KeyName+"\"", t.KeyValue, Environment.NewLine));
        }
        intiString.Append(Environment.NewLine+"        }");

        dicData.InitExpression  =  new CodeSnippetExpression( intiString.ToString());
        return dicData;
    }

    private static CodeMemberMethod CreateSerializeMethod(CsvSpreadSheet sheet) {
        CodeMemberMethod serializeMethod = new CodeMemberMethod();
        serializeMethod.Attributes = MemberAttributes.Public | MemberAttributes.Final | MemberAttributes.Static;
        serializeMethod.Name = "Serialize";
        serializeMethod.Parameters.Add(new CodeParameterDeclarationExpression(typeof(string), "fileName"));

        if(sheet.Kind == CsvSpreadSheet.EKind.DicRecord) {
            CodeVariableDeclarationStatement listValue = new CodeVariableDeclarationStatement(string.Format("List<{0}>", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName)), "listValue");
            listValue.InitExpression = new CodeObjectCreateExpression(string.Format("List<{0}>", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName)), new CodeSnippetExpression("Data.Values"));
            serializeMethod.Statements.Add(listValue);            

            CodeMethodInvokeExpression callSerilizeCsvFile = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("CsvHelper"), "SerializeCsvFile", 
                new CodeExpression[]{new CodeVariableReferenceExpression("listValue"), new CodeVariableReferenceExpression("fileName")});
            serializeMethod.Statements.Add(callSerilizeCsvFile);

        }
        else if(sheet.Kind == CsvSpreadSheet.EKind.ListRecord) {
            CodeMethodInvokeExpression callSerilizeCsvFile = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("CsvHelper"), "SerializeCsvFile", 
                new CodeExpression[]{new CodeVariableReferenceExpression("Data"), new CodeVariableReferenceExpression("fileName")});
            serializeMethod.Statements.Add(callSerilizeCsvFile);

        }
        return serializeMethod;
    }

    private static CodeMemberMethod BuildDeserializeMethod(CsvSpreadSheet sheet) {
        CodeMemberMethod readMethod = new CodeMemberMethod();
        readMethod.Attributes = MemberAttributes.Public | MemberAttributes.Final | MemberAttributes.Static;
        readMethod.Name       = "Deserialize";
        readMethod.Parameters.Add(new CodeParameterDeclarationExpression(typeof(string), "fileName"));
        readMethod.Parameters.Add(new CodeParameterDeclarationExpression(typeof(bool),   "isAssetBundle"));

        readMethod.Statements.Add(new CodeSnippetExpression("Data.Clear()")); 
        string declaraList = string.Format("List<{0}> listValue = CsvHelper.DeserializeCsvFile<{0}>(fileName);", JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName));
        readMethod.Statements.Add(new CodeSnippetExpression(declaraList));
        if(sheet.Kind == CsvSpreadSheet.EKind.DicRecord) {
            string forStatement = string.Format(@"
            for(int i = 0; (i < listValue.Count); i++) {{ 
                int keyValue = listValue[i].{0};
                Data.Add(keyValue, listValue[i]);
            }}",CsvSpreadSheet.HeaderValueLiteral);
            readMethod.Statements.Add(new CodeSnippetExpression(forStatement));
        }
        else if(sheet.Kind == CsvSpreadSheet.EKind.ListRecord) {
            string assignState = @"Data = listValue;";
            readMethod.Statements.Add(new CodeSnippetExpression(assignState));
        }
        return readMethod;
    }

    private static CodeMemberMethod BuildReadMethodLocalization(CsvSpreadSheet sheet) {
        CodeMemberMethod readMethod = new CodeMemberMethod();
        readMethod.Attributes = MemberAttributes.Public | MemberAttributes.Final | MemberAttributes.Static;
        readMethod.Name       = "Read";
        readMethod.Parameters.Add(new CodeParameterDeclarationExpression(typeof(string), "fileName"));

        // CsvSpreadSheet sheet = new CsvSpreadSheet(fileName);
        CodeMethodInvokeExpression callClearData = new  CodeMethodInvokeExpression(new CodeVariableReferenceExpression("Data"),  "Clear");
        readMethod.Statements.Add(callClearData);

        CodeMethodInvokeExpression callClearData2 = new  CodeMethodInvokeExpression(new CodeVariableReferenceExpression("RecordIdValue"),  "Clear");
        readMethod.Statements.Add(callClearData2);

        CodeMethodInvokeExpression callClearData3 = new  CodeMethodInvokeExpression(new CodeVariableReferenceExpression("IdRecordValue"),  "Clear");
        readMethod.Statements.Add(callClearData3);

        readMethod.Statements.Add( new CodeSnippetExpression(@"Init()"));
        readMethod.Statements.Add( new CodeSnippetExpression(@"Init2()"));

        CodeVariableDeclarationStatement declaraSheet = new CodeVariableDeclarationStatement(typeof(CsvSpreadSheet), "sheet");
        declaraSheet.InitExpression = new CodeObjectCreateExpression(typeof(CsvSpreadSheet), new CodeExpression[] {new CodeVariableReferenceExpression("fileName"), new CodePrimitiveExpression(true)});
        readMethod.Statements.Add(declaraSheet);

        // for statment
        CodeIterationStatement forStatement = new CodeIterationStatement();

        forStatement.InitStatement = new CodeVariableDeclarationStatement( typeof(int), "i", new CodePrimitiveExpression(0));

        forStatement.TestExpression = new CodeBinaryOperatorExpression(new CodeVariableReferenceExpression("i"), CodeBinaryOperatorType.LessThan, new CodeSnippetExpression("sheet.Records.Count"));

        forStatement.IncrementStatement = new CodeAssignStatement( new CodeVariableReferenceExpression("i"), new CodeBinaryOperatorExpression( 
        new CodeVariableReferenceExpression("i"), CodeBinaryOperatorType.Add, new CodePrimitiveExpression(1) ));

        forStatement.Statements.Add( new CodeVariableDeclarationStatement( JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName), "record", new CodeObjectCreateExpression(JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName), new CodeExpression[]{})));
        foreach(CodeStatement t in BuildReadStatements(sheet)) {
            forStatement.Statements.Add(t);
        }

        // add new record to list or dictionary
        if(sheet.Kind == CsvSpreadSheet.EKind.DicRecord) {
            CodeVariableDeclarationStatement keyValueDeclaration = new CodeVariableDeclarationStatement(typeof(int), "keyValue");
            keyValueDeclaration.InitExpression = new CodeSnippetExpression(@"sheet.GetRecord(i).KeyValue");
            forStatement.Statements.Add(keyValueDeclaration);
            forStatement.Statements.Add(new CodeSnippetExpression(@"Data.Add(keyValue, record);"));
        }
        else if(sheet.Kind == CsvSpreadSheet.EKind.ListRecord){
            forStatement.Statements.Add(new CodeSnippetExpression(@"Data.Add(record)"));
        }
        
        readMethod.Statements.Add(forStatement);
        return readMethod;
    }    

    private static CodeMemberMethod BuildReadMethod(CsvSpreadSheet sheet) {
        CodeMemberMethod readMethod = new CodeMemberMethod();
        readMethod.Attributes = MemberAttributes.Public | MemberAttributes.Final | MemberAttributes.Static;
        readMethod.Name       = "Read";
        readMethod.Parameters.Add(new CodeParameterDeclarationExpression(typeof(string), "fileName"));

        // CsvSpreadSheet sheet = new CsvSpreadSheet(fileName);
        CodeMethodInvokeExpression callClearData = new  CodeMethodInvokeExpression(new CodeVariableReferenceExpression("Data"),  "Clear");
        readMethod.Statements.Add(callClearData);

        CodeVariableDeclarationStatement declaraSheet = new CodeVariableDeclarationStatement(typeof(CsvSpreadSheet), "sheet");
        declaraSheet.InitExpression = new CodeObjectCreateExpression(typeof(CsvSpreadSheet), new CodeExpression[] {new CodeVariableReferenceExpression("fileName"), new CodePrimitiveExpression(true)});
        readMethod.Statements.Add(declaraSheet);

        // for statment
        CodeIterationStatement forStatement = new CodeIterationStatement();

        forStatement.InitStatement = new CodeVariableDeclarationStatement( typeof(int), "i", new CodePrimitiveExpression(0));

        forStatement.TestExpression = new CodeBinaryOperatorExpression(new CodeVariableReferenceExpression("i"), CodeBinaryOperatorType.LessThan, new CodeSnippetExpression("sheet.Records.Count"));

        forStatement.IncrementStatement = new CodeAssignStatement( new CodeVariableReferenceExpression("i"), new CodeBinaryOperatorExpression( 
        new CodeVariableReferenceExpression("i"), CodeBinaryOperatorType.Add, new CodePrimitiveExpression(1) ));

        forStatement.Statements.Add( new CodeVariableDeclarationStatement( JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName), "record", new CodeObjectCreateExpression(JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName), new CodeExpression[]{})));
        foreach(CodeStatement t in BuildReadStatements(sheet)) {
            forStatement.Statements.Add(t);
        }

        // add new record to list or dictionary
        if(sheet.Kind == CsvSpreadSheet.EKind.DicRecord) {
            CodeVariableDeclarationStatement keyValueDeclaration = new CodeVariableDeclarationStatement(typeof(int), "keyValue");
            keyValueDeclaration.InitExpression = new CodeSnippetExpression(@"sheet.GetRecord(i).KeyValue");
            forStatement.Statements.Add(keyValueDeclaration);
            forStatement.Statements.Add(new CodeSnippetExpression(@"Data.Add(keyValue, record);"));
        }
        else if(sheet.Kind == CsvSpreadSheet.EKind.ListRecord){
            forStatement.Statements.Add(new CodeSnippetExpression(@"Data.Add(record)"));
        }
        
        readMethod.Statements.Add(forStatement);
        return readMethod;
    }

    private static CodeStatement[] BuildReadStatements(CsvSpreadSheet sheet) {
        List<CsvSpreadSheet.HeaderRecord> headerList = sheet.Header;
        CodeStatement[] result = new CodeStatement[headerList.Count];
        for(int i = 0; i < headerList.Count; i++) {
            if(headerList[i].Name == "_ID") {

                CodeSnippetStatement snippet = new CodeSnippetStatement("                record._ID = CsvValueConverter.ReadValueDicValue(sheet, i, \"_VALUE\");"); 
                result[i] = snippet;
            }
            else {
                CodeAssignStatement assign = new CodeAssignStatement();
                assign.Left  = new CodeFieldReferenceExpression(new CodeVariableReferenceExpression("record"), headerList[i].Name);
                assign.Right = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("CsvValueConverter"),  CsvHelper.GetReadColumnFunctionName(headerList[i].TypeLiteral), 
                    new CodeExpression[]{ new CodeVariableReferenceExpression("sheet"), new CodeVariableReferenceExpression("i"), new CodePrimitiveExpression(headerList[i].Name)});                
                result[i] = assign;
            }
        }
        return result;
    }

    private static CodeTypeDeclaration BuildCsvRecordStructDeclaration(CsvSpreadSheet sheet) {
        string structName =  JumpCsvEditorHelper.GetCsvDataStructName(sheet.CsvFileName);
        CodeTypeDeclaration structType = new CodeTypeDeclaration(structName);
        structType.IsStruct = true;
        structType.TypeAttributes = TypeAttributes.Public;
        structType.CustomAttributes.Add(new CodeAttributeDeclaration("Serializable"));

        List<CsvSpreadSheet.HeaderRecord> headerList = sheet.Header;
        foreach(var t in headerList) {
            if((t.TypeLiteral == "id" || t.TypeLiteral == "id[]" || t.TypeLiteral == "loc" || t.TypeLiteral == "loc[]") && t.Name != CsvSpreadSheet.HeaderIdNameLiteral) {
                int index = t.Index;
                for(int i = 1; i < sheet.mReader.Height; i++) {
                    var val = sheet.mReader.ReadCell(i , index);
                    if(!string.IsNullOrEmpty(val)) {
                        if(allRecords.Exists(x=>x.KeyName == val) == false && val != "None") {
                            throw new Exception("Can not parse id " + val + " at file " + sheet.CsvFileName);
                        }
                    }
                }
            }
            structType.Members.Add(new CodeSnippetTypeMember(string.Format("public {0,-10} {1};",t.Type.Name, t.Name)));
        }
        structType.Members.Add(new CodeSnippetTypeMember(Environment.NewLine + "\t"));
        return structType;
    }

    private static CodeTypeDeclaration BuildCsvDataClassDeclaration(string name, string[] filedName, Type[] typeLst) {
        CodeTypeDeclaration classType = new CodeTypeDeclaration(name);
        classType.IsClass = true;
        classType.TypeAttributes = TypeAttributes.Public;
        for(int i = 0; i < filedName.Length; i++) {
            CodeMemberField newField = new CodeMemberField(typeLst[i], filedName[i]);
            newField.Attributes = MemberAttributes.Public;
            classType.Members.Add(newField);
        }
        return classType;
    }

    private static CodeTypeDeclaration BuildRecordIdDeclaration(string name, List<CsvSpreadSheet.Record> recordLst ) {
        CodeTypeDeclaration enumType = new CodeTypeDeclaration(name);
        enumType.IsClass = true;
        enumType.TypeAttributes = TypeAttributes.Public;
        enumType.Members.Add(new CodeSnippetTypeMember(string.Format("public const int {0,-20} = {1};", "None", 0)));

        for(int i = 0; i < recordLst.Count; i++) {
            enumType.Members.Add(new CodeSnippetTypeMember(string.Format("public const int {0,-20} = {1};", recordLst[i].KeyName, recordLst[i].KeyValue)));
        }
        enumType.Members.Add(new CodeSnippetTypeMember(Environment.NewLine + "\t"));
        return enumType;        
    }

}
