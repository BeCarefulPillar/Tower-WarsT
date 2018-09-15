namespace Sfs2X.Entities.Match
{
    using System;

    public interface IMatcher
    {
        string Symbol { get; }

        int Type { get; }
    }
}

