namespace Sfs2X.Entities.Data
{
    using Sfs2X.Util;
    using System;
    using System.Collections;

    public interface ISFSArray : ICollection, IEnumerable
    {
        void Add(SFSDataWrapper val);
        void AddBool(bool val);
        void AddBoolArray(bool[] val);
        void AddByte(byte val);
        void AddByteArray(ByteArray val);
        void AddClass(object val);
        void AddDouble(double val);
        void AddDoubleArray(double[] val);
        void AddFloat(float val);
        void AddFloatArray(float[] val);
        void AddInt(int val);
        void AddIntArray(int[] val);
        void AddLong(long val);
        void AddLongArray(long[] val);
        void AddNull();
        void AddSFSArray(ISFSArray val);
        void AddSFSObject(ISFSObject val);
        void AddShort(short val);
        void AddShortArray(short[] val);
        void AddUtfString(string val);
        void AddUtfStringArray(string[] val);
        bool Contains(object obj);
        bool GetBool(int index);
        bool[] GetBoolArray(int index);
        byte GetByte(int index);
        ByteArray GetByteArray(int index);
        object GetClass(int index);
        double GetDouble(int index);
        double[] GetDoubleArray(int index);
        string GetDump();
        string GetDump(bool format);
        object GetElementAt(int index);
        float GetFloat(int index);
        float[] GetFloatArray(int index);
        string GetHexDump();
        int GetInt(int index);
        int[] GetIntArray(int index);
        long GetLong(int index);
        long[] GetLongArray(int index);
        ISFSArray GetSFSArray(int index);
        ISFSObject GetSFSObject(int index);
        short GetShort(int index);
        short[] GetShortArray(int index);
        string GetUtfString(int index);
        string[] GetUtfStringArray(int index);
        SFSDataWrapper GetWrappedElementAt(int index);
        bool IsNull(int index);
        object RemoveElementAt(int index);
        int Size();
        ByteArray ToBinary();
    }
}

