using UnityEngine;
using System;
using System.IO;
using System.Collections.Generic;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Runtime.Serialization.Formatters.Binary;

namespace JumpCSV {
public static class CsvHelper {
    public static bool IsValidVariableName(string name) {
        Regex re = new Regex(@"^[a-zA-Z_#][a-zA-Z0-9_]*$");
        return re.IsMatch(name);
    }

    public static string GetReadColumnFunctionName(string typename) {
        return GetReadColumnFunctionName(GetCsvColumnTypeByName(typename), typename);
    }

    public static string GetReadColumnFunctionName(Type t, string typename) {
    	Type type = typeof(CsvValueConverter);
    	foreach(var m in type.GetMethods(BindingFlags.Public | BindingFlags.Static)) {
    		foreach( var attr in m.GetCustomAttributes(false)) {
    			if(attr is CsvColumnTypeAttributes) {
    				CsvColumnTypeAttributes csvAttr = attr as CsvColumnTypeAttributes;
    				if(t == csvAttr.mColumnType && csvAttr.mTypeName == typename) {
    					return m.Name;
    				}
    			} 
    		}
    	}
    	throw new Exception("Can not found function to read type " + t.ToString());
    }

    public static Type GetCsvColumnTypeByName(string name) {
    	Type type = typeof(CsvValueConverter);
    	foreach(var m in type.GetMethods(BindingFlags.Public | BindingFlags.Static)) {
    		foreach( var attr in m.GetCustomAttributes(false)) {
    			if(attr is CsvColumnTypeAttributes) {
    				CsvColumnTypeAttributes csvAttr = attr as CsvColumnTypeAttributes;
    				if(name == csvAttr.mTypeName) {
    					return csvAttr.mColumnType;
    				}
    			} 
    		}
    	}
        return null;
    }

    public static void Encode(byte[] src, int srcOffset, byte[] dst, int dstOffset, int size, byte[] cipher) {
        byte[] _s = new byte[256];
        for(int i = 0; i < 256; i++) {
            _s[i] = (byte)i;
        }
        for(int i = 0, j = 0; i < 256; i++) {
            j = (byte)((j + _s[i] + cipher[i % cipher.Length]) % 256);
            byte t = _s[i];
            _s[i] = _s[j];
            _s[j] = t;
        }
        int _i = 0;
        int _j = 0;
        for(int i = 0; i < size; i++) {
            _i = (byte)((_i + 1) % 256);
            _j = (byte)((_j + _s[_i]) % 256);
            byte t = _s[_i];
            _s[_i] = _s[_j];
            _s[_j] = t;
            dst[dstOffset+i] = (byte)(src[srcOffset+i] ^ _s[(_s[_i] + _s[_j]) % 256]);
        }  
    }    

    public static Type GetType( string TypeName )
    {
     
        // Try Type.GetType() first. This will work with types defined
        // by the Mono runtime, in the same assembly as the caller, etc.
        var type = Type.GetType( TypeName );
     
        // If it worked, then we're done here
        if( type != null )
            return type;
     
        // If the TypeName is a full name, then we can try loading the defining assembly directly
        if( TypeName.Contains( "." ) )
        {
     
            // Get the name of the assembly (Assumption is that we are using 
            // fully-qualified type names)
            var assemblyName = TypeName.Substring( 0, TypeName.IndexOf( '.' ) );
     
            // Attempt to load the indicated Assembly
            var assembly = Assembly.Load( assemblyName );
            if( assembly == null )
                return null;
     
            // Ask that assembly to return the proper Type
            type = assembly.GetType( TypeName );
            if( type != null )
                return type;
     
        }
     
        // If we still haven't found the proper type, we can enumerate all of the 
        // loaded assemblies and see if any of them define the type
        var currentAssembly = Assembly.GetExecutingAssembly();
        var referencedAssemblies = currentAssembly.GetReferencedAssemblies();
        foreach( var assemblyName in referencedAssemblies )
        {
     
            // Load the referenced assembly
            var assembly = Assembly.Load( assemblyName );
            if( assembly != null )
            {
                // See if that assembly defines the named type
                type = assembly.GetType( TypeName );
                if( type != null )
                    return type;
            }
        }
     
        // The type just couldn't be found...
        return null;
     
    }

    public static string SerializeCsvFile(System.Object obj, string fileName) {
        string directory = Path.GetDirectoryName(fileName);
        if(!Directory.Exists(directory)) {
            Directory.CreateDirectory(directory);
        }

        using (Stream stream = File.Open(fileName, FileMode.Create))
        {
            BinaryFormatter bin = new BinaryFormatter();
            bin.Serialize(stream, obj);
        }
        return fileName;
    }

    public static List<T> DeserializeCsvFile<T>(string fileName) {
        try {
            TextAsset asset = Resources.Load(fileName) as TextAsset;
            if(asset==null) {
                Debug.Log("TextAsset is null pointer " + fileName.ToString());
            }
            Stream s = new MemoryStream(asset.bytes);
            if(s==null) {
                Debug.Log("stream is null pointer");
            }
            BinaryFormatter bin = new BinaryFormatter();
            List<T> result = (List<T>)bin.Deserialize(s);
            return result;            
        } catch(Exception s) {
            throw new Exception("Can not load binary file: " +"Asset/Resources/" + fileName + " " + s.ToString());
        }
    }
}
}
