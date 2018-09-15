#if TOLUA
using System;
using System.Reflection;
using LuaInterface;

public static class LuaReflect
{
    public static void Register(LuaState L)
    {
        //L.BeginModule(null);

        L.BeginClass(typeof(Byte), typeof(object), "byte");
        L.RegFunction("New", _CreateByte);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("__eq", op_Equality);
        L.EndClass();

        L.BeginClass(typeof(SByte), typeof(object), "sbyte");
        L.RegFunction("New", _CreateSByte);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("__eq", op_Equality);
        L.EndClass();

        L.BeginClass(typeof(Short), typeof(object), "short");
        L.RegFunction("New", _CreateShort);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("__eq", op_Equality);
        L.EndClass();

        L.BeginClass(typeof(UShort), typeof(object), "ushort");
        L.RegFunction("New", _CreateUShort);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("__eq", op_Equality);
        L.EndClass();

        L.BeginClass(typeof(Int), typeof(object), "int");
        L.RegFunction("New", _CreateInt);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("__eq", op_Equality);
        L.EndClass();

        L.BeginClass(typeof(UInt), typeof(object), "uint");
        L.RegFunction("New", _CreateUInt);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("__eq", op_Equality);
        L.EndClass();

        L.BeginClass(typeof(Float), typeof(object), "float");
        L.RegFunction("New", _CreateFloat);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("__eq", op_Equality);
        L.EndClass();

        //L.EndModule();


        L.BeginModule("CS");
        L.RegFunction("CreateInstance", CreateInscance);
        L.RegFunction("SCall", StaticCall);
        L.RegFunction("GetSValue", GetStaticValue);
        L.RegFunction("GetSProperty", GetStaticProperty);
        L.RegFunction("SetSValue", SetStaticValue);
        L.RegFunction("SetSProperty", SetStaticProperty);
        L.RegFunction("Call", Call);
        L.RegFunction("GetValue", GetValue);
        L.RegFunction("GetProperty", GetProperty);
        L.RegFunction("SetValue", SetValue);
        L.RegFunction("SetProperty", SetProperty);
        L.EndModule();
    }

    private static object CheckTypeRef(object obj) { return obj is TypeRef ? (obj as TypeRef).value : obj; }

