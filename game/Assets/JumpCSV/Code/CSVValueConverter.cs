using System;
using System.Collections;
using UnityEngine;

namespace JumpCSV {
public static class CsvValueConverter {

    public static int[]    ParseIntArray     (string s) { 
        if(string.IsNullOrEmpty(s)) {
            return new int[0];
        }
        var line = s.Split(new Char[]{'|','#'});
        int[] result = new int[line.Length];

        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseInt(line[i]);
        }
        return result;
    }

    public static int    ParseInt     (string s) { 
        if(String.IsNullOrEmpty(s)) {
            return 0;
        }    
        return Int32.Parse(s);
    }

    public static ObsInt    ParseObsInt     (string s) { 
        if(String.IsNullOrEmpty(s)) {
            return 0;
        }    
        return new ObsInt(Int32.Parse(s));
    }

    public static ObsInt[]    ParseObsIntArray     (string s) { 
        if(string.IsNullOrEmpty(s)) {
            return new ObsInt[0];
        }
        var line = s.Split(new Char[]{'|','#'});
        ObsInt[] result = new ObsInt[line.Length];

        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseObsInt(line[i]);
        }
        return result;
    }
    
    public static float  ParseFloat   (string s) {
        if(String.IsNullOrEmpty(s)) {
            return 0f;
        }    
        return float.Parse(s);
    }

    public static float[]    ParseFloatArray     (string s) { 
        if(string.IsNullOrEmpty(s)) {
            return new float[0];
        }
        var line = s.Split(new Char[]{'|','#'});
        float[] result = new float[line.Length];

        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseFloat(line[i]);
        }
        return result;
    }

    public static double ParseDouble (string s) {
        if(String.IsNullOrEmpty(s)) {
            return 0;
        }
        return double.Parse(s);
    }

    public static double[]    ParseDoubleArray     (string s) { 
        if(string.IsNullOrEmpty(s)) {
            return new double[0];
        }
        var line = s.Split(new Char[]{'|','#'});
        double[] result = new double[line.Length];

        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseDouble(line[i]);
        }
        return result;
    }

    public static decimal ParseDecimal(string s) {
        if(String.IsNullOrEmpty(s)) {
            return 0m;
        }
        return decimal.Parse(s);
    }

    public static decimal[]    ParseDecimalArray     (string s) { 
        if(string.IsNullOrEmpty(s)) {
            return new decimal[0];
        }
        var line = s.Split(new Char[]{'|','#'});
        decimal[] result = new decimal[line.Length];

        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseDecimal(line[i]);
        }
        return result;
    }
    
    public static string ParseString  (string s) {
        return s;
    }

    public static string[] ParseStringArray (string s) {
        if(string.IsNullOrEmpty(s)) {
            return new string[0];
        }
        var line = s.Split(new Char[]{'|','#'});
        string[] result = new string[line.Length];

        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseString(line[i]);
        }
        return result;        
    }

    public static bool   ParseBool (string s) {
        if(String.IsNullOrEmpty(s)) {
            return false;
        }    
        return bool.Parse(s);
    }

    public static Vector2 ParseVector2(string s) {
        if(String.IsNullOrEmpty(s)) {
            return Vector2.zero;
        }
        string[] part = s.Split(new char[]{','});
        return new Vector2(ParseFloat(part[0]), ParseFloat(part[1]));
    }

    public static Vector3 ParseVector3(string s) {
        if(String.IsNullOrEmpty(s)) {
            return Vector3.zero;
        }
        string[] part = s.Split(new char[]{','});
        return new Vector3(ParseFloat(part[0]), ParseFloat(part[1]), ParseFloat(part[2]));
    }

    public static int ParseCsvRecordId(string s) {
        if(String.IsNullOrEmpty(s)) {
            return 0;
        }
        try {
            return (int)((typeof(ERId)).GetField(s).GetRawConstantValue());
        }
        catch{
            Debug.LogError("can not parse " + s);
        }
        return 0;
    }

    public static int[] ParseCsvRecordIdArray(string s) {
        if(string.IsNullOrEmpty(s)) {
            return new int[0];
        }
        var line = s.Split(new Char[]{'|','#'});
        int[] result = new int[line.Length];

        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseCsvRecordId(line[i]);
        }
        return result;        
    }

    public static int[] ParseCsvRecordLocArray(string s) {
        if(string.IsNullOrEmpty(s)) {
            return new int[0];
        }
        var line = s.Split(new Char[]{'|','#'});
        int[] result = new int[line.Length];

        for(int i = 0; i < line.Length; i++) {
            if(string.IsNullOrEmpty(line[i])) {
                result[i] = 0;
            }
            else {                
                result[i] = LocalizationCsvData.IdRecordValue[line[i]];
            }
        }
        return result;        
    }


    [CsvColumnTypeAttributes(typeof(ObsInt), "obsint")]
    public static ObsInt ReadValueObsInt(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;

        return ParseObsInt(sheet.GetValue(row, column)); 
    }

    [CsvColumnTypeAttributes(typeof(ObsInt[]), "obsint[]")]
    public static ObsInt[] ReadValueObsIntArray(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        ObsInt[] result = new ObsInt[len];

        for(int i = 0; i < len; i++) {
            result[i] = ParseObsInt(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(ObsInt[]), "obsint{}")]
    public static ObsInt[] ReadValueObsIntArrayLine(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        var v = sheet.GetValue(row, column);
        string[] line;
        if(string.IsNullOrEmpty(v)) {
            line = new string[0];
        }
        else {
            line = sheet.GetValue(row, column).Split(new Char[]{'|','#'});
        }

        ObsInt[] result = new ObsInt[line.Length];

        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseObsInt(line[i]);
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(ObsInt[][]), "obsint[][]")]
    public static ObsInt[][] ReadValueObsIntArray2(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        ObsInt[][] result = new ObsInt[len][];

        for(int i = 0; i < len; i++) {
            result[i] = ParseObsIntArray(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(int), "dicval")]
    public static int ReadValueDicValue(CsvSpreadSheet sheet, int index, string headerName ) {
        if (headerName == "_VALUE" && sheet.dicWithoutValue) {
            return sheet.Records[index].KeyValue; 
        }
    
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;

        return ParseInt(sheet.GetValue(row, column)); 
    }


    [CsvColumnTypeAttributes(typeof(int), "int")]
    public static int ReadValueInt(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;

        return ParseInt(sheet.GetValue(row, column)); 
    }

    [CsvColumnTypeAttributes(typeof(int[]), "int[]")]
    public static int[] ReadValueIntArray(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        int[] result = new int[len];

        for(int i = 0; i < len; i++) {
            result[i] = ParseInt(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(int[]), "int{}")]
    public static int[] ReadValueIntArrayLine(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        var v = sheet.GetValue(row, column);
        string[] line;
        if(string.IsNullOrEmpty(v)) {
            line = new string[0];
        }
        else {
            line = sheet.GetValue(row, column).Split(new Char[]{'|','#'});
        }
        int[] result = new int[line.Length];
        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseInt(line[i]);
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(int[][]), "int[][]")]
    public static int[][] ReadValueIntArray2(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        int[][] result = new int[len][];

        for(int i = 0; i < len; i++) {
            result[i] = ParseIntArray(sheet.GetValue(i+row, column));
        }
        return result;
    }


    [CsvColumnTypeAttributes(typeof(float), "float")]
    public static float ReadValueFloat(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;

        return ParseFloat(sheet.GetValue(row, column)); 
    }

    [CsvColumnTypeAttributes(typeof(float[]), "float[]")]
    public static float[] ReadValueFloatArray(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        float[] result = new float[len];

        for(int i = 0; i < len; i++) {
            result[i] = ParseFloat(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(float[][]), "float[][]")]
    public static float[][] ReadValueFloatArray2(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        float[][] result = new float[len][];

        for(int i = 0; i < len; i++) {
            result[i] = ParseFloatArray(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(Vector2), "vector2")]
    public static Vector2 ReadValueVector2(CsvSpreadSheet sheet, int index, string headerName) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;

        return ParseVector2(sheet.GetValue(row, column));
    }

    [CsvColumnTypeAttributes(typeof(Vector2), "vector2{}")]
    public static Vector2[] ReadValueVector2ArrayLine(CsvSpreadSheet sheet, int index, string headerName) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        var v = sheet.GetValue(row, column);
        string[] line;
        if(string.IsNullOrEmpty(v)) {
            line = new string[0];
        }
        else {
            line = sheet.GetValue(row, column).Split(new Char[]{'|','#'});
        }

        Vector2[] result = new Vector2[line.Length];
        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseVector2(line[i]);
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(Vector2[]), "vector2[]")]
    public static Vector2[] ReadValueVector2Array(CsvSpreadSheet sheet, int index, string headerName) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        Vector2[] result = new Vector2[len];

        for(int i = 0; i < len; i++) {
            result[i] = ParseVector2(sheet.GetValue(i+row, column));
        } 
        return result;
    }

    [CsvColumnTypeAttributes(typeof(Vector3), "vector3")]
    public static Vector3 ReadValueVector3(CsvSpreadSheet sheet, int index, string headerName) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;

        return ParseVector2(sheet.GetValue(row, column));
    }

    [CsvColumnTypeAttributes(typeof(Vector3[]), "vector3{}")]
    public static Vector3[] ReadValueVector3ArrayLine(CsvSpreadSheet sheet, int index, string headerName) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        var v = sheet.GetValue(row, column);
        string[] line;
        if(string.IsNullOrEmpty(v)) {
            line = new string[0];
        }
        else {
            line = sheet.GetValue(row, column).Split(new Char[]{'|','#'});
        }
        Vector3[] result = new Vector3[line.Length];
        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseVector3(line[i]);
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(Vector3[]), "vector3[]")]
    public static Vector3[] ReadValueVector3Array(CsvSpreadSheet sheet, int index, string headerName) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        Vector3[] result = new Vector3[len];

        for(int i = 0; i < len; i++) {
            result[i] = ParseVector2(sheet.GetValue(i+row, column));
        } 
        return result;
    }

    [CsvColumnTypeAttributes(typeof(double), "double")]
    public static double ReadValueDouble(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;

        return ParseDouble(sheet.GetValue(row, column)); 
    }

    [CsvColumnTypeAttributes(typeof(double[]), "double{}")]
    public static double[] ReadValueDoubleArrayLine(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        var v = sheet.GetValue(row, column);
        string[] line;
        if(string.IsNullOrEmpty(v)) {
            line = new string[0];
        }
        else {
            line = sheet.GetValue(row, column).Split(new Char[]{'|','#'});
        }
        double[] result = new double[line.Length];
        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseDouble(line[i]);
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(double[][]), "double[][]")]
    public static double[][] ReadValueDoubleArray2(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        double[][] result = new double[len][];

        for(int i = 0; i < len; i++) {
            result[i] = ParseDoubleArray(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(double[]), "double[]")]
    public static double[] ReadValueDoubleArray(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        double[] result = new double[len];

        for(int i = 0; i < len; i++) {
            result[i] = ParseDouble(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(decimal), "decimal")]
    public static decimal ReadValueDecimal(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;

        return ParseDecimal(sheet.GetValue(row, column)); 
    }

    [CsvColumnTypeAttributes(typeof(decimal[]), "decimal{}")]
    public static decimal[] ReadValueDecimalArrayLine(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        var v = sheet.GetValue(row, column);
        string[] line;
        if(string.IsNullOrEmpty(v)) {
            line = new string[0];
        }
        else {
            line = sheet.GetValue(row, column).Split(new Char[]{'|','#'});
        }
        decimal[] result = new decimal[line.Length];
        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseDecimal(line[i]);
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(decimal[][]), "decimal[][]")]
    public static decimal[][] ReadValueDecimalArray2(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        decimal[][] result = new decimal[len][];

        for(int i = 0; i < len; i++) {
            result[i] = ParseDecimalArray(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(decimal[]), "decimal[]")]
    public static decimal[] ReadValueDecimalArray(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        decimal[] result = new decimal[len];

        for(int i = 0; i < len; i++) {
            result[i] = ParseDecimal(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(string), "string")]
    public static string ReadValueString(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;

        return ParseString(sheet.GetValue(row, column)); 
    }

    [CsvColumnTypeAttributes(typeof(string[]), "string[]")]
    public static string[] ReadValueStringArray(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        string[] result = new string[len];

        for(int i = 0; i < len; i++) {
            result[i] = ParseString(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(string[][]), "string[][]")]
    public static string[][] ReadValueStringArray2(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        string[][] result = new string[len][];

        for(int i = 0; i < len; i++) {
            result[i] = ParseStringArray(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(string[]), "string{}")]
    public static string[] ReadValueStringArrayLine(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        var line   = sheet.GetValue(row, column).Split(new Char[]{'|','#'});

        string[] result = new string[line.Length];
        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseString(line[i]);
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(bool), "bool")]
    public static bool ReadValueBool(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;

        return ParseBool(sheet.GetValue(row, column)); 
    }

    [CsvColumnTypeAttributes(typeof(bool[]), "bool[]")]
    public static bool[] ReadValueBoolArray(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        bool[] result = new bool[len];

        for(int i = 0; i < len; i++) {
            result[i] = ParseBool(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(bool[]), "bool{}")]
    public static bool[] ReadValueBoolArrayLine(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        var line   = sheet.GetValue(row, column).Split(new Char[]{'|','#'});

        bool[] result = new bool[line.Length];
        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseBool(line[i]);
        }
        return result;
    }


    [CsvColumnTypeAttributes(typeof(int), "id")]
    public static int ReadValueCsvRecordId(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;

        return ParseCsvRecordId(sheet.GetValue(row, column)); 
    }

    [CsvColumnTypeAttributes(typeof(int[]), "id[]")]
    public static int[] ReadValueCsvIdArray(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        int[] result = new int[len];

        for(int i = 0; i < len; i++) {
            result[i] = ParseCsvRecordId(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(int[][]), "id[][]")]
    public static int[][] ReadValueCsvIdArray2(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        int[][] result = new int[len][];

        for(int i = 0; i < len; i++) {
            result[i] = ParseCsvRecordIdArray(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(int[]), "id{}")]
    public static int[] ReadValueCsvIdArrayLine(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        var line   = sheet.GetValue(row, column).Split(new Char[]{'|','#'});

        int[] result = new int[line.Length];
        for(int i = 0; i < line.Length; i++) {
            result[i] = ParseCsvRecordId(line[i]);
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(int), "loc")]
    public static int ReadValueCsvLoc(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        if(string.IsNullOrEmpty(sheet.GetValue(row, column))) {
            return 0;
        }
        else {
            return LocalizationCsvData.IdRecordValue[sheet.GetValue(row, column)];
        }
    }

    [CsvColumnTypeAttributes(typeof(int[]), "loc[]")]
    public static int[] ReadValueLocArray(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        int[] result = new int[len];
        for(int i = 0; i < len; i++) {
            if(string.IsNullOrEmpty(sheet.GetValue(row+i, column))) {
                result[i] = 0;
            }
            else {
                result[i] = LocalizationCsvData.IdRecordValue[sheet.GetValue(i+row, column)];
            }
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(int[][]), "loc[][]")]
    public static int[][] ReadValueLocArray2(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        int len    = sheet.GetRecord(index).HeaderContentLength[column];
        int[][] result = new int[len][];
 
        for(int i = 0; i < len; i++) {
            result[i] = ParseCsvRecordLocArray(sheet.GetValue(i+row, column));
        }
        return result;
    }

    [CsvColumnTypeAttributes(typeof(int[]), "loc{}")]
    public static int[] ReadValueLocArrayLine(CsvSpreadSheet sheet, int index, string headerName ) {
        int row    = sheet.GetRecord(index).StartRow;
        int column = sheet.GetHeaderRecord(headerName).Index;
        var line   = sheet.GetValue(row, column).Split(new Char[]{'|','#'});

        int[] result = new int[line.Length];
        for(int i = 0; i < line.Length; i++) {
            if(string.IsNullOrEmpty(sheet.GetValue(row+i, column))) {
                result[i] = 0;
            }
            else {                
                result[i] = LocalizationCsvData.IdRecordValue[sheet.GetValue(i+row, column)];
            }
        }
        return result;
    }
}
}
