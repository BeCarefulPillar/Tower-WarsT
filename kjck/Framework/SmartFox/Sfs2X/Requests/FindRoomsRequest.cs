namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities.Match;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class FindRoomsRequest : BaseRequest
    {
        private string groupId;
        public static readonly string KEY_EXPRESSION = "e";
        public static readonly string KEY_FILTERED_ROOMS = "fr";
        public static readonly string KEY_GROUP = "g";
        public static readonly string KEY_LIMIT = "l";
        private int limit;
        private MatchExpression matchExpr;

        public FindRoomsRequest(MatchExpression expr) : base(RequestType.FindRooms)
        {
            this.Init(expr, null, 0);
        }

        public FindRoomsRequest(MatchExpression expr, string groupId) : base(RequestType.FindRooms)
        {
            this.Init(expr, groupId, 0);
        }

        public FindRoomsRequest(MatchExpression expr, string groupId, int limit) : base(RequestType.FindRooms)
        {
            this.Init(expr, groupId, limit);
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutSFSArray(KEY_EXPRESSION, this.matchExpr.ToSFSArray());
            if (this.groupId != null)
            {
                base.sfso.PutUtfString(KEY_GROUP, this.groupId);
            }
            if (this.limit > 0)
            {
                base.sfso.PutShort(KEY_LIMIT, (short) this.limit);
            }
        }

        private void Init(MatchExpression expr, string groupId, int limit)
        {
            this.matchExpr = expr;
            this.groupId = groupId;
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
                throw new SFSValidationError("FindRooms request error", errors);
            }
        }
    }
}

