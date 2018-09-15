namespace Sfs2X.Core
{
    using System;
    using System.Collections;

    public class EventDispatcher
    {
        private Hashtable listeners = new Hashtable();
        private object target;

        public EventDispatcher(object target)
        {
            this.target = target;
        }

        public void AddEventListener(string eventType, EventListenerDelegate listener)
        {
            EventListenerDelegate a = this.listeners[eventType] as EventListenerDelegate;
            a = (EventListenerDelegate) Delegate.Combine(a, listener);
            this.listeners[eventType] = a;
        }

        public void DispatchEvent(BaseEvent evt)
        {
            EventListenerDelegate delegate2 = this.listeners[evt.Type] as EventListenerDelegate;
            if (delegate2 != null)
            {
                evt.Target = this.target;
                try
                {
                    delegate2(evt);
                }
                catch (Exception exception)
                {
                    throw new Exception("Error dispatching event " + evt.Type + ": " + exception.Message + " " + exception.StackTrace, exception);
                }
            }
        }

        public void RemoveAll()
        {
            this.listeners.Clear();
        }

        public void RemoveEventListener(string eventType, EventListenerDelegate listener)
        {
            EventListenerDelegate source = this.listeners[eventType] as EventListenerDelegate;
            if (source != null)
            {
                source = (EventListenerDelegate) Delegate.Remove(source, listener);
            }
            this.listeners[eventType] = source;
        }
    }
}

