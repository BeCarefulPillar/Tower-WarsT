using System;
using Kiol.Util;

namespace Kiol.IO.Table
{
    public class KTableRowData
    {
        private KTableRow mRow;
        private object[] mData;

        public KTableRowData(KTableRow row, object[] data)
        {
            if (row == null)
            {
                throw new ArgumentNullException("creat KTableRowData need a KTableRow!");
            }

            //mData = new object[row.columnNum];
            mRow = row;
            SetData(data);
        }

        public KTableRow row { get { return mRow; } }

        public object this[int column]
        {
            get
            {
                return (mData != null && column >= 0 && column < mData.Length) ? mData[column] : null;
            }
            set
            {
                if (column >= 0 && column < mData.Length)
                {
                    if (value == null)
                    {
                        mData[column] = KConvert.Default(mRow.GetColumnType(column));
                    }
                    else if (Convert.GetTypeCode(value) == mRow.GetColumnType(column))
                    {
                        mData[column] = value;
                    }
                }
            }
        }

        public object this[string columnName]
        {
            get
            {
                return this[mRow.GetColumnIndex(columnName)];
            }
            set
            {
                this[mRow.GetColumnIndex(columnName)] = value;
            }
        }

        public void SetData(object[] data)
        {
            if (data == null)
            {
                mData = null;
            }
            else if (data.Length == mRow.columnNum)
            {
                for (int i = 0; i < data.Length; i++)
                {
                    TypeCode typeCode = Type.GetTypeCode(data[i].GetType());
                    if (typeCode != mRow[i])
                    {
                        throw new ArgumentException("data[" + i + "] type(" + typeCode + ") not match " + mRow[i] + " !");
                    }
                }
                mData = data;
            }
            else
            {
                throw new ArgumentException("data length[" + data.Length + "] not match row[" + mRow.columnNum + "]");
            }
        }

        public void SetDataDit(object[] data)
        {
            mData = data;
        }

        public object[] data { get { return mData; } }

        public bool GetBool(int column) { object d = this[column]; return d is bool ? (bool)d : false; }
        public bool GetBool(string columnName) { return GetBool(mRow.GetColumnIndex(columnName)); }
        public char GetChar(int column) { object d = this[column]; return d is char ? (char)d : default(char); }
        public char GetChar(string columnName) { return GetChar(mRow.GetColumnIndex(columnName)); }
        public byte GetByte(int column) { object d = this[column]; return d is byte ? (byte)d : default(byte); }
        public byte GetByte(string columnName) { return GetByte(mRow.GetColumnIndex(columnName)); }
        public sbyte GetSByte(int column) { object d = this[column]; return d is sbyte ? (sbyte)d : default(sbyte); }
        public sbyte GetSByte(string columnName) { return GetSByte(mRow.GetColumnIndex(columnName)); }
        public short GetInt16(int column) { object d = this[column]; return d is short ? (short)d : default(short); }
        public short GetInt16(string columnName) { return GetInt16(mRow.GetColumnIndex(columnName)); }
        public ushort GetUInt16(int column) { object d = this[column]; return d is ushort ? (ushort)d : default(ushort); }
        public ushort GetUInt16(string columnName) { return GetUInt16(mRow.GetColumnIndex(columnName)); }
        public int GetInt32(int column) { object d = this[column]; return d is int ? (int)d : default(int); }
        public int GetInt32(string columnName) { return GetInt32(mRow.GetColumnIndex(columnName)); }
        public uint GetUInt32(int column) { object d = this[column]; return d is uint ? (uint)d : default(uint); }
        public uint GetUInt32(string columnName) { return GetUInt32(mRow.GetColumnIndex(columnName)); }
        public long GetInt64(int column) { object d = this[column]; return d is long ? (long)d : default(long); }
        public long GetInt64(string columnName) { return GetInt64(mRow.GetColumnIndex(columnName)); }
        public ulong GetUInt64(int column) { object d = this[column]; return d is ulong ? (ulong)d : default(ulong); }
        public ulong GetUInt64(string columnName) { return GetUInt64(mRow.GetColumnIndex(columnName)); }
        public float GetFloat(int column) { object d = this[column]; return d is float ? (float)d : default(float); }
        public float GetFloat(string columnName) { return GetFloat(mRow.GetColumnIndex(columnName)); }
        public double GetDouble(int column) { object d = this[column]; return d is double ? (double)d : default(double); }
        public double GetDouble(string columnName) { return GetDouble(mRow.GetColumnIndex(columnName)); }
        public decimal GetDecimal(int column) { object d = this[column]; return d is decimal ? (decimal)d : default(decimal); }
        public decimal GetDecimal(string columnName) { return GetDecimal(mRow.GetColumnIndex(columnName)); }
        public string GetString(int column) { object d = this[column]; return d is string ? (string)d : string.Empty; }
        public string GetString(string columnName) { return GetString(mRow.GetColumnIndex(columnName)); }
    }
}