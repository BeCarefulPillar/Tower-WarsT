namespace Sfs2X.Entities.Variables
{
    using Sfs2X.Entities.Data;
    using System;

    public interface UserVariable
    {
        bool GetBoolValue();
        double GetDoubleValue();
        int GetIntValue();
        ISFSArray GetSFSArrayValue();
        ISFSObject GetSFSObjectValue();
        string GetStringValue();
        bool IsNull();
        ISFSArray ToSFSArray();

        string Name { get; }

        VariableType Type { get; }

        object Value { get; }
    }
}

