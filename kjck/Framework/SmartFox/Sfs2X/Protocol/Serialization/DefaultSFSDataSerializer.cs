namespace Sfs2X.Protocol.Serialization
{
    using Sfs2X.Entities.Data;
    using Sfs2X.Exceptions;
    using Sfs2X.Util;
    using System;
    using System.Collections;
    using System.Reflection;

    public class DefaultSFSDataSerializer : ISFSDataSerializer
    {
        private static readonly string CLASS_FIELDS_KEY = "$F";
        private static readonly string CLASS_MARKER_KEY = "$C";
        private static readonly string FIELD_NAME_KEY = "N";
        private static readonly string FIELD_VALUE_KEY = "V";
        private static DefaultSFSDataSerializer instance;
        private static Assembly runningAssembly = null;

        private DefaultSFSDataSerializer()
        {
        }

        private ByteArray AddData(ByteArray buffer, ByteArray newData)
        {
            buffer.WriteBytes(newData.Bytes);
            return buffer;
        }

        private ByteArray Arr2bin(ISFSArray array, ByteArray buffer)
        {
            for (int i = 0; i < array.Size(); i++)
            {
                SFSDataWrapper wrappedElementAt = array.GetWrappedElementAt(i);
                buffer = this.EncodeObject(buffer, wrappedElementAt.Type, wrappedElementAt.Data);
            }
            return buffer;
        }

        public ByteArray Array2Binary(ISFSArray array)
        {
            ByteArray buffer = new ByteArray();
            buffer.WriteByte(Convert.ToByte(0x11));
            buffer.WriteShort(Convert.ToInt16(array.Size()));
            return this.Arr2bin(array, buffer);
        }

        public ISFSArray Binary2Array(ByteArray data)
        {
            if (data.Length < 3)
            {
                throw new SFSCodecError("Can't decode an SFSArray. Byte data is insufficient. Size: " + data.Length + " byte(s)");
            }
            data.Position = 0;
            return this.DecodeSFSArray(data);
        }

        public ISFSObject Binary2Object(ByteArray data)
        {
            if (data.Length < 3)
            {
                throw new SFSCodecError("Can't decode an SFSObject. Byte data is insufficient. Size: " + data.Length + " byte(s)");
            }
            data.Position = 0;
            return this.DecodeSFSObject(data);
        }

        private SFSDataWrapper BinDecode_BOOL(ByteArray buffer)
        {
            return new SFSDataWrapper(SFSDataType.BOOL, buffer.ReadBool());
        }

        private SFSDataWrapper BinDecode_BOOL_ARRAY(ByteArray buffer)
        {
            int typedArraySize = this.GetTypedArraySize(buffer);
            bool[] data = new bool[typedArraySize];
            for (int i = 0; i < typedArraySize; i++)
            {
                data[i] = buffer.ReadBool();
            }
            return new SFSDataWrapper(SFSDataType.BOOL_ARRAY, data);
        }

        private SFSDataWrapper BinDecode_BYTE(ByteArray buffer)
        {
            return new SFSDataWrapper(SFSDataType.BYTE, buffer.ReadByte());
        }

        private SFSDataWrapper BinDecode_BYTE_ARRAY(ByteArray buffer)
        {
            int count = buffer.ReadInt();
            if (count < 0)
            {
                throw new SFSCodecError("Array negative size: " + count);
            }
            return new SFSDataWrapper(SFSDataType.BYTE_ARRAY, new ByteArray(buffer.ReadBytes(count)));
        }

        private SFSDataWrapper BinDecode_DOUBLE(ByteArray buffer)
        {
            return new SFSDataWrapper(SFSDataType.DOUBLE, buffer.ReadDouble());
        }

        private SFSDataWrapper BinDecode_DOUBLE_ARRAY(ByteArray buffer)
        {
            int typedArraySize = this.GetTypedArraySize(buffer);
            double[] data = new double[typedArraySize];
            for (int i = 0; i < typedArraySize; i++)
            {
                data[i] = buffer.ReadDouble();
            }
            return new SFSDataWrapper(SFSDataType.DOUBLE_ARRAY, data);
        }

        private SFSDataWrapper BinDecode_FLOAT(ByteArray buffer)
        {
            return new SFSDataWrapper(SFSDataType.FLOAT, buffer.ReadFloat());
        }

        private SFSDataWrapper BinDecode_FLOAT_ARRAY(ByteArray buffer)
        {
            int typedArraySize = this.GetTypedArraySize(buffer);
            float[] data = new float[typedArraySize];
            for (int i = 0; i < typedArraySize; i++)
            {
                data[i] = buffer.ReadFloat();
            }
            return new SFSDataWrapper(SFSDataType.FLOAT_ARRAY, data);
        }

        private SFSDataWrapper BinDecode_INT(ByteArray buffer)
        {
            return new SFSDataWrapper(SFSDataType.INT, buffer.ReadInt());
        }

        private SFSDataWrapper BinDecode_INT_ARRAY(ByteArray buffer)
        {
            int typedArraySize = this.GetTypedArraySize(buffer);
            int[] data = new int[typedArraySize];
            for (int i = 0; i < typedArraySize; i++)
            {
                data[i] = buffer.ReadInt();
            }
            return new SFSDataWrapper(SFSDataType.INT_ARRAY, data);
        }

        private SFSDataWrapper BinDecode_LONG(ByteArray buffer)
        {
            return new SFSDataWrapper(SFSDataType.LONG, buffer.ReadLong());
        }

        private SFSDataWrapper BinDecode_LONG_ARRAY(ByteArray buffer)
        {
            int typedArraySize = this.GetTypedArraySize(buffer);
            long[] data = new long[typedArraySize];
            for (int i = 0; i < typedArraySize; i++)
            {
                data[i] = buffer.ReadLong();
            }
            return new SFSDataWrapper(SFSDataType.LONG_ARRAY, data);
        }

        private SFSDataWrapper BinDecode_NULL(ByteArray buffer)
        {
            return new SFSDataWrapper(SFSDataType.NULL, null);
        }

        private SFSDataWrapper BinDecode_SHORT(ByteArray buffer)
        {
            return new SFSDataWrapper(SFSDataType.SHORT, buffer.ReadShort());
        }

        private SFSDataWrapper BinDecode_SHORT_ARRAY(ByteArray buffer)
        {
            int typedArraySize = this.GetTypedArraySize(buffer);
            short[] data = new short[typedArraySize];
            for (int i = 0; i < typedArraySize; i++)
            {
                data[i] = buffer.ReadShort();
            }
            return new SFSDataWrapper(SFSDataType.SHORT_ARRAY, data);
        }

        private SFSDataWrapper BinDecode_UTF_STRING(ByteArray buffer)
        {
            return new SFSDataWrapper(SFSDataType.UTF_STRING, buffer.ReadUTF());
        }

        private SFSDataWrapper BinDecode_UTF_STRING_ARRAY(ByteArray buffer)
        {
            int typedArraySize = this.GetTypedArraySize(buffer);
            string[] data = new string[typedArraySize];
            for (int i = 0; i < typedArraySize; i++)
            {
                data[i] = buffer.ReadUTF();
            }
            return new SFSDataWrapper(SFSDataType.UTF_STRING_ARRAY, data);
        }

        private ByteArray BinEncode_BOOL(ByteArray buffer, bool val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.BOOL);
            newData.WriteBool(val);
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_BOOL_ARRAY(ByteArray buffer, bool[] val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.BOOL_ARRAY);
            newData.WriteShort(Convert.ToInt16(val.Length));
            for (int i = 0; i < val.Length; i++)
            {
                newData.WriteBool(val[i]);
            }
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_BYTE(ByteArray buffer, byte val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.BYTE);
            newData.WriteByte(val);
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_BYTE_ARRAY(ByteArray buffer, ByteArray val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.BYTE_ARRAY);
            newData.WriteInt(val.Length);
            newData.WriteBytes(val.Bytes);
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_DOUBLE(ByteArray buffer, double val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.DOUBLE);
            newData.WriteDouble(val);
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_DOUBLE_ARRAY(ByteArray buffer, double[] val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.DOUBLE_ARRAY);
            newData.WriteShort(Convert.ToInt16(val.Length));
            for (int i = 0; i < val.Length; i++)
            {
                newData.WriteDouble(val[i]);
            }
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_FLOAT(ByteArray buffer, float val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.FLOAT);
            newData.WriteFloat(val);
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_FLOAT_ARRAY(ByteArray buffer, float[] val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.FLOAT_ARRAY);
            newData.WriteShort(Convert.ToInt16(val.Length));
            for (int i = 0; i < val.Length; i++)
            {
                newData.WriteFloat(val[i]);
            }
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_INT(ByteArray buffer, double val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.DOUBLE);
            newData.WriteDouble(val);
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_INT(ByteArray buffer, int val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.INT);
            newData.WriteInt(val);
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_INT_ARRAY(ByteArray buffer, int[] val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.INT_ARRAY);
            newData.WriteShort(Convert.ToInt16(val.Length));
            for (int i = 0; i < val.Length; i++)
            {
                newData.WriteInt(val[i]);
            }
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_LONG(ByteArray buffer, long val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.LONG);
            newData.WriteLong(val);
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_LONG_ARRAY(ByteArray buffer, long[] val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.LONG_ARRAY);
            newData.WriteShort(Convert.ToInt16(val.Length));
            for (int i = 0; i < val.Length; i++)
            {
                newData.WriteLong(val[i]);
            }
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_NULL(ByteArray buffer)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte((byte) 0);
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_SHORT(ByteArray buffer, short val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.SHORT);
            newData.WriteShort(val);
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_SHORT_ARRAY(ByteArray buffer, short[] val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.SHORT_ARRAY);
            newData.WriteShort(Convert.ToInt16(val.Length));
            for (int i = 0; i < val.Length; i++)
            {
                newData.WriteShort(val[i]);
            }
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_UTF_STRING(ByteArray buffer, string val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.UTF_STRING);
            newData.WriteUTF(val);
            return this.AddData(buffer, newData);
        }

        private ByteArray BinEncode_UTF_STRING_ARRAY(ByteArray buffer, string[] val)
        {
            ByteArray newData = new ByteArray();
            newData.WriteByte(SFSDataType.UTF_STRING_ARRAY);
            newData.WriteShort(Convert.ToInt16(val.Length));
            for (int i = 0; i < val.Length; i++)
            {
                newData.WriteUTF(val[i]);
            }
            return this.AddData(buffer, newData);
        }

        private void ConvertCsObj(object csObj, ISFSObject sfsObj)
        {
            Type type = csObj.GetType();
            string fullName = type.FullName;
            SerializableSFSType type2 = csObj as SerializableSFSType;
            if (type2 == null)
            {
                throw new SFSCodecError(string.Concat(new object[] { "Cannot serialize object: ", csObj, ", type: ", fullName, " -- It doesn't implement the SerializableSFSType interface" }));
            }
            ISFSArray val = SFSArray.NewInstance();
            sfsObj.PutUtfString(CLASS_MARKER_KEY, fullName);
            sfsObj.PutSFSArray(CLASS_FIELDS_KEY, val);
            FieldInfo[] fields = type.GetFields(BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance);
            foreach (FieldInfo info in fields)
            {
                string name = info.Name;
                object obj2 = info.GetValue(csObj);
                ISFSObject obj3 = SFSObject.NewInstance();
                SFSDataWrapper wrapper = this.WrapField(obj2);
                if (wrapper == null)
                {
                    throw new SFSCodecError(string.Concat(new object[] { "Cannot serialize field of object: ", csObj, ", field: ", name, ", type: ", info.GetType().Name, " -- unsupported type!" }));
                }
                obj3.PutUtfString(FIELD_NAME_KEY, name);
                obj3.Put(FIELD_VALUE_KEY, wrapper);
                val.AddSFSObject(obj3);
            }
        }

        private void ConvertSFSObject(ISFSArray fieldList, object csObj, Type objType)
        {
            for (int i = 0; i < fieldList.Size(); i++)
            {
                ISFSObject sFSObject = fieldList.GetSFSObject(i);
                string utfString = sFSObject.GetUtfString(FIELD_NAME_KEY);
                SFSDataWrapper data = sFSObject.GetData(FIELD_VALUE_KEY);
                object obj3 = this.UnwrapField(data);
                FieldInfo field = objType.GetField(utfString, BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance);
                if (field != null)
                {
                    field.SetValue(csObj, obj3);
                }
            }
        }

        public ISFSObject Cs2Sfs(object csObj)
        {
            ISFSObject sfsObj = SFSObject.NewInstance();
            this.ConvertCsObj(csObj, sfsObj);
            return sfsObj;
        }

        private SFSDataWrapper DecodeObject(ByteArray buffer)
        {
            SFSDataType type = (SFSDataType) Convert.ToInt32(buffer.ReadByte());
            switch (type)
            {
                case SFSDataType.NULL:
                    return this.BinDecode_NULL(buffer);

                case SFSDataType.BOOL:
                    return this.BinDecode_BOOL(buffer);

                case SFSDataType.BOOL_ARRAY:
                    return this.BinDecode_BOOL_ARRAY(buffer);

                case SFSDataType.BYTE:
                    return this.BinDecode_BYTE(buffer);

                case SFSDataType.BYTE_ARRAY:
                    return this.BinDecode_BYTE_ARRAY(buffer);

                case SFSDataType.SHORT:
                    return this.BinDecode_SHORT(buffer);

                case SFSDataType.SHORT_ARRAY:
                    return this.BinDecode_SHORT_ARRAY(buffer);

                case SFSDataType.INT:
                    return this.BinDecode_INT(buffer);

                case SFSDataType.INT_ARRAY:
                    return this.BinDecode_INT_ARRAY(buffer);

                case SFSDataType.LONG:
                    return this.BinDecode_LONG(buffer);

                case SFSDataType.LONG_ARRAY:
                    return this.BinDecode_LONG_ARRAY(buffer);

                case SFSDataType.FLOAT:
                    return this.BinDecode_FLOAT(buffer);

                case SFSDataType.FLOAT_ARRAY:
                    return this.BinDecode_FLOAT_ARRAY(buffer);

                case SFSDataType.DOUBLE:
                    return this.BinDecode_DOUBLE(buffer);

                case SFSDataType.DOUBLE_ARRAY:
                    return this.BinDecode_DOUBLE_ARRAY(buffer);

                case SFSDataType.UTF_STRING:
                    return this.BinDecode_UTF_STRING(buffer);

                case SFSDataType.UTF_STRING_ARRAY:
                    return this.BinDecode_UTF_STRING_ARRAY(buffer);

                case SFSDataType.SFS_ARRAY:
                    buffer.Position--;
                    return new SFSDataWrapper(0x11, this.DecodeSFSArray(buffer));
            }
            if (type != SFSDataType.SFS_OBJECT)
            {
                throw new Exception("Unknow SFSDataType ID: " + type);
            }
            buffer.Position--;
            ISFSObject sfsObj = this.DecodeSFSObject(buffer);
            byte num = Convert.ToByte(0x12);
            object data = sfsObj;
            if (sfsObj.ContainsKey(CLASS_MARKER_KEY) && sfsObj.ContainsKey(CLASS_FIELDS_KEY))
            {
                num = Convert.ToByte(0x13);
                data = this.Sfs2Cs(sfsObj);
            }
            return new SFSDataWrapper(num, data);
        }

        private ISFSArray DecodeSFSArray(ByteArray buffer)
        {
            ISFSArray array = SFSArray.NewInstance();
            SFSDataType type = (SFSDataType) Convert.ToInt32(buffer.ReadByte());
            if (type != SFSDataType.SFS_ARRAY)
            {
                throw new SFSCodecError(string.Concat(new object[] { "Invalid SFSDataType. Expected: ", SFSDataType.SFS_ARRAY, ", found: ", type }));
            }
            int num = buffer.ReadShort();
            if (num < 0)
            {
                throw new SFSCodecError("Can't decode SFSArray. Size is negative: " + num);
            }
            try
            {
                for (int i = 0; i < num; i++)
                {
                    SFSDataWrapper val = this.DecodeObject(buffer);
                    if (val == null)
                    {
                        throw new SFSCodecError("Could not decode SFSArray item at index: " + i);
                    }
                    array.Add(val);
                }
            }
            catch (SFSCodecError error)
            {
                throw error;
            }
            return array;
        }

        private ISFSObject DecodeSFSObject(ByteArray buffer)
        {
            SFSObject obj2 = SFSObject.NewInstance();
            byte num = buffer.ReadByte();
            if (num != Convert.ToByte(0x12))
            {
                throw new SFSCodecError(string.Concat(new object[] { "Invalid SFSDataType. Expected: ", SFSDataType.SFS_OBJECT, ", found: ", num }));
            }
            int num2 = buffer.ReadShort();
            if (num2 < 0)
            {
                throw new SFSCodecError("Can't decode SFSObject. Size is negative: " + num2);
            }
            try
            {
                for (int i = 0; i < num2; i++)
                {
                    string key = buffer.ReadUTF();
                    SFSDataWrapper val = this.DecodeObject(buffer);
                    if (val == null)
                    {
                        throw new SFSCodecError("Could not decode value for SFSObject with key: " + key);
                    }
                    obj2.Put(key, val);
                }
            }
            catch (SFSCodecError error)
            {
                throw error;
            }
            return obj2;
        }

        private ByteArray EncodeObject(ByteArray buffer, int typeId, object data)
        {
            switch (((SFSDataType) typeId))
            {
                case SFSDataType.NULL:
                    buffer = this.BinEncode_NULL(buffer);
                    return buffer;

                case SFSDataType.BOOL:
                    buffer = this.BinEncode_BOOL(buffer, (bool) data);
                    return buffer;

                case SFSDataType.BYTE:
                    buffer = this.BinEncode_BYTE(buffer, (byte) data);
                    return buffer;

                case SFSDataType.SHORT:
                    buffer = this.BinEncode_SHORT(buffer, (short) data);
                    return buffer;

                case SFSDataType.INT:
                    buffer = this.BinEncode_INT(buffer, (int) data);
                    return buffer;

                case SFSDataType.LONG:
                    buffer = this.BinEncode_LONG(buffer, (long) data);
                    return buffer;

                case SFSDataType.FLOAT:
                    buffer = this.BinEncode_FLOAT(buffer, (float) data);
                    return buffer;

                case SFSDataType.DOUBLE:
                    buffer = this.BinEncode_DOUBLE(buffer, (double) data);
                    return buffer;

                case SFSDataType.UTF_STRING:
                    buffer = this.BinEncode_UTF_STRING(buffer, (string) data);
                    return buffer;

                case SFSDataType.BOOL_ARRAY:
                    buffer = this.BinEncode_BOOL_ARRAY(buffer, (bool[]) data);
                    return buffer;

                case SFSDataType.BYTE_ARRAY:
                    buffer = this.BinEncode_BYTE_ARRAY(buffer, (ByteArray) data);
                    return buffer;

                case SFSDataType.SHORT_ARRAY:
                    buffer = this.BinEncode_SHORT_ARRAY(buffer, (short[]) data);
                    return buffer;

                case SFSDataType.INT_ARRAY:
                    buffer = this.BinEncode_INT_ARRAY(buffer, (int[]) data);
                    return buffer;

                case SFSDataType.LONG_ARRAY:
                    buffer = this.BinEncode_LONG_ARRAY(buffer, (long[]) data);
                    return buffer;

                case SFSDataType.FLOAT_ARRAY:
                    buffer = this.BinEncode_FLOAT_ARRAY(buffer, (float[]) data);
                    return buffer;

                case SFSDataType.DOUBLE_ARRAY:
                    buffer = this.BinEncode_DOUBLE_ARRAY(buffer, (double[]) data);
                    return buffer;

                case SFSDataType.UTF_STRING_ARRAY:
                    buffer = this.BinEncode_UTF_STRING_ARRAY(buffer, (string[]) data);
                    return buffer;

                case SFSDataType.SFS_ARRAY:
                    buffer = this.AddData(buffer, this.Array2Binary((ISFSArray) data));
                    return buffer;

                case SFSDataType.SFS_OBJECT:
                    buffer = this.AddData(buffer, this.Object2Binary((SFSObject) data));
                    return buffer;

                case SFSDataType.CLASS:
                    buffer = this.AddData(buffer, this.Object2Binary(this.Cs2Sfs(data)));
                    return buffer;
            }
            throw new SFSCodecError("Unrecognized type in SFSObject serialization: " + typeId);
        }

        private ByteArray EncodeSFSObjectKey(ByteArray buffer, string val)
        {
            buffer.WriteUTF(val);
            return buffer;
        }

        private int GetTypedArraySize(ByteArray buffer)
        {
            short num = buffer.ReadShort();
            if (num < 0)
            {
                throw new SFSCodecError("Array negative size: " + num);
            }
            return num;
        }

        private ByteArray Obj2bin(ISFSObject obj, ByteArray buffer)
        {
            string[] keys = obj.GetKeys();
            foreach (string str in keys)
            {
                SFSDataWrapper data = obj.GetData(str);
                buffer = this.EncodeSFSObjectKey(buffer, str);
                buffer = this.EncodeObject(buffer, data.Type, data.Data);
            }
            return buffer;
        }

        public ByteArray Object2Binary(ISFSObject obj)
        {
            ByteArray buffer = new ByteArray();
            buffer.WriteByte(Convert.ToByte(0x12));
            buffer.WriteShort(Convert.ToInt16(obj.Size()));
            return this.Obj2bin(obj, buffer);
        }

        private ArrayList RebuildArray(ISFSArray sfsArr)
        {
            ArrayList list = new ArrayList();
            for (int i = 0; i < sfsArr.Size(); i++)
            {
                list.Add(this.UnwrapField(sfsArr.GetWrappedElementAt(i)));
            }
            return list;
        }

        private Hashtable RebuildDict(ISFSObject sfsObj)
        {
            Hashtable hashtable = new Hashtable();
            foreach (string str in sfsObj.GetKeys())
            {
                hashtable[str] = this.UnwrapField(sfsObj.GetData(str));
            }
            return hashtable;
        }

        public object Sfs2Cs(ISFSObject sfsObj)
        {
            if (!(sfsObj.ContainsKey(CLASS_MARKER_KEY) && sfsObj.ContainsKey(CLASS_FIELDS_KEY)))
            {
                throw new SFSCodecError("The SFSObject passed does not represent any serialized class.");
            }
            string utfString = sfsObj.GetUtfString(CLASS_MARKER_KEY);
            Type type = null;
            if (runningAssembly == null)
            {
                type = Type.GetType(utfString);
            }
            else
            {
                type = runningAssembly.GetType(utfString);
            }
            if (type == null)
            {
                throw new SFSCodecError("Cannot find type: " + utfString);
            }
            object csObj = Activator.CreateInstance(type);
            if (!(csObj is SerializableSFSType))
            {
                throw new SFSCodecError(string.Concat(new object[] { "Cannot deserialize object: ", csObj, ", type: ", utfString, " -- It doesn't implement the SerializableSFSType interface" }));
            }
            this.ConvertSFSObject(sfsObj.GetSFSArray(CLASS_FIELDS_KEY), csObj, type);
            return csObj;
        }

        private ISFSArray UnrollArray(ArrayList arr)
        {
            ISFSArray array = SFSArray.NewInstance();
            foreach (object obj2 in arr)
            {
                SFSDataWrapper val = this.WrapField(obj2);
                if (val == null)
                {
                    throw new SFSCodecError("Cannot serialize field of array: " + obj2 + " -- unsupported type!");
                }
                array.Add(val);
            }
            return array;
        }

        private ISFSObject UnrollDictionary(Hashtable dict)
        {
            ISFSObject obj2 = SFSObject.NewInstance();
            foreach (string str in dict.Keys)
            {
                SFSDataWrapper val = this.WrapField(dict[str]);
                if (val == null)
                {
                    throw new SFSCodecError(string.Concat(new object[] { "Cannot serialize field of dictionary with key: ", str, ", ", dict[str], " -- unsupported type!" }));
                }
                obj2.Put(str, val);
            }
            return obj2;
        }

        private object UnwrapField(SFSDataWrapper wrapper)
        {
            int type = wrapper.Type;
            if (type <= 8)
            {
                return wrapper.Data;
            }
            switch (type)
            {
                case 0x11:
                    return this.RebuildArray(wrapper.Data as ISFSArray);

                case 0x12:
                {
                    ISFSObject data = wrapper.Data as ISFSObject;
                    if (data.ContainsKey(CLASS_MARKER_KEY) && data.ContainsKey(CLASS_FIELDS_KEY))
                    {
                        return this.Sfs2Cs(data);
                    }
                    return this.RebuildDict(wrapper.Data as ISFSObject);
                }
                case 0x13:
                    return wrapper.Data;
            }
            return null;
        }

        private SFSDataWrapper WrapField(object val)
        {
            if (val == null)
            {
                return new SFSDataWrapper(SFSDataType.NULL, null);
            }
            SFSDataWrapper wrapper = null;
            if (val is bool)
            {
                wrapper = new SFSDataWrapper(SFSDataType.BOOL, val);
            }
            else
            {
                if (val is byte)
                {
                    return new SFSDataWrapper(SFSDataType.BYTE, val);
                }
                if (val is short)
                {
                    return new SFSDataWrapper(SFSDataType.SHORT, val);
                }
                if (val is int)
                {
                    return new SFSDataWrapper(SFSDataType.INT, val);
                }
                if (val is long)
                {
                    return new SFSDataWrapper(SFSDataType.LONG, val);
                }
                if (val is float)
                {
                    return new SFSDataWrapper(SFSDataType.FLOAT, val);
                }
                if (val is double)
                {
                    return new SFSDataWrapper(SFSDataType.DOUBLE, val);
                }
                if (val is string)
                {
                    return new SFSDataWrapper(SFSDataType.UTF_STRING, val);
                }
                if (val is ArrayList)
                {
                    return new SFSDataWrapper(SFSDataType.SFS_ARRAY, this.UnrollArray(val as ArrayList));
                }
                if (val is SerializableSFSType)
                {
                    wrapper = new SFSDataWrapper(SFSDataType.SFS_OBJECT, this.Cs2Sfs(val));
                }
                else if (val is Hashtable)
                {
                    wrapper = new SFSDataWrapper(SFSDataType.SFS_OBJECT, this.UnrollDictionary(val as Hashtable));
                }
            }
            return wrapper;
        }

        public static DefaultSFSDataSerializer Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new DefaultSFSDataSerializer();
                }
                return instance;
            }
        }

        public static Assembly RunningAssembly
        {
            get
            {
                return runningAssembly;
            }
            set
            {
                runningAssembly = value;
            }
        }
    }
}

