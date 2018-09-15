using System;
using System.Collections;
using System.Collections.Generic;

namespace Kiol.IO.Table
{
    public class KTable : IList<KTableRowData>
    {
        private KTableRow mRow;
        private KTableRowData mRowData;
        private List<object[]> dataList;

        public KTable(KTableRow row, int capactiy)
        {
            if (row == null)
            {
                throw new ArgumentNullException("creat ktable, the row must not be null");
            }
            mRow = row;
            mRowData = row.CreatEmptyData();
            dataList = new List<object[]>(capactiy);
        }

        public KTableRow row { get { return mRow; } }
        public KTableRowData rowTemplate { get { return mRowData; } }

        public int IndexOf(KTableRowData item)
        {
            return dataList.IndexOf(item.data);
        }

        public void Insert(int index, KTableRowData item)
        {
            if (item.row != mRow)
            {
                throw new ArgumentException("insert row not match table row");
            }
            Insert(index, item.data);
        }
        public void Insert(int index, object[] data)
        {
            if (data == null)
            {
                throw new ArgumentNullException("add row data can not null");
            }
            if (data.Length != mRow.columnNum)
            {
                throw new ArgumentNullException("add row data length not match");
            }
            dataList.Insert(index, data);
        }
        public void RemoveAt(int index)
        {
            dataList.RemoveAt(index);
        }

        public KTableRowData this[int index]
        {
            get
            {
                mRowData.SetDataDit(dataList[index]);
                return mRowData;
            }
            set
            {
                if (value.row != mRow)
                {
                    throw new ArgumentException("set row not match table row");
                }
                if (value.data != null && value.data.Length == mRow.columnNum)
                {
                    dataList[index] = value.data;
                }
            }
        }

        public IEnumerator GetEnumerator()
        {
            for (int i = 0; i < dataList.Count; i++)
            {
                yield return this[i];
            }
        }

        public void Add(KTableRowData item)
        {
            if (item.row != mRow)
            {
                throw new ArgumentException("add row not match table row");
            }
            Add(item.data);
        }
        public void Add(object[] data)
        {
            if (data == null)
            {
                throw new ArgumentNullException("add row data can not null");
            }
            if (data.Length != mRow.columnNum)
            {
                throw new ArgumentNullException("add row data length not match");
            }
            dataList.Add(data);
        }

        public void Clear()
        {
            dataList.Clear();
            mRowData.SetDataDit(null);
        }

        public bool Contains(KTableRowData item)
        {
            return Find(item) >= 0;
        }

        public void CopyTo(KTableRowData[] array, int arrayIndex)
        {
            if (array == null) return;
            int size = Math.Min(array.Length - arrayIndex, dataList.Count);
            for (int i = 0; i < size; i++, arrayIndex++)
            {
                array[arrayIndex] = new KTableRowData(mRow, null);
                array[arrayIndex].SetDataDit(dataList[i]);
            }
        }

        public int Count { get { return dataList.Count; } }

        public bool IsReadOnly { get { return false; } }

        public bool Remove(KTableRowData item)
        {
            int idx = Find(item);
            if (idx < 0) return false;
            dataList.RemoveAt(idx);
            return true;
        }

        IEnumerator<KTableRowData> IEnumerable<KTableRowData>.GetEnumerator()
        {
            for (int i = 0; i < dataList.Count; i++)
            {
                yield return this[i];
            }
        }

        private int Find(KTableRowData item)
        {
            return (item != null || item.row == mRow) ? Find(item.data) : -1;
        }
        private int Find(object[] data)
        {
            for (int i = 0; i < dataList.Count; i++)
            {
                if (Equals(data, dataList[i]))
                {
                    return i;
                }
            }
            return -1;
        }

        private bool Equals(object[] dl, object[] dr)
        {
            if (dl == null) return dr == null;
            if (dr == null) return false;
            if (dl.Length != dr.Length) return false;
            for (int i = 0; i < dl.Length; i++)
            {
                if (dl[i] != dr[i]) return false;
            }
            return true;
        }
    }
}