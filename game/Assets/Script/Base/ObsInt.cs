using UnityEngine;
using System.Collections;
using System;

[Serializable]
public struct ObsInt : IComparable<ObsInt> {
    private int raw_value;
    static int key;
    static ObsInt() {
        key = 0x7ac90731;
    }
    public ObsInt(int value) {
        this.raw_value = (value ^ key);
    }

    public int ToInt() {
        return raw_value ^ key;
    }

    public override string ToString() {
        return (raw_value ^ key).ToString();
    }

    static public implicit operator ObsInt(int value) {
        return new ObsInt(value);
    }

    static public implicit operator int(ObsInt value) {
        return (value.raw_value) ^ key;
    }

    static public bool operator > (ObsInt one, ObsInt other) {
        return (one.raw_value ^ key) > (other.raw_value ^ key);
    }

    static public bool operator >= (ObsInt one, ObsInt other) {
        return (one.raw_value ^ key) >= (other.raw_value ^ key);
    }

    static public bool operator < (ObsInt one, ObsInt other) {
        return (one.raw_value ^ key) < (other.raw_value ^ key);
    }

    static public bool operator <= (ObsInt one, ObsInt other) {
        return (one.raw_value ^ key) <= (other.raw_value ^ key);
    }

    static public bool operator == (ObsInt one, ObsInt other) {
        return (one.raw_value ^ key) == (other.raw_value ^ key);
    }

    static public bool operator != (ObsInt one, ObsInt other) {
        return (one.raw_value ^ key) != (other.raw_value ^ key);
    }

    public override int GetHashCode() {
        return raw_value.GetHashCode();
    }

    public override bool Equals(object obj) {
        if(obj is ObsInt)
            return ((ObsInt)obj).raw_value == this.raw_value;
        else 
            return false;
    }

    public int CompareTo(ObsInt other) {
        return (this.raw_value ^ key).CompareTo(other.raw_value ^ key);
    }
}
