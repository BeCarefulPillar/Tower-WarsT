using System;
using System.IO;
using System.Text;
using Kiol.Zip.GZip;

namespace Kiol.IO.Table
{
    public class KTableReader : IDisposable
    {
        private BinaryReader mReader;
        private KTableRow mRow;

        public KTableReader(byte[] buffer, bool isGzip = false) : this(isGzip ? new GZipInputStream(new MemoryStream(buffer, false)) as Stream : new MemoryStream(buffer, false)) { }
            
        public KTableReader(Stream stream)
        {
            int code = stream.ReadByte();
            Encoding encoding = null;
            if (code == 1)
            {
                encoding = Encoding.ASCII;
            }
            else if (code == 2)
            {
                encoding = Encoding.UTF8;
            }
            else
            {
                throw new IOException("stream not a table data");
            }
            mReader = new BinaryReader(stream, encoding);
            int col = mReader.ReadByte();
            if (col == 0)
            {
                throw new IOException("stream not a table data");
            }
            TypeCode[] types = new TypeCode[col];
            for (int i = 0; i < col; i++)
            {
                TypeCode typeCode = (TypeCode)mReader.ReadByte();
                if (KTableRow.IsUnSupportedType(typeCode))
                {
                    throw new IOException("stream not a table data");
                }
                types[i] = typeCode;
            }
            string[] colNames = null;
            int nameCnt = mReader.ReadByte();
            if (nameCnt == col)
            {
                colNames = new string[col];
                for (int i = 0; i < col; i++)
                {
                    colNames[i] = mReader.ReadString();
                }
            }
            else if (nameCnt > 0)
            {
                throw new IOException("stream not a table data");
            }
            mRow = new KTableRow(types, colNames);
        }

        public KTableRow row { get { return mRow; } }

        public KTableRowData ReadRow()
        {
            object[] data = ReadRowData();
            return data == null ? null : mRow.CreatData(data);
        }

        public bool ReadRow(KTableRowData krd)
        {
            if (krd == null || krd.row != mRow) return false;
            if (krd.row != mRow)
            {
                throw new ArgumentException("row not match!");
            }
            object[] data = ReadRowData();
            krd.SetDataDit(data);
            return data != null;
        }

        public object[] ReadRowData()
        {
            object[] data = null;
            try
            {
                data = new object[mRow.columnNum];
                for (int i = 0; i < mRow.columnNum; i++)
                {
                    data[i] = Read(mRow[i]);
                }
            }
            catch
            {
                data = null;
            }
            return data;
        }

        public KTable ReadToTable()
        {
            KTable table = new KTable(mRow, 32);
            object[] data = ReadRowData();
            while (data != null)
            {
                table.Add(data);
                data = ReadRowData();
            }
            return table;
        }

        private object Read(TypeCode typeCode)
        {
            switch (typeCode)
            {
                case TypeCode.Boolean: return mReader.ReadBoolean();
                case TypeCode.Char: return mReader.ReadChar();
                case TypeCode.Byte: return mReader.ReadByte();
                case TypeCode.SByte: return mReader.ReadSByte();
                case TypeCode.Int16: return mReader.ReadInt16();
                case TypeCode.UInt16: return mReader.ReadUInt16();
                case TypeCode.Int32: return mReader.ReadInt32();
                case TypeCode.UInt32: return mReader.ReadUInt32();
                case TypeCode.Int64: return mReader.ReadInt64();
                case TypeCode.UInt64: return mReader.ReadUInt64();
                case TypeCode.Single: return mReader.ReadSingle();
                case TypeCode.Double: return mReader.ReadDouble();
                case TypeCode.Decimal: return mReader.ReadDecimal();
                case TypeCode.String: return mReader.ReadString();
                default: throw new NotSupportedException("type " + typeCode + " not supported!");
            }
        }

        public void Dispose()
        {
            if (mReader != null)
            {
                mReader.Close();
            }
        }
    }
}