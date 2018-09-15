namespace Sfs2X.Entities.Data
{
    using Sfs2X.Util;
    using System;

    public interface ISFSObject
    {
        bool ContainsKey(string key);
        bool GetBool(string key);
        bool[] GetBoolArray(string key);
        byte GetByte(string key);
        ByteArray GetByteArray(string key);
        object GetClass(string key);
        SFSDataWrapper GetData(string key);
        double GetDouble(string key);
        double[] GetDoubleArray(string key);
        string GetDump();
        string GetDump(bool format);
        float GetFloat(string key);
        float[] GetFloatArray(string key);
        string GetHexDump();
        int GetInt(string key);
        int[] GetIntArray(string key);
        string[] GetKeys();
        long GetLong(string key);
        long[] GetLongArray(string key);
        ISFSArray GetSFSArray(string key);
        ISFSObject GetSFSObject(string key);
        short GetShort(string key);
        short[] GetShortArray(string key);
        string GetUtfString(string key);
        string[] GetUtfStringArray(string key);
        bool IsNull(string key);
        void Put(string key, SFSDataWrapper val);
        void PutBool(string key, bool val);
        void PutBoolArray(string key, bool[] val);
        void PutByte(string key, byte val);
        void PutByteArray(string key, ByteArray val);
        void PutClass(string key, object val);
        void PutDouble(string key, double val);
        void PutDoubleArray(string key, double[] val);
        void PutFloat(string key, float val);
        void PutFloatArray(string key, float[] val);
        void PutInt(string key, int val);
        void PutIntArray(string key, int[] val);
        void PutLong(string key, long val);
        void PutLongArray(string key, long[] val);
        void PutNull(string key);
        void PutSFSArray(string key, ISFSArray val);
        void PutSFSObject(string key, ISFSObject val);
        void PutShort(string key, short val);
        void PutShortArray(string key, short[] val);
        void PutUtfString(string key, string val);
        void PutUtfStringArray(string key, string[] val);
        void RemoveElement(string key);
        int Size();
        ByteArray ToBinary();
    }
}

