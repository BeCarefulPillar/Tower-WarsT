using UnityEngine;
using System;
using System.IO;
using System.Collections.Generic;

namespace JumpCSV {
public class CsvSpreadSheet {

    static public string HeaderIdNameLiteral      = "_ID";
    static public string HeaderValueLiteral       = "_VALUE";
    static public string HeaderIndexLiteral       = "_INDEX";
    static public Type   HeaderIdNameType         = typeof(int);  
    static public Type   HeaderValueType          = typeof(int);
    static public Type   HeaderIndexType          = typeof(int);

    public enum EKind {
        None,
        ListRecord,
        DicRecord,
    }

    public class HeaderRecord {
        public string  Name;
        public string  TypeLiteral;
        public Type    Type;
        public int     Index;

        public HeaderRecord(string name, string typeStr, Type type, int index) {
            Name           = name;
            TypeLiteral    = typeStr;
            Index          = index;
            Type           = type;//CsvHelper.GetCsvColumnTypeByName(typeStr); 
        }

        public override string ToString() {
            return string.Format("{0} {1}");
        }
    }

    public class Record {
        public string      KeyName;   
        public int         KeyValue;
        public int         StartRow;
        public int         Height;
        public int         Index;
        public List<int>   HeaderContentLength = new List<int>();

        public Record(string keyName, string keyValue, int startRow, int height, int index) { 
            KeyName   = keyName;
            KeyValue  = CsvValueConverter.ParseInt(keyValue);
            Height    = height;
            Index     = index;
            StartRow  = startRow;
        }
    }


    public  List<HeaderRecord> Header        = new List<HeaderRecord>();
    public  List<Record>       Records       = new List<Record>();
    public  HashSet<int>       CommentColumn = new HashSet<int>();
    public  CsvReader          mReader       = new CsvReader();
    public  string             CsvFileName   {get; set;}
    private int                mWidth;
    private int                mHeight;
    public  EKind              Kind          {get;private set;}
    public  bool               dicWithoutValue = false;

    public CsvSpreadSheet(string fileName, bool isResourceLoad) {
        CsvFileName = fileName;
        if(isResourceLoad) {
            TextAsset asset = null;
#if UNITY_EDITOR
            asset = (TextAsset)UnityEditor.AssetDatabase.LoadAssetAtPath(fileName + ".csv", typeof(TextAsset));
            if(asset == null) {
                asset = (TextAsset)UnityEditor.AssetDatabase.LoadAssetAtPath("Assets/Build/CSV/Common/" + Path.GetFileNameWithoutExtension(fileName) + ".csv", typeof(TextAsset));                 
            }
#endif
            if(asset == null) {
                asset = Resources.Load(fileName) as TextAsset;
            }
            if(asset == null) throw new Exception("Can not load file from " + fileName.ToString());
            mReader.ReadFromString(asset.text);
        }
        else {
            mReader.Read(CsvFileName);
        }
        ReadHeader();
        ReadBody();
    }

    public int CalculateHashCode() {
        string val = "";
        if(Kind == EKind.ListRecord) {
            foreach(var h in Header) {
                val += h.Name + h.TypeLiteral;
            }
            return val.GetHashCode();
        }
        else if(Kind == EKind.DicRecord) {
            foreach(var h in Header) {
                val += h.Name + h.TypeLiteral;
            }
            foreach(var r in Records) {
                val += r.KeyName + r.KeyValue.ToString();
            }
            return val.GetHashCode();
        }
        throw new Exception("can not handle");
    }

    public CsvSpreadSheet(string content) {
        mReader.ReadFromString(content);
        ReadHeader();
        ReadBody();
    }

    public string GetBasicInfo() {
        return string.Format("Name: {0}\nKind: {1}\nRecord Count: {2}\n", CsvFileName, Kind, Records.Count);
    }
 
    public HeaderRecord  GetHeaderRecord(int index) {
        return Header[index];
    }

    public string GetBareName() {
        return Path.GetFileName(CsvFileName).Split(new char[]{'.'})[0];        
    }

    public HeaderRecord  GetHeaderRecord(string headerName) {
        int index = Header.FindIndex((x)=>{return x.Name == headerName;});
        return GetHeaderRecord(index);
    }

    public Record    GetRecord(string recordKeyName) {
        int index = Records.FindIndex((x) => {return x.KeyName == recordKeyName;});
        return GetRecord(index);
    }

    public Record    GetRecord(int index) {
        return Records[index];
    }

    private bool IsReservedColumnName(string name) {
        return name == HeaderIndexLiteral || name == HeaderValueLiteral || name == HeaderIdNameLiteral;
    }

