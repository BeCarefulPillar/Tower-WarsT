namespace Sfs2X.Entities.Data
{
    using Sfs2X.Protocol.Serialization;
    using Sfs2X.Util;
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Text;

    public class SFSObject : ISFSObject
    {
        private Dictionary<string, SFSDataWrapper> dataHolder = new Dictionary<string, SFSDataWrapper>();
        private ISFSDataSerializer serializer = DefaultSFSDataSerializer.Instance;

        public bool ContainsKey(string key)
        {
            return this.dataHolder.ContainsKey(key);
        }

        private string Dump()
        {
            StringBuilder builder = new StringBuilder();
            builder.Append(Convert.ToString(DefaultObjectDumpFormatter.TOKEN_INDENT_OPEN));
            foreach (KeyValuePair<string, SFSDataWrapper> pair in this.dataHolder)
            {
                SFSDataWrapper wrapper = pair.Value;
                string key = pair.Key;
                int type = wrapper.Type;
                builder.Append("(" + ((SFSDataType) type).ToString().ToLower() + ")");
                builder.Append(" " + key + ": ");
                if (type == 0x12)
                {
                    builder.Append((wrapper.Data as SFSObject).GetDump(false));
                }
                else if (type == 0x11)
                {
                    builder.Append((wrapper.Data as SFSArray).GetDump(false));
                }
                else if ((type > 8) && (type < 0x13))
                {
                    builder.Append("[" + wrapper.Data + "]");
                }
                else
                {
                    builder.Append(wrapper.Data);
                }
                builder.Append(DefaultObjectDumpFormatter.TOKEN_DIVIDER);
            }
            string str2 = builder.ToString();
            if (this.Size() > 0)
            {
                str2 = str2.Substring(0, str2.Length - 1);
            }
            return (str2 + DefaultObjectDumpFormatter.TOKEN_INDENT_CLOSE);
        }

        private ICollection GetArray(string key)
        {
            return this.GetValue<ICollection>(key);
        }

        public bool GetBool(string key)
        {
            return this.GetValue<bool>(key);
        }

        public bool[] GetBoolArray(string key)
        {
            return (bool[]) this.GetArray(key);
        }

        public byte GetByte(string key)
        {
            return this.GetValue<byte>(key);
        }

        public ByteArray GetByteArray(string key)
        {
            return this.GetValue<ByteArray>(key);
        }

        public object GetClass(string key)
        {
            SFSDataWrapper wrapper = this.dataHolder[key];
            if (wrapper != null)
            {
                return wrapper.Data;
            }
            return null;
        }

        public SFSDataWrapper GetData(string key)
        {
            return this.dataHolder[key];
        }

        public double GetDouble(string key)
        {
            return this.GetValue<double>(key);
        }

        public double[] GetDoubleArray(string key)
        {
            return (double[]) this.GetArray(key);
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

        public float GetFloat(string key)
        {
            return this.GetValue<float>(key);
        }

        public float[] GetFloatArray(string key)
        {
            return (float[]) this.GetArray(key);
        }

        public string GetHexDump()
        {
            return DefaultObjectDumpFormatter.HexDump(this.ToBinary());
        }

        public int GetInt(string key)
        {
            return this.GetValue<int>(key);
        }

        public int[] GetIntArray(string key)
        {
            return (int[]) this.GetArray(key);
        }

        public string[] GetKeys()
        {
            string[] array = new string[this.dataHolder.Keys.Count];
            this.dataHolder.Keys.CopyTo(array, 0);
            return array;
        }

        public long GetLong(string key)
        {
            return this.GetValue<long>(key);
        }

        public long[] GetLongArray(string key)
        {
            return (long[]) this.GetArray(key);
        }

        public ISFSArray GetSFSArray(string key)
        {
            return this.GetValue<ISFSArray>(key);
        }

        public ISFSObject GetSFSObject(string key)
        {
            return this.GetValue<ISFSObject>(key);
        }

        public short GetShort(string key)
        {
            return this.GetValue<short>(key);
        }

        public short[] GetShortArray(string key)
        {
            return (short[]) this.GetArray(key);
        }

        public string GetUtfString(string key)
        {
            return this.GetValue<string>(key);
        }

        public string[] GetUtfStringArray(string key)
        {
            return (string[]) this.GetArray(key);
        }

        public T GetValue<T>(string key)
        {
            if (!this.dataHolder.ContainsKey(key))
            {
                return default(T);
            }
            return (T) this.dataHolder[key].Data;
        }

        public bool IsNull(string key)
        {
            return (!this.ContainsKey(key) || (this.GetData(key).Data == null));
        }

        public static SFSObject NewFromBinaryData(ByteArray ba)
        {
            return (DefaultSFSDataSerializer.Instance.Binary2Object(ba) as SFSObject);
        }

        public static SFSObject NewInstance()
        {
            return new SFSObject();
        }

        public void Put(string key, SFSDataWrapper val)
        {
            this.dataHolder[key] = val;
        }

        public void PutBool(string key, bool val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.BOOL, val);
        }

        public void PutBoolArray(string key, bool[] val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.BOOL_ARRAY, val);
        }

        public void PutByte(string key, byte val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.BYTE, val);
        }

        public void PutByteArray(string key, ByteArray val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.BYTE_ARRAY, val);
        }

        public void PutClass(string key, object val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.CLASS, val);
        }

        public void PutDouble(string key, double val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.DOUBLE, val);
        }

        public void PutDoubleArray(string key, double[] val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.DOUBLE_ARRAY, val);
        }

        public void PutFloat(string key, float val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.FLOAT, val);
        }

        public void PutFloatArray(string key, float[] val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.FLOAT_ARRAY, val);
        }

        public void PutInt(string key, int val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.INT, val);
        }

        public void PutIntArray(string key, int[] val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.INT_ARRAY, val);
        }

        public void PutLong(string key, long val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.LONG, val);
        }

        public void PutLongArray(string key, long[] val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.LONG_ARRAY, val);
        }

        public void PutNull(string key)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.NULL, null);
        }

        public void PutSFSArray(string key, ISFSArray val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.SFS_ARRAY, val);
        }

        public void PutSFSObject(string key, ISFSObject val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.SFS_OBJECT, val);
        }

        public void PutShort(string key, short val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.SHORT, val);
        }

        public void PutShortArray(string key, short[] val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.SHORT_ARRAY, val);
        }

        public void PutUtfString(string key, string val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.UTF_STRING, val);
        }

        public void PutUtfStringArray(string key, string[] val)
        {
            this.dataHolder[key] = new SFSDataWrapper(SFSDataType.UTF_STRING_ARRAY, val);
        }

        public void RemoveElement(string key)
        {
            this.dataHolder.Remove(key);
        }

        public int Size()
        {
            return this.dataHolder.Count;
        }

        public ByteArray ToBinary()
        {
            return this.serializer.Object2Binary(this);
        }
    }
}

