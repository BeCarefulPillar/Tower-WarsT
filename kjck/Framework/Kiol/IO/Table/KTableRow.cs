using System;
using System.Collections.Generic;

namespace Kiol.IO.Table
{
    public class KTableRow : IEnumerable<TypeCode>
    {
        private TypeCode[] mColumnType;
        private string[] mColumnName;
        private Dictionary<string, int> mColumnNameDic;

        public KTableRow(TypeCode[] columnsType, string[] columnsName = null)
        {
            if (columnsType != null && columnsType.Length > 0)
            {
                if (columnsType.Length > 255)
                {
                    throw new ArgumentOutOfRangeException("columnNum can not be over 255!");
                }
                for (int i = 0; i < columnsType.Length; i++)
                {
                    if (IsUnSupportedType(columnsType[i]))
                    {
                        throw new NotSupportedException("type " + columnsType[i] + " not supported!");
                    }
                }
                mColumnType = columnsType;
                if (columnsName != null)
                {
                    if (columnsName.Length == columnsType.Length)
                    {
                        mColumnNameDic = new Dictionary<string, int>(columnsName.Length);
                        for (int i = 0; i < columnsName.Length; i++)
                        {
                            try
                            {
                                mColumnNameDic.Add(columnsName[i], i);
                            }
                            catch (ArgumentNullException)
                            {
                                throw new ArgumentNullException("columnNname can not be null in index " + i + " !");
                            }
                            catch (ArgumentException)
                            {
                                throw new ArgumentException("Duplicate columnNname " + columnsName[i] + " !");
                            }
                        }
                        mColumnName = columnsName;
                    }
                    else
                    {
                        throw new ArgumentException("columnNname num must equals columnsType!");
                    }
                }
            }
            else
            {
                throw new ArgumentException("columnNum can not be zero!");
            }
        }

        public bool hasColumnName { get { return mColumnName != null; } }

        public int columnNum { get { return mColumnType.Length; } }

        public TypeCode this[int index] { get { return mColumnType[index]; } }

        public int GetColumnIndex(string columnNmae)
        {
            if (mColumnNameDic == null) return -1;
            int idx = 0;
            return mColumnNameDic.TryGetValue(columnNmae, out idx) ? idx : -1;
        }

        public string GetColumnName(int column)
        {
            if (mColumnName == null) return string.Empty;
            return (column >= 0 && column < mColumnName.Length) ? mColumnName[column] : string.Empty;
        }
        public TypeCode GetColumnType(int column)
        {
            return (column >= 0 && column < columnNum) ? mColumnType[column] : TypeCode.Empty;
        }
        public TypeCode GetColumnType(string columnNmae)
        {
            if (mColumnNameDic == null) return TypeCode.Empty;
            int idx = 0;
            return mColumnNameDic.TryGetValue(columnNmae, out idx) ? mColumnType[idx] : TypeCode.Empty;
        }

        public KTableRowData CreatEmptyData()
        {
            return new KTableRowData(this, null);
        }
        public KTableRowData CreatData(object[] data)
        {
            return new KTableRowData(this, data);
        }

        IEnumerator<TypeCode> IEnumerable<TypeCode>.GetEnumerator()
        {
            for (int i = 0; i < mColumnType.Length; i++)
            {
                yield return mColumnType[i];
            }
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            return mColumnType.GetEnumerator();
        }

        public static bool IsUnSupportedType(TypeCode typeCode)
        {
            return typeCode == TypeCode.Empty || typeCode == TypeCode.Object || typeCode == TypeCode.DBNull || typeCode == TypeCode.DateTime || (int)typeCode > 18;
        }
    }
}