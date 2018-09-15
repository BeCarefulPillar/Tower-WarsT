namespace Sfs2X.Protocol.Serialization
{
    using Sfs2X.Entities.Data;
    using Sfs2X.Util;

    public interface ISFSDataSerializer
    {
        ByteArray Array2Binary(ISFSArray array);
        ISFSArray Binary2Array(ByteArray data);
        ISFSObject Binary2Object(ByteArray data);
        ByteArray Object2Binary(ISFSObject obj);
    }
}

