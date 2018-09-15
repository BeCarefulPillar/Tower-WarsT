namespace Sfs2X.Entities.Data
{
    using Sfs2X.Exceptions;
    using Sfs2X.Protocol.Serialization;
    using Sfs2X.Util;
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Text;

    public class SFSArray : ISFSArray, ICollection, IEnumerable
    {
        private List<SFSDataWrapper> dataHolder = new List<SFSDataWrapper>();
        private ISFSDataSerializer serializer = DefaultSFSDataSerializer.Instance;

        public void Add(SFSDataWrapper wrappedObject)
        {
            this.dataHolder.Add(wrappedObject);
        }

        public void AddBool(bool val)
        {
            this.AddObject(val, SFSDataType.BOOL);
        }

        public void AddBoolArray(bool[] val)
        {
            this.AddObject(val, SFSDataType.BOOL_ARRAY);
        }

        public void AddByte(byte val)
        {
            this.AddObject(val, SFSDataType.BYTE);
        }

        public void AddByteArray(ByteArray val)
        {
            this.AddObject(val, SFSDataType.BYTE_ARRAY);
        }

        public void AddClass(object val)
        {
            this.AddObject(val, SFSDataType.CLASS);
        }

        public void AddDouble(double val)
        {
            this.AddObject(val, SFSDataType.DOUBLE);
        }

        public void AddDoubleArray(double[] val)
        {
            this.AddObject(val, SFSDataType.DOUBLE_ARRAY);
        }

        public void AddFloat(float val)
        {
            this.AddObject(val, SFSDataType.FLOAT);
        }

        public void AddFloatArray(float[] val)
        {
            this.AddObject(val, SFSDataType.FLOAT_ARRAY);
        }

        public void AddInt(int val)
        {
            this.AddObject(val, SFSDataType.INT);
        }

        public void AddIntArray(int[] val)
        {
            this.AddObject(val, SFSDataType.INT_ARRAY);
        }

        public void AddLong(long val)
        {
            this.AddObject(val, SFSDataType.LONG);
        }

        public void AddLongArray(long[] val)
        {
            this.AddObject(val, SFSDataType.LONG_ARRAY);
        }

        public void AddNull()
        {
            this.AddObject(null, SFSDataType.NULL);
        }

        private void AddObject(object val, SFSDataType tp)
        {
            this.Add(new SFSDataWrapper((int) tp, val));
        }

        public void AddSFSArray(ISFSArray val)
        {
            this.AddObject(val, SFSDataType.SFS_ARRAY);
        }

        public void AddSFSObject(ISFSObject val)
        {
            this.AddObject(val, SFSDataType.SFS_OBJECT);
        }

        public void AddShort(short val)
        {
            this.AddObject(val, SFSDataType.SHORT);
        }

        public void AddShortArray(short[] val)
        {
            this.AddObject(val, SFSDataType.SHORT_ARRAY);
        }

        public void AddUtfString(string val)
        {
            this.AddObject(val, SFSDataType.UTF_STRING);
        }

        public void AddUtfStringArray(string[] val)
        {
            this.AddObject(val, SFSDataType.UTF_STRING_ARRAY);
        }

        public bool Contains(object obj)
        {
            if ((obj is ISFSArray) || (obj is ISFSObject))
            {
                throw new SFSError("ISFSArray and ISFSObject are not supported by this method.");
            }
            for (int i = 0; i < this.Size(); i++)
            {
                if (object.Equals(this.GetElementAt(i), obj))
                {
                    return true;
                }
            }
            return false;
        }

        private string Dump()
        {
            StringBuilder builder = new StringBuilder(Convert.ToString(DefaultObjectDumpFormatter.TOKEN_INDENT_OPEN));
            for (int i = 0; i < this.dataHolder.Count; i++)
            {
                string dump;
                SFSDataWrapper wrapper = this.dataHolder[i];
                int type = wrapper.Type;
                if (type == 0x12)
                {
                    dump = (wrapper.Data as SFSObject).GetDump(false);
                }
                else if (type == 0x11)
                {
                    dump = (wrapper.Data as SFSArray).GetDump(false);
                }
                else if (type == 0)
                {
                    dump = "NULL";
                }
                else if ((type > 8) && (type < 0x13))
                {
                    dump = "[" + wrapper.Data + "]";
                }
                else
                {
                    dump = wrapper.Data.ToString();
                }
                builder.Append("(" + ((SFSDataType) type).ToString().ToLower() + ") ");
                builder.Append(dump);
                builder.Append(Convert.ToString(DefaultObjectDumpFormatter.TOKEN_DIVIDER));
            }
            string str2 = builder.ToString();
            if (this.Size() > 0)
            {
                str2 = str2.Substring(0, str2.Length - 1);
            }
            return (str2 + Convert.ToString(DefaultObjectDumpFormatter.TOKEN_INDENT_CLOSE));
        }

        private ICollection GetArray(int index)
        {
            return this.GetValue<ICollection>(index);
        }

        public bool GetBool(int index)
        {
            return this.GetValue<bool>(index);
        }

        public bool[] GetBoolArray(int index)
        {
            return (bool[]) this.GetArray(index);
        }

        public byte GetByte(int index)
        {
            return this.GetValue<byte>(index);
        }

        public ByteArray GetByteArray(int index)
        {
            return this.GetValue<ByteArray>(index);
        }

        public object GetClass(int index)
        {
            SFSDataWrapper wrapper = this.dataHolder[index];
            return ((wrapper != null) ? wrapper.Data : null);
        }

        public double GetDouble(int index)
        {
            return this.GetValue<double>(index);
        }

        public double[] GetDoubleArray(int index)
        {
            return (double[]) this.GetArray(index);
        }

        public string GetDump()
        {
            return this.GetDump(true);
        }

        public string GetDump(bool format)
        {
            if (!format)
            {
                return this.Dump();
            }
            return DefaultObjectDumpFormatter.PrettyPrintDump(this.Dump());
        }

        public object GetElementAt(int index)
        {
            object data = null;
            if (this.dataHolder[index] != null)
            {
                data = this.dataHolder[index].Data;
            }
            return data;
        }

        public float GetFloat(int index)
        {
            return this.GetValue<float>(index);
        }

        public float[] GetFloatArray(int index)
        {
            return (float[]) this.GetArray(index);
        }

        public string GetHexDump()
        {
            return DefaultObjectDumpFormatter.HexDump(this.ToBinary());
        }

        public int GetInt(int index)
        {
            return this.GetValue<int>(index);
        }

        public int[] GetIntArray(int index)
        {
            return (int[]) this.GetArray(index);
        }

        public long GetLong(int index)
        {
            return this.GetValue<long>(index);
        }

        public long[] GetLongArray(int index)
        {
            return (long[]) this.GetArray(index);
        }

        public ISFSArray GetSFSArray(int index)
        {
            return this.GetValue<ISFSArray>(index);
        }

        public ISFSObject GetSFSObject(int index)
        {
            return this.GetValue<ISFSObject>(index);
        }

        public short GetShort(int index)
        {
            return this.GetValue<short>(index);
        }

        public short[] GetShortArray(int index)
        {
            return (short[]) this.GetArray(index);
        }

        public string GetUtfString(int index)
        {
            return this.GetValue<string>(index);
        }

        public string[] GetUtfStringArray(int index)
        {
            return (string[]) this.GetArray(index);
        }

        public T GetValue<T>(int index)
        {
            if (index >= this.dataHolder.Count)
            {
                return default(T);
            }
            SFSDataWrapper wrapper = this.dataHolder[index];
            return (T) wrapper.Data;
        }

        public SFSDataWrapper GetWrappedElementAt(int index)
        {
            return this.dataHolder[index];
        }

        public bool IsNull(int index)
        {
            if (index >= this.dataHolder.Count)
            {
                return true;
            }
            SFSDataWrapper wrapper = this.dataHolder[index];
            return (wrapper.Type == 0);
        }

        public static SFSArray NewFromBinaryData(ByteArray ba)
        {
            return (DefaultSFSDataSerializer.Instance.Binary2Array(ba) as SFSArray);
        }

        public static SFSArray NewInstance()
        {
            return new SFSArray();
        }

        public object RemoveElementAt(int index)
        {
            if (index >= this.dataHolder.Count)
            {
                return null;
            }
            SFSDataWrapper wrapper = this.dataHolder[index];
            this.dataHolder.RemoveAt(index);
            return wrapper.Data;
        }

        public int Size()
        {
            return this.dataHolder.Count;
        }

        void ICollection.CopyTo(Array toArray, int index)
        {
            foreach (SFSDataWrapper wrapper in this.dataHolder)
            {
                toArray.SetValue(wrapper, index);
                index++;
            }
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return new SFSArrayEnumerator(this.dataHolder);
        }

        public ByteArray ToBinary()
        {
            return this.serializer.Array2Binary(this);
        }

        int ICollection.Count
        {
            get
            {
                return this.dataHolder.Count;
            }
        }

        bool ICollection.IsSynchronized
        {
            get
            {
                return false;
            }
        }

        object ICollection.SyncRoot
        {
            get
            {
                return this;
            }
        }
    }
}

