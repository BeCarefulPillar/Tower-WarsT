namespace Sfs2X.Core
{
    using System;

    public interface IDispatchable
    {
        void AddEventListener(string eventType, EventListenerDelegate listener);

        EventDispatcher Dispatcher { get; }
    }
}

