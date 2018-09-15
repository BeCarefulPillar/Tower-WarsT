using System;
using System.IO;
using System.Text;

namespace Kiol.IO.Table
{
    public class KTableWriter : IDisposable
    {
        private BinaryWriter mWriter;
        private KTableRow mRow;

        public KTableWriter(Stream stream, KTableRow row) : this(stream, row, Encoding.ASCII) { }
        public KTableWriter(Stream stream, KTableRow row, Encoding encoding)
        {
            if (row == null || row.columnNum < 1)
            {
                throw new ArgumentNullException("KTableWriter need row");
            }
            byte code = 0;
            if (encoding == Encoding.ASCII)
            {
                code = 1;
            }
            else if (encoding == Encoding.UTF8)
            {
                code = 2;
            }
            else
            {
                throw new NotSupportedException("Encoding(" + encoding.EncodingName + ") not supported!");
            }
            mRow = row;
            mWriter = new BinaryWriter(stream, encoding);
            mWriter.Write(code);
            byte cnt = (byte)mRow.columnNum;
            mWriter.Write(cnt);
            for (int i = 0; i < cnt; i++)
            {
                mWriter.Write((byte)mRow[i]);
            }
            if (mRow.hasColumnName)
            {
                mWriter.Write(cnt);
                for (int i = 0; i < cnt; i++)
                {
                    mWriter.Write(mRow.GetColumnName(i));
                }
            }
            else
            {
                mWriter.Write(0);
            }
        }

        public KTableRow row { get { return mRow; } }

        public void WriteRow(KTableRowData data)
        {
            if (data.row != mRow)
            {
                throw new ArgumentException("row not match!");
            }
            WriteRow(data.data);
        }

        public void WriteRow(params object[] data)
        {
            if (data == null)
            {
                throw new ArgumentNullException("data can not null!");
            }
            if (data.Length != mRow.columnNum)
            {
                throw new ArgumentException("data length not match row");
            }
            for (int i = 0; i < mRow.columnNum; i++)
            {
                if (data[i] == null)
                {
                    throw new ArgumentNullException("data[" + i + "] can not null!");
                }
                TypeCode typeCode = Type.GetTypeCode(data[i].GetType());
                if (typeCode != mRow[i])
                {
                    throw new ArgumentException("data[" + i + "] type(" + typeCode + ") not match " + mRow[i] + " !");
                }
                switch (typeCode)
                {
                    case TypeCode.Boolean: mWriter.Write((bool)data[i]); break;
                    case TypeCode.Char: mWriter.Write((char)data[i]); break;
                    case TypeCode.Byte: mWriter.Write((byte)data[i]); break;
                    case TypeCode.SByte: mWriter.Write((sbyte)data[i]); break;
                    case TypeCode.Int16: mWriter.Write((Int16)data[i]); break;
                    case TypeCode.UInt16: mWriter.Write((UInt16)data[i]); break;
                    case TypeCode.Int32: mWriter.Write((Int32)data[i]); break;
                    case TypeCode.UInt32: mWriter.Write((UInt32)data[i]); break;
                    case TypeCode.Int64: mWriter.Write((Int64)data[i]); break;
                    case TypeCode.UInt64: mWriter.Write((UInt64)data[i]); break;
                    case TypeCode.Single: mWriter.Write((Single)data[i]); break;
                    case TypeCode.Double: mWriter.Write((Double)data[i]); break;
                    case TypeCode.Decimal: mWriter.Write((Decimal)data[i]); break;
                    case TypeCode.String: mWriter.Write((string)data[i]); break;
                    default: throw new NotSupportedException("type " + typeCode + " not supported!");
                }
            }
        }

        public void Dispose()
        {
            if (mWriter != null)
            {
                mWriter.Close();
            }
        }
    }
}