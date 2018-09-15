using System;
using System.Reflection;
#if NETFX_CORE
using System.Collections.Generic;
using System.Linq;
#endif

namespace Kiol.Reflection
{
    public static class ReflectionExtensions
    {
        /// <summary>
        /// 检索表示指定字段的对象
        /// </summary>
        /// <param name="type">包含字段的类型</param>
        /// <param name="name">字段名</param>
        /// <returns>表示指定字段的对象，若未找到该字段则为 null</returns>
        public static FieldInfo GetTypeField(this Type type, string name)
        {
#if NETFX_CORE
            IEnumerable<FieldInfo> fs = type.GetRuntimeFields();
            foreach (FieldInfo fi in fs) if (fi.Name == name) return fi;
            return null;
#else
            return type.GetField(name, BindingFlags.GetField | BindingFlags.SetField | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static);
#endif
        }
        /// <summary>
        /// 检索表示指定类型定义的所有字段的集合
        /// </summary>
        /// <param name="type">包含字段的类型</param>
        /// <returns>指定类型的字段集合</returns>
        public static FieldInfo[] GetTypeFields(this Type type, bool noPublic = true, bool instance = true, bool isStatic = true)
        {
#if NETFX_CORE
            return type.GetRuntimeFields().ToArray();
#else
            BindingFlags flag = BindingFlags.GetField | BindingFlags.SetField | BindingFlags.Public;
            if (noPublic) flag |= BindingFlags.NonPublic;
            if (instance) flag |= BindingFlags.Instance;
            if (isStatic) flag |= BindingFlags.Static;
            return type.GetFields(flag);
#endif
        }
        /// <summary>
        /// 检索一个表示指定事件的对象
        /// </summary>
        /// <param name="type">包含该事件的类型</param>
        /// <param name="name">事件的名称</param>
        /// <returns>表示指定事件的对象，若未找到该事件则为 null</returns>
        public static EventInfo GetTypeEvent(this Type type, string name)
        {
#if NETFX_CORE
            IEnumerable<EventInfo> es = type.GetRuntimeEvents();
            foreach (EventInfo ei in es) if (ei.Name == name) return ei;
            return null;
#else
            return type.GetEvent(name, BindingFlags.GetField | BindingFlags.SetField | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static);
#endif
        }
        /// <summary>
        /// 检索表示指定类型定义的所有事件的集合
        /// </summary>
        /// <param name="type">包含该事件的类型</param>
        /// <returns>指定类型的事件集合</returns>
        public static EventInfo[] GetTypeEvents(this Type type, bool noPublic = true, bool instance = true, bool isStatic = true)
        {
#if NETFX_CORE
            return type.GetRuntimeEvents().ToArray();
#else
            BindingFlags flag = BindingFlags.GetField | BindingFlags.SetField | BindingFlags.Public;
            if (noPublic) flag |= BindingFlags.NonPublic;
            if (instance) flag |= BindingFlags.Instance;
            if (isStatic) flag |= BindingFlags.Static;
            return type.GetEvents(flag);
#endif
        }
        /// <summary>
        /// 检索表示指定属性的对象
        /// </summary>
        /// <param name="type">包含该属性的类型</param>
        /// <param name="name">属性的名称</param>
        /// <returns>表示指定属性的对象，若未找到该属性则为 null</returns>
        public static PropertyInfo GetTypeProperty(this Type type, string name)
        {
#if NETFX_CORE
            IEnumerable<PropertyInfo> ps = type.GetRuntimeProperties();
            foreach (PropertyInfo pi in ps) if (pi.Name == name) return pi;
            return null;
#else
            return type.GetProperty(name, BindingFlags.GetProperty | BindingFlags.SetProperty | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static);
#endif
        }
        /// <summary>
        /// 检索表示指定类型定义的所有属性的集合
        /// </summary>
        /// <param name="type">包含属性的类型</param>
        /// <returns>指定类型的属性集合</returns>
        public static PropertyInfo[] GetTypeProperties(this Type type, bool noPublic = true, bool instance = true, bool isStatic = true)
        {
#if NETFX_CORE
            return type.GetRuntimeProperties().ToArray();
#else
            BindingFlags flag = BindingFlags.GetProperty | BindingFlags.SetProperty | BindingFlags.Public;
            if (noPublic) flag |= BindingFlags.NonPublic;
            if (instance) flag |= BindingFlags.Instance;
            if (isStatic) flag |= BindingFlags.Static;
            return type.GetProperties(flag);
#endif
        }
        /// <summary>
        /// 检索表示指定方法的对象
        /// </summary>
        /// <param name="type">包含方法的类型</param>
        /// <param name="name">方法的名称</param>
        /// <param name="parameters">表示指定方法的对象，若未找到该方法则为 null</param>
        /// <returns></returns>
        public static MethodInfo GetTypeMethod(this Type type, string name, params Type[] parameters)
        {
#if NETFX_CORE
            IEnumerable<MethodInfo> ms = type.GetRuntimeMethods();
            foreach (MethodInfo mi in ms) if (mi.Name == name && mi.CheckParamType(parameters)) return mi;
            return null;
#else
            return type.GetMethod(name, BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static, null, parameters, null);
#endif
        }
        /// <summary>
        /// 检索表示指定类型定义的所有方法的集合
        /// </summary>
        /// <param name="type">包含方法的类型</param>
        /// <returns>指定类型的方法集合</returns>
        public static MethodInfo[] GetTypeMethods(this Type type, bool noPublic = true, bool instance = true, bool isStatic = true)
        {
#if NETFX_CORE
            return type.GetRuntimeMethods().ToArray();
#else
            BindingFlags flag = BindingFlags.InvokeMethod | BindingFlags.Public;
            if (noPublic) flag |= BindingFlags.NonPublic;
            if (instance) flag |= BindingFlags.Instance;
            if (isStatic) flag |= BindingFlags.Static;
            return type.GetMethods(flag);
#endif
        }
        /// <summary>
        /// 获取指示指定委托表示的方法的对象
        /// </summary>
        /// <param name="del">要检查的委托</param>
        /// <returns>表示该方法的对象</returns>
        public static MethodInfo GetDelegateMethod(this Delegate del)
        {
#if NETFX_CORE
            return del.GetMethodInfo();
#else
            return del.Method;
#endif
        }
        /// <summary>
        /// 检索表示在此方法最先声明的直接或间接类上的指定方法的对象
        /// </summary>
        /// <param name="method">关于检索信息的方法</param>
        /// <returns>表示在基类中指定的方法的初始声明的对象</returns>
        public static MethodInfo GetTypeBaseDefinition(this MethodInfo method)
        {
#if NETFX_CORE
            return method.GetRuntimeBaseDefinition();
#else
            return method.GetBaseDefinition();
#endif
        }
        /// <summary>
        /// 检测方法的参数类型是否匹配
        /// </summary>
        public static bool CheckParamType(this MethodInfo method, Type[] types)
        {
            ParameterInfo[] parameters = method.GetParameters();
            if (parameters == null && types == null)
            {
                return true;
            }
            if (parameters == null || types == null || parameters.Length != types.Length)
            {
                return false;
            }
            for (int i = 0; i < parameters.Length; i++)
            {
                if (parameters[i].ParameterType != types[i])
                {
                    return false;
                }
            }
            return true;
        }
        /// <summary>
        /// 是否是基元类型
        /// </summary>
        public static bool IsPrimitive(this Type type)
        {
#if NETFX_CORE
            return type.GetTypeInfo().IsPrimitive;
#else
            return type.IsPrimitive;
#endif
        }
        /// <summary>
        /// 是否是值类型
        /// </summary>
        public static bool IsValueType(this Type type)
        {
#if NETFX_CORE
            return type.GetTypeInfo().IsValueType;
#else
            return type.IsValueType;
#endif
        }
        /// <summary>
        /// 是否是枚举类型
        /// </summary>
        public static bool IsEnum(this Type type)
        {
#if NETFX_CORE
            return type.GetTypeInfo().IsEnum;
#else
            return type.IsEnum;
#endif
        }
        /// <summary>
        /// 是否是数组
        /// </summary>
        public static bool IsArray(this Type type)
        {
#if NETFX_CORE
            return type.GetTypeInfo().IsArray;
#else
            return type.IsArray;
#endif
        }
        /// <summary>
        /// 是否是结构体
        /// </summary>
        public static bool IsStruct(this Type type)
        {
#if NETFX_CORE
            TypeInfo ti = type.GetTypeInfo();
            return ti.IsValueType && !ti.IsPrimitive && !ti.IsEnum;
#else
            return type.IsValueType && !type.IsPrimitive && !type.IsEnum;
#endif 
        }
        /// <summary>
        /// 给定类型是否是其子类
        /// </summary>
        public static bool IsSubclassOf(this Type type, Type c)
        {
#if NETFX_CORE
            return type.GetTypeInfo().IsSubclassOf(c);
#else
            return type.IsSubclassOf(c);
#endif
        }
        /// <summary>
        /// 给定对象是否是其实例
        /// </summary>
        public static bool IsInstanceOfType(this Type type, object o)
        {
#if NETFX_CORE
            if (o == null) return false;
            Type ot = o.GetType();
            return ot == type || ot.GetTypeInfo().IsSubclassOf(type);
#else
            return type.IsInstanceOfType(o);
#endif
        }
    }
}