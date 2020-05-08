using System;
#pragma warning disable 414
public class CSVFileException : Exception {

    int column;
    int row;
    string file;

    public CSVFileException(string file, int column, int row, string errorMessage):
            base(string.Format("column: {1} row: {2} in file {3} contains error {0}", errorMessage, column, row, file))
     {
        this.column = column;
        this.row    = row;
        this.file   = file;
    }

    public CSVFileException(string file, string errorMessage) : base (string.Format("{0} contains error {1}", file, errorMessage)) {
        this.column = -1;
        this.row    = -1;
        this.file   = file;
    }

}
