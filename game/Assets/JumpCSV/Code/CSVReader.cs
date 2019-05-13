using UnityEngine;
using System;
using System.Linq;
using System.Collections.Generic;
using System.IO;
using System.Text;

public class CsvReader
{
    static public char   FIELD_DELIMITER    = ',';   // A one-character string used to separate fields.
    static public bool   DOUBLEQUOTE        = true;  // if true quote in quote field need doubled
    static public char   QUOTECHAR          = '"';   // the character to quote
    static public char   NEWLINE            = '\n';  // line feeder character
    static public char   CARRIAGERETURN     = '\r';  

    public  int              Width      {get;private set;}
    public  int              Height     {get;private set;}
    public  string           RawContent {get;private set;}
    private int              p;
    private List<string[]>   mGrid = new List<string[]>();

    public void Clear() {
        Width  = -1;
        Height = -1;
        RawContent = "";
        p          = 0;
        mGrid.Clear();
    }

    private char Peek() {
        if(p < RawContent.Length-1) return RawContent[p+1];
        else return char.MinValue;
    }

    private void CreateColumn(List<string> columns) {
        Width = columns.Count;
        mGrid.Add(columns.ToArray());
        Height = 1;
    }

    private void AddRow(List<string> rows) {
        mGrid.Add(rows.ToArray());
        Height++;
    }

    public void ReadFromString(string content) {
        Clear();
        RawContent = content;
        List<string>  line   = new List<string>();
        StringBuilder buffer = new StringBuilder(1024);

        bool isInQuote = false;

        Action AddCurrent = () => {
            buffer.Append(RawContent[p]);
        };

        Action AddField = () => {
            line.Add(buffer.ToString());
            buffer.Length = 0;
        };

        Action AddToGrid = () => {
            if(Height == -1) {
                CreateColumn(line);
            }
            else {
                AddRow(line);
            }
            line.Clear();
        };

        while(p < RawContent.Length) {
            if(RawContent[p] == QUOTECHAR) {
                if(!isInQuote) {
                    isInQuote = true;
                }
                else {
                    if(Peek() == FIELD_DELIMITER) {
                        AddField();
                        p++;
                        isInQuote = false;
                    }
                    else if(Peek() == NEWLINE || Peek() == CARRIAGERETURN ) {
                        isInQuote = false;
                    }
                    else {
                        if(DOUBLEQUOTE) {
                            if(Peek() != QUOTECHAR) {
                                throw new Exception("quote character is not double in quote filed " + buffer.ToString() + Peek());
                            }
                            p++;
                        }
                        AddCurrent();
                    }
                }                
            }
            else if(RawContent[p] == FIELD_DELIMITER) {
                if(!isInQuote) {
                    AddField();
                }
                else {
                    AddCurrent();                    
                }
            }
            else if(RawContent[p] == NEWLINE || RawContent[p] == CARRIAGERETURN) { // meet line terminator
                if(!isInQuote) {
                    if(RawContent[p] == CARRIAGERETURN && Peek() == NEWLINE) { // skip /r/n
                        p++;
                    }
                    AddField();
                    AddToGrid();
                }
                else {
                    AddCurrent();
                }                
            }
            else {
                AddCurrent();
            }
            p++;
        }

        if(line.Count > 0) { // when last character is not line terminator
            AddField();
            AddToGrid();
        }
    }

    public void Read(string filePath, bool resourceLoad = false) {
        Clear();
        if(resourceLoad) {
            TextAsset asset = Resources.Load(filePath) as TextAsset;
            if(asset == null) throw new Exception("Can not load file from " + filePath.ToString());
            ReadFromString(asset.text);
        }
        else {
            using(StreamReader reader = File.OpenText(filePath)) {
                if(reader == null) throw new ArgumentNullException("can not read " + filePath.ToString());
                ReadFromString(reader.ReadToEnd());
            }            
        }
    }

    public string[] ReadLine(int n) {
        if(n > mGrid.Count && n < 0) {
            throw new Exception("line number is invailed");
        }
        return mGrid[n];
    }

    public string ReadCell(int x, int y) {
        return ReadLine(x)[y];
    }
    
    public void DebugOutputmGrid()
    {
        StringBuilder textOutput = new StringBuilder("****Dump CSV Table****\n", 1024); 
        for (int x = 0; x < Height; x++) {  
            for (int y = 0; y < Width; y++) {
                textOutput.Append(mGrid[x][y]); 
                textOutput.Append("|") ; 
            }
            textOutput.Append("\n") ; 
        }
        Debug.Log(textOutput.ToString());
    }
                    
}

