namespace Sfs2X.FSM
{
    using System;
    using System.Collections.Generic;
    using System.Runtime.CompilerServices;

    public class FiniteStateMachine
    {
        private volatile int currentStateName;
        private object locker = new object();
        public OnStateChangeDelegate onStateChange;
        private List<FSMState> states = new List<FSMState>();

        public void AddAllStates(Type statesEnumType)
        {
            foreach (object obj2 in Enum.GetValues(statesEnumType))
            {
                this.AddState(obj2);
            }
        }

        public void AddState(object st)
        {
            int newStateName = (int) st;
            FSMState item = new FSMState();
            item.SetStateName(newStateName);
            this.states.Add(item);
        }

        public void AddStateTransition(object from, object to, object tr)
        {
            int st = (int) from;
            int outputState = (int) to;
            int transition = (int) tr;
            this.FindStateObjByName(st).AddTransition(transition, outputState);
        }

        public int ApplyTransition(object tr)
        {
            lock (this.locker)
            {
                int transition = (int) tr;
                int currentStateName = this.currentStateName;
                this.currentStateName = this.FindStateObjByName((int) this.currentStateName).ApplyTransition(transition);
                if ((currentStateName != this.currentStateName) && (this.onStateChange != null))
                {
                    this.onStateChange(currentStateName, this.currentStateName);
                }
                return this.currentStateName;
            }
        }

        private FSMState FindStateObjByName(object st)
        {
            int num = (int) st;
            foreach (FSMState state in this.states)
            {
                if (num.Equals(state.GetStateName()))
                {
                    return state;
                }
            }
            return null;
        }

        public int GetCurrentState()
        {
            lock (this.locker)
            {
                return this.currentStateName;
            }
        }

        public void SetCurrentState(object state)
        {
            int toStateName = (int) state;
            if (this.onStateChange != null)
            {
                this.onStateChange(this.currentStateName, toStateName);
            }
            this.currentStateName = toStateName;
        }

        public delegate void OnStateChangeDelegate(int fromStateName, int toStateName);
    }
}