    #region base type
    public interface TypeRef { object value { get; } }
    public class Byte : TypeRef
    {
        private byte val;
        public Byte(byte b) { val = b; }
        public object value { get { return val; } }
        public override bool Equals(object obj) { return val.Equals(obj); }
        public override int GetHashCode() { return val.GetHashCode(); }
        public override string ToString() { return val.ToString(); }
        public static explicit operator Byte(byte value) { return new Byte(value); }
        public static explicit operator byte(Byte value) { return value.val; }
    }
    public class SByte : TypeRef
    {
        private sbyte val;
        public SByte(sbyte s) { val = s; }
        public object value { get { return val; } }
        public override bool Equals(object obj) { return val.Equals(obj); }
        public override int GetHashCode() { return val.GetHashCode(); }
        public override string ToString() { return val.ToString(); }
        public static explicit operator SByte(sbyte value) { return new SByte(value); }
        public static explicit operator sbyte(SByte value) { return value.val; }
    }
    public class Short : TypeRef
    {
        private short val;
        public Short(short s) { val = s; }
        public object value { get { return val; } }
        public override bool Equals(object obj) { return val.Equals(obj); }
        public override int GetHashCode() { return val.GetHashCode(); }
        public override string ToString() { return val.ToString(); }
        public static explicit operator Short(short value) { return new Short(value); }
        public static explicit operator short(Short value) { return value.val; }
    }
    public class UShort : TypeRef
    {
        private ushort val;
        public UShort(ushort u) { val = u; }
        public object value { get { return val; } }
        public override bool Equals(object obj) { return val.Equals(obj); }
        public override int GetHashCode() { return val.GetHashCode(); }
        public override string ToString() { return val.ToString(); }
        public static explicit operator UShort(ushort value) { return new UShort(value); }
        public static explicit operator ushort(UShort value) { return value.val; }
    }
    public class Int : TypeRef
    {
        private int val;
        public Int(int i) { val = i; }
        public object value { get { return val; } }
        public override bool Equals(object obj) { return val.Equals(obj); }
        public override int GetHashCode() { return val.GetHashCode(); }
        public override string ToString() { return val.ToString(); }
        public static explicit operator Int(int value) { return new Int(value); }
        public static explicit operator int(Int value) { return value.val; }
    }
    public class UInt : TypeRef
    {
        private uint val;
        public UInt(uint u) { val = u; }
        public object value { get { return val; } }
        public override bool Equals(object obj) { return val.Equals(obj); }
        public override int GetHashCode() { return val.GetHashCode(); }
        public override string ToString() { return val.ToString(); }
        public static explicit operator UInt(uint value) { return new UInt(value); }
        public static explicit operator uint(UInt value) { return value.val; }
    }
    public class Float : TypeRef
    {
        private float val;
        public Float(float f) { val = f; }
        public object value { get { return val; } }
        public override bool Equals(object obj) { return val.Equals(obj); }
        public override int GetHashCode() { return val.GetHashCode(); }
        public override string ToString() { return val.ToString(); }
        public static explicit operator Float(float value) { return new Float(value); }
        public static explicit operator float(Float value) { return value.val; }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int _CreateByte(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1)
            {
                ToLua.PushObject(L, new Byte((byte)LuaDLL.luaL_checknumber(L, 1)));
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: LuaReflect.Byte");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int _CreateSByte(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1)
            {
                ToLua.PushObject(L, new SByte((sbyte)LuaDLL.luaL_checknumber(L, 1)));
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: LuaReflect.SByte");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int _CreateShort(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1)
            {
                ToLua.PushObject(L, new Short((short)LuaDLL.luaL_checknumber(L, 1)));
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: LuaReflect.Short");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int _CreateUShort(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1)
            {
                ToLua.PushObject(L, new UShort((ushort)LuaDLL.luaL_checknumber(L, 1)));
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: LuaReflect.UShort");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int _CreateInt(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1)
            {
                ToLua.PushObject(L, new Int((int)LuaDLL.luaL_checknumber(L, 1)));
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: LuaReflect.Int");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int _CreateUInt(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1)
            {
                ToLua.PushObject(L, new UInt((uint)LuaDLL.luaL_checknumber(L, 1)));
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: LuaReflect.UInt");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int _CreateFloat(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1)
            {
                ToLua.PushObject(L, new Float((float)LuaDLL.luaL_checknumber(L, 1)));
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: LuaReflect.Float");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int op_Equality(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            LuaDLL.lua_pushboolean(L, ToLua.ToObject(L, 1) == ToLua.ToObject(L, 2));
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int CreateInscance(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 0)
            {
                Type type = null;
                if (TypeChecker.CheckType(L, typeof(string), 1))
                {
                    type = Type.GetType(ToLua.CheckString(L, 1));
                }
                else if (TypeChecker.CheckType(L, typeof(Type), 1))
                {
                    type = ToLua.ToObject(L, 1) as Type;
                }
                if (type == null)
                {
                    Debugger.LogWarning("create cs instance param must [type] or [type name]");
                    return 0;
                }
                object[] param = null;
                if (count > 2)
                {
                    param = new object[count - 2];
                    for (int i = 0; i < param.Length; i++)
                    {
                        param[i] = CheckTypeRef(ToLua.ToVarObject(L, i + 3));
                    }
                }
                object ret = Activator.CreateInstance(type, param);
                if (ret != null)
                {
                    ToLua.Push(L, ret);
                    return 1;
                }
            }
            else
            {
                Debugger.LogWarning("create cs instance need param (type/type name, method name, param...)");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int StaticCall(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 1 && TypeChecker.CheckType(L, typeof(string), 2))
            {
                Type type = null;
                if (TypeChecker.CheckType(L, typeof(string), 1))
                {
                    type = Type.GetType(ToLua.CheckString(L, 1));
                }
                else if (TypeChecker.CheckType(L, typeof(Type), 1))
                {
                    type = ToLua.ToObject(L, 1) as Type;
                }
                if (type == null)
                {
                    Debugger.LogWarning("call cs static method first param must [type] or [type name]");
                    return 0;
                }
                object[] param = null;
                if (count > 2)
                {
                    param = new object[count - 2];
                    for (int i = 0; i < param.Length; i++)
                    {
                        param[i] = CheckTypeRef(ToLua.ToVarObject(L, i + 3));
                    }
                }
                object ret = type.InvokeMember(ToLua.CheckString(L, 2), BindingFlags.Static | BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.NonPublic, null, null, param);
                if (ret != null)
                {
                    ToLua.Push(L, ret);
                    return 1;
                }
            }
            else
            {
                Debugger.LogWarning("call cs static method need param (type/type name, method name, param...)");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetStaticValue(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 1 && TypeChecker.CheckType(L, typeof(string), 2))
            {
                Type type = null;
                if (TypeChecker.CheckType(L, typeof(string), 1))
                {
                    type = Type.GetType(ToLua.CheckString(L, 1));
                }
                else if (TypeChecker.CheckType(L, typeof(Type), 1))
                {
                    type = ToLua.ToObject(L, 1) as Type;
                }
                if (type == null)
                {
                    Debugger.LogWarning("get cs static field first param mmust [type] or [type name]");
                    return 0;
                }
                FieldInfo field = type.GetField(ToLua.CheckString(L, 2), BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.GetField);
                if (field != null)
                {
                    ToLua.Push(L, field.GetValue(null));
                    return 1;
                }
            }
            else
            {
                Debugger.LogWarning("get cs static field need param (type/type name, field name)");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetStaticProperty(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 1 && TypeChecker.CheckType(L, typeof(string), 2))
            {
                Type type = null;
                if (TypeChecker.CheckType(L, typeof(string), 1))
                {
                    type = Type.GetType(ToLua.CheckString(L, 1));
                }
                else if (TypeChecker.CheckType(L, typeof(Type), 1))
                {
                    type = ToLua.ToObject(L, 1) as Type;
                }
                if (type == null)
                {
                    Debugger.LogWarning("get cs static property first param mmust [type] or [type name]");
                    return 0;
                }
                PropertyInfo prop = type.GetProperty(ToLua.CheckString(L, 2), BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.GetProperty);
                if (prop != null)
                {
                    object[] index = null;
                    if (count > 2)
                    {
                        index = new object[count - 2];
                        for (int i = 0; i < index.Length; i++)
                        {
                            index[i] = CheckTypeRef(ToLua.ToVarObject(L, i + 3));
                        }
                    }
                    ToLua.Push(L, prop.GetValue(null, index));
                    return 1;
                }
            }
            else
            {
                Debugger.LogWarning("get cs static property need param (type/type name, property name, index...)");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetStaticValue(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 2 && TypeChecker.CheckType(L, typeof(string), 2))
            {
                Type type = null;
                if (TypeChecker.CheckType(L, typeof(string), 1))
                {
                    type = Type.GetType(ToLua.CheckString(L, 1));
                }
                else if (TypeChecker.CheckType(L, typeof(Type), 1))
                {
                    type = ToLua.ToObject(L, 1) as Type;
                }
                if (type == null)
                {
                    Debugger.LogWarning("set cs static field first param mmust [type] or [type name]");
                    return 0;
                }
                FieldInfo field = type.GetField(ToLua.CheckString(L, 2), BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.SetField);
                if (field != null)
                {
                    field.SetValue(null, CheckTypeRef(ToLua.ToVarObject(L, 3)));
                }
            }
            else
            {
                Debugger.LogWarning("set cs static field need param (type/type name, field name, value)");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetStaticProperty(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 2 && TypeChecker.CheckType(L, typeof(string), 2))
            {
                Type type = null;
                if (TypeChecker.CheckType(L, typeof(string), 1))
                {
                    type = Type.GetType(ToLua.CheckString(L, 1));
                }
                else if (TypeChecker.CheckType(L, typeof(Type), 1))
                {
                    type = ToLua.ToObject(L, 1) as Type;
                }
                if (type == null)
                {
                    Debugger.LogWarning("set cs static property first param mmust [type] or [type name]");
                    return 0;
                }
                PropertyInfo prop = type.GetProperty(ToLua.CheckString(L, 2), BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.SetProperty);
                if (prop != null)
                {
                    object[] index = null;
                    if (count > 3)
                    {
                        index = new object[count - 3];
                        for (int i = 0; i < index.Length; i++)
                        {
                            index[i] = CheckTypeRef(ToLua.ToVarObject(L, i + 4));
                        }
                    }
                    prop.SetValue(null, CheckTypeRef(ToLua.ToVarObject(L, 3)), index);
                }
            }
            else
            {
                Debugger.LogWarning("set cs static property need param (type/type name, property name, value, index...)");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Call(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 1 && TypeChecker.CheckType(L, typeof(string), 2))
            {
                object target = null;
                target = ToLua.ToVarObject(L, 1);
                if (target == null)
                {
                    Debugger.LogWarning("call cs instance method target can not be null!");
                    return 0;
                }
                object[] param = null;
                if (count > 2)
                {
                    param = new object[count - 2];
                    for (int i = 0; i < param.Length; i++)
                    {
                        param[i] = CheckTypeRef(ToLua.ToVarObject(L, i + 3));
                    }
                }
                object ret = target.GetType().InvokeMember(ToLua.CheckString(L, 2), BindingFlags.Instance | BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.NonPublic, null, target, param);
                if (ret != null)
                {
                    ToLua.Push(L, ret);
                    return 1;
                }
            }
            else
            {
                Debugger.LogWarning("call cs instance method need param (target, method name, param...)");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetValue(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 1 && TypeChecker.CheckType(L, typeof(string), 2))
            {
                object target = null;
                target = ToLua.ToVarObject(L, 1);
                if (target == null)
                {
                    Debugger.LogWarning("get cs instance field target can not be null!");
                    return 0;
                }
                FieldInfo field = target.GetType().GetField(ToLua.CheckString(L, 2), BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.GetField);
                if (field != null)
                {
                    ToLua.Push(L, field.GetValue(target));
                    return 1;
                }
            }
            else
            {
                Debugger.LogWarning("get cs instance field need param (target, field name)");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetProperty(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 1 && TypeChecker.CheckType(L, typeof(string), 2))
            {
                object target = null;
                target = ToLua.ToVarObject(L, 1);
                if (target == null)
                {
                    Debugger.LogWarning("get cs instance property target can not be null!");
                    return 0;
                }
                PropertyInfo prop = target.GetType().GetProperty(ToLua.CheckString(L, 2), BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.GetProperty);
                if (prop != null)
                {
                    object[] index = null;
                    if (count > 2)
                    {
                        index = new object[count - 2];
                        for (int i = 0; i < index.Length; i++)
                        {
                            index[i] = CheckTypeRef(ToLua.ToVarObject(L, i + 3));
                        }
                    }
                    ToLua.Push(L, prop.GetValue(target, index));
                    return 1;
                }
            }
            else
            {
                Debugger.LogWarning("get cs instance property need param (target, property name, index...)");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetValue(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 2 && TypeChecker.CheckType(L, typeof(string), 2))
            {
                object target = null;
                target = ToLua.ToVarObject(L, 1);
                if (target == null)
                {
                    Debugger.LogWarning("set cs instance field target can not be null!");
                    return 0;
                }
                FieldInfo field = target.GetType().GetField(ToLua.CheckString(L, 2), BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.SetField);
                if (field != null)
                {
                    field.SetValue(target, CheckTypeRef(ToLua.ToVarObject(L, 3)));
                }
            }
            else
            {
                Debugger.LogWarning("set cs instance field need param (target, field name, value)");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetProperty(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 2 && TypeChecker.CheckType(L, typeof(string), 2))
            {
                object target = null;
                target = ToLua.ToVarObject(L, 1);
                if (target == null)
                {
                    Debugger.LogWarning("set cs instance property target can not be null!");
                    return 0;
                }
                PropertyInfo prop = target.GetType().GetProperty(ToLua.CheckString(L, 2), BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.SetProperty);
                if (prop != null)
                {
                    object[] index = null;
                    if (count > 3)
                    {
                        index = new object[count - 3];
                        for (int i = 0; i < index.Length; i++)
                        {
                            index[i] = CheckTypeRef(ToLua.ToVarObject(L, i + 4));
                        }
                    }
                    prop.SetValue(target, CheckTypeRef(ToLua.ToVarObject(L, 3)), index);
                }
            }
            else
            {
                Debugger.LogWarning("set cs instance property need param (target, property name, value, index...)");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
}
#endif