namespace Sfs2X.Entities
{
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Variables;
    using System;
    using System.Collections.Generic;

    public interface IMMOItem
    {
        bool ContainsVariable(string name);
        IMMOItemVariable GetVariable(string name);
        List<IMMOItemVariable> GetVariables();
        void SetVariable(IMMOItemVariable variable);
        void SetVariables(List<IMMOItemVariable> variables);

        Vec3D AOIEntryPoint { get; set; }

        int Id { get; }
    }
}

