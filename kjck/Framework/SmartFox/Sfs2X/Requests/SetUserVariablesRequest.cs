namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Variables;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class SetUserVariablesRequest : BaseRequest
    {
        public static readonly string KEY_USER = "u";
        public static readonly string KEY_VAR_LIST = "vl";
        private ICollection<UserVariable> userVariables;

        public SetUserVariablesRequest(ICollection<UserVariable> userVariables) : base(RequestType.SetUserVariables)
        {
            this.userVariables = userVariables;
        }

        public override void Execute(SmartFox sfs)
        {
            ISFSArray val = SFSArray.NewInstance();
            foreach (UserVariable variable in this.userVariables)
            {
                val.AddSFSArray(variable.ToSFSArray());
            }
            base.sfso.PutSFSArray(KEY_VAR_LIST, val);
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if ((this.userVariables == null) || (this.userVariables.Count == 0))
            {
                errors.Add("No variables were specified");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("SetUserVariables request error", errors);
            }
        }
    }
}