    private void ReadHeader() {
        string[] headerInfo        = mReader.ReadLine(0);            

        if(headerInfo.Length < 1) {
            throw new CSVFileException(CsvFileName, "The header can not be empty");
        }

        // read header
        Header.Clear();
        mWidth = headerInfo.Length;
        for(int i = 0; i < mWidth; i++) {
            string[] tuple =  headerInfo[i].Split(new char[]{':'});
            if(tuple.Length == 1 && IsReservedColumnName(tuple[0])) {
                if(tuple[0] == HeaderIdNameLiteral) {
                    Header.Add(new HeaderRecord(tuple[0], "id", HeaderIdNameType, i));
                }
                else if(tuple[0] == HeaderValueLiteral) {
                    Header.Add(new HeaderRecord(tuple[0], "dicval", HeaderValueType, i));
                }
                else if(tuple[0] == HeaderIndexLiteral) {
                    Header.Add(new HeaderRecord(tuple[0], "int", HeaderIndexType, i));
                }
                else {
                    throw new CSVFileException(CsvFileName, i+1, 1, "Header name " + headerInfo[i] + " is not a valid name");
                }
            }
            else if(tuple.Length != 2){
                throw new CSVFileException(CsvFileName, i+1, 1, "Header name " + headerInfo[i] + " is not a valid name");
            }
            else {
                if( CsvHelper.IsValidVariableName(tuple[0])) {
                    Type type =  CsvHelper.GetCsvColumnTypeByName(tuple[1]);
                    if(type == null) {
                        throw new CSVFileException(CsvFileName, i+1, 1, "Can not recognize name of type " + tuple[1]);
                    }
                    if(tuple[0][0] == '#') {
                        CommentColumn.Add(i);
                    }
                    else {
                        Header.Add(new HeaderRecord(tuple[0], tuple[1], type, i));
                    }
                }
                else {
                    throw new CSVFileException(CsvFileName, i+1, 1, tuple[0] + " is not a valid column name. A valid column name for header must the uppercase and lowercase letters A through Z, the underscore _ and, except for the first character, the digits 0 through 9.");
                }                
            }
        }

        int duplicatedColumn = CheckDuplicatedColumnName();
        if(duplicatedColumn > -1) {
            throw new CSVFileException(CsvFileName, duplicatedColumn+1, 1, "Duplicated column name " + headerInfo[duplicatedColumn]);            
        }

        int idPos     =  Header.FindIndex((x)=>{ return x.Name == HeaderIdNameLiteral;  });
        int valuePos  =  Header.FindIndex((x)=>{ return x.Name == HeaderValueLiteral;   });
        int indexPos  =  Header.FindIndex((x)=>{ return x.Name == HeaderIndexLiteral;   });  

        if(idPos > -1 && valuePos > -1 && indexPos > -1) {
            string error = string.Format("Confuse csv format, the List csv file need include {0} field in header, key-value csv file need include {1} {2} in header", HeaderIndexLiteral, HeaderValueLiteral, HeaderIdNameLiteral);
            throw new CSVFileException(CsvFileName, error);
        }
        else if(idPos > -1 && valuePos == -1 && indexPos == -1){ //dictionary without value
            Header.Add(new HeaderRecord(HeaderValueLiteral, "dicval", HeaderValueType, Header.Count));
            Kind = EKind.DicRecord;
            dicWithoutValue = true;
        }
        else if(indexPos > -1 && idPos == -1 && valuePos == -1) { // list csv
            if(GetHeaderRecord(indexPos).Type == HeaderIndexType) {
                Kind = EKind.ListRecord;            
            }
            else {
                string error = string.Format("List csv field {0} must with {1} type.",  HeaderIndexLiteral, "int");
                throw new CSVFileException(CsvFileName, error);
            }
        }
        else if(indexPos == -1 && idPos > -1 && valuePos > -1) {  // dictionary csv
            // check id type 
            if(GetHeaderRecord(idPos).Type !=  CsvHelper.GetCsvColumnTypeByName("id")) {
                string error = string.Format("Header named {0} type does not match type {1} at file {2}", HeaderIdNameLiteral, CsvHelper.GetCsvColumnTypeByName("id"), CsvFileName);
                throw new Exception(error);
            }

            // if contains _VALUE field, check the type is int
            if(GetHeaderRecord(valuePos).Type !=  HeaderValueType) {
                string error = string.Format("Header named {0} type does not match type {1} at file {2}", HeaderValueLiteral, HeaderValueType, CsvFileName);
                throw new Exception(error);
            }

            Kind = EKind.DicRecord;
        }
        else {
            string error = string.Format("Header is not valid, make sure you add {0}:int field for list csv file and {1}:int {2}:id fields for key-value csv file at first row", HeaderIndexLiteral, HeaderValueLiteral, HeaderIdNameLiteral);
            throw new CSVFileException(CsvFileName, error);
        }

        mHeight     = mReader.Height;
    }

    private int CheckDuplicatedColumnName() {
        // check duplicated name
        for(int i = 0; i < Header.Count; i++) {
            for(int j = i+1; j < Header.Count; j++) {
                if(Header[i].Name == Header[j].Name) {
                    return i;
                }
            }
        }
        return -1;
    }

