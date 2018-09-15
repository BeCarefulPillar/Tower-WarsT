namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Entities.Match;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class FindUsersRequest : BaseRequest
    {
        public static readonly string KEY_EXPRESSION = "e";
        public static readonly string KEY_FILTERED_USERS = "fu";
        public static readonly string KEY_GROUP = "g";
        public static readonly string KEY_LIMIT = "l";
        public static readonly string KEY_ROOM = "r";
        private int limit;
        private MatchExpression matchExpr;
        private object target;

        public FindUsersRequest(MatchExpression expr) : base(RequestType.FindUsers)
        {
            this.Init(expr, null, 0);
        }

        public FindUsersRequest(MatchExpression expr, Room target) : base(RequestType.FindUsers)
        {
            this.Init(expr, target, 0);
        }

        public FindUsersRequest(MatchExpression expr, string target) : base(RequestType.FindUsers)
        {
            this.Init(expr, target, 0);
        }

        public FindUsersRequest(MatchExpression expr, Room target, int limit) : base(RequestType.FindUsers)
        {
            this.Init(expr, target, limit);
        }

        public FindUsersRequest(MatchExpression expr, string target, int limit) : base(RequestType.FindUsers)
        {
            this.Init(expr, target, limit);
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutSFSArray(KEY_EXPRESSION, this.matchExpr.ToSFSArray());
            if (this.target != null)
            {
                if (this.target is Room)
                {
                    base.sfso.PutInt(KEY_ROOM, (this.target as Room).Id);
                }
                else if (this.target is string)
                {
                    base.sfso.PutUtfString(KEY_GROUP, this.target as string);
                }
                else
                {
                    sfs.Log.Warn(new string[] { "Unsupport target type for FindUsersRequest: " + this.target });
                }
            }
            if (this.limit > 0)
            {
                base.sfso.PutShort(KEY_LIMIT, (short) this.limit);
            }
        }

        private void Init(MatchExpression expr, object target, int limit)
        {
            this.matchExpr = expr;
            this.target = target;
            this.limit = limit;
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (this.matchExpr == null)
            {
                errors.Add("Missing Match Expression");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("FindUsers request error", errors);
            }
        }
    }
}