    private void ReadBody() {
        int headerIndex = 0;
        if     (Kind == EKind.ListRecord) {headerIndex = GetHeaderRecord(HeaderIndexLiteral).Index;    }
        else if(Kind == EKind.DicRecord)  {
            headerIndex = (!dicWithoutValue)?GetHeaderRecord(HeaderValueLiteral).Index:GetHeaderRecord(HeaderIdNameLiteral).Index; 
        }
        else {
            throw new Exception(string.Format("can not read body form {0} csv file: {1}", Kind, CsvFileName));
        }

        string keyValue = "";
        if (dicWithoutValue){
            keyValue = "1";
        }
        else{
            keyValue = mReader.ReadLine(1)[headerIndex];
        }

        int    counter    = 1;
        if(string.IsNullOrEmpty(keyValue)) {
            throw new Exception(string.Format("the first row of body does not contains any key value at file: {0}", CsvFileName));
        }
        int    currentRow  = 2;
        int    startRow    = 1;
        while(currentRow != mHeight) {
            string content = mReader.ReadCell(currentRow, headerIndex);
            if(!string.IsNullOrEmpty(content)) {
                if(Kind == EKind.ListRecord) {
                    try {
                        Record record = new Record(keyValue, keyValue, startRow, counter, Records.Count);
                        Records.Add(record);
                    } catch(Exception) {
                        Debug.LogError(string.Format("Can not conver {0} to int at file {1}, at cell {2} {3}", keyValue, CsvFileName, startRow, headerIndex));
                    }
                }
                else if(Kind == EKind.DicRecord) {
                    int keyNamePos = GetHeaderRecord(HeaderIdNameLiteral).Index;
                    string keyName = mReader.ReadCell(startRow, keyNamePos);
                    try {
                        Record record = new Record(keyName, keyValue, startRow, counter, Records.Count);
                        Records.Add(record);   
                    } catch(Exception) {
                        Debug.LogError(string.Format("Can not conver {0} to int at file {1}, at cell {2} {3}", keyValue, CsvFileName, startRow, headerIndex));                        
                    }
                }
                startRow = currentRow;
                counter   = 1;
                if (dicWithoutValue){
                    int value = 0;
                    int.TryParse(keyValue, out value);
                    keyValue = (value + 1).ToString();
                }else{
                    keyValue  = content;
                }
            }
            else {
                counter++;
            }
            currentRow++;
        }

        if(Kind == EKind.ListRecord) {
            Record record = new Record(keyValue, keyValue, startRow, counter, Records.Count);
            Records.Add(record);
        }
        else if(Kind == EKind.DicRecord) {
            int keyNamePos = GetHeaderRecord(HeaderIdNameLiteral).Index;
            string keyName = mReader.ReadCell(startRow, keyNamePos);
            Record record = new Record(keyName, keyValue, startRow, counter, Records.Count);
            Records.Add(record);
        }

        CheckKeyValueValidation();

        // create header content length
        for(int i = 0; i < Records.Count; i++) {
            for(int j = 0; j < mWidth; j++) {
                var currentRecord = Records[i];
                int start = Records[i].StartRow;
                int end   = start + Records[i].Height;
                int column   = j;
                int contentNum  = 0;
                bool hasEmptyCell = false;
                for(int k = start; k < end; k++) {
                    if( !string.IsNullOrEmpty(mReader.ReadCell(k, column))) {
                        if(hasEmptyCell) {
                            throw new Exception( string.Format("Contains empty cell at row {0}, column {1} in the file: {2}", k, column, CsvFileName));
                        }
                        else {
                            contentNum++;
                        }
                    }
                    else {
                        hasEmptyCell = true;
                    }
                }
                currentRecord.HeaderContentLength.Add(contentNum);                
            }
        }
    }

    private void CheckKeyValueValidation() {
        if(Kind == EKind.ListRecord) {
            for(int i = 0; i < Records.Count; i++) {
                if(Records[i].KeyValue != i) {
                    throw new Exception(string.Format("Value in {0} column is not sequential like 0,1,2,3... in the file {1}", HeaderIndexLiteral, CsvFileName));
                }
            }
        }
        else if(Kind == EKind.DicRecord) {
            for(int i = 0; i < Records.Count; i++) {
                if( !CsvHelper.IsValidVariableName(Records[i].KeyName) ) {
                    throw new Exception(string.Format("Key Name value {0} is not valid name at file {1}", Records[i].KeyName, CsvFileName));
                }

                if( !IsValidKeyValueForDicRecord(Records[i].KeyValue)) {                
                    throw new Exception(string.Format("Key ID value {0} is not valid name at file {1}", Records[i].KeyValue, CsvFileName));
                }
                for(int j = i+1; j < Records.Count; j++) {
                    if(Records[i].KeyName == Records[j].KeyName) {         
                        throw new Exception(string.Format("Contains same name {0} in {1} column in the file {2}", Records[j].KeyName, HeaderIdNameLiteral, CsvFileName));
                    }

                    if(Records[i].KeyValue == Records[j].KeyValue) {             
                        throw new Exception(string.Format("Contains same value {0} in {1} column in the file {2}", Records[j].KeyValue, HeaderValueLiteral, CsvFileName));
                    }
                }
            }
        }
        else {
            throw new Exception("Unknow csv file type");
        }
    }

    public string GetValue(int x, int y) {
        return mReader.ReadCell(x, y);
    }


    private bool IsValidKeyValueForDicRecord (int keyValue) {
        return keyValue > 0;
    }
}
}
    