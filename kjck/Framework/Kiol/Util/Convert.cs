using System;
using Kiol.Reflection;

namespace Kiol.Util
{
    public static class KConvert
    {
        /// <summary>
        /// 返回类型的默认值
        /// </summary>
        public static object Default(TypeCode type)
        {
            switch (type)
            {
                case TypeCode.Boolean: return default(bool);
                case TypeCode.Char: return default(char);
                case TypeCode.String: return string.Empty;
                case TypeCode.DateTime: return default(DateTime);
                case TypeCode.Single: return 0f;
                case TypeCode.Double: return 0d;
                case TypeCode.Decimal: return 0d;
                case TypeCode.Byte:
                case TypeCode.SByte:
                case TypeCode.Int16:
                case TypeCode.UInt16:
                case TypeCode.Int32:
                case TypeCode.UInt32:
                case TypeCode.Int64:
                case TypeCode.UInt64:
                    return 0;
            }
            return null;
        }
        /// <summary>
        /// 返回类型的默认值
        /// </summary>
        public static object Default(Type type) { return type.IsValueType() ? Activator.CreateInstance(type) : (type == typeof(string) ? string.Empty : null); }
        /// <summary>
        /// 转换对象类型，若转换错误，则返回类型的默认值
        /// </summary>
        /// <param name="source">源数据</param>
        /// <param name="targetType">目标数据类型</param>
        /// <returns></returns>
        public static object ConvertType(object source, Type targetType)
        {
            try { return Convert.ChangeType(source, targetType); }
            catch (Exception e) { KLogger.LogWarning(string.Format("convert type from {0} to {1} error! see detail:\n{2}", source, targetType, e)); return Default(targetType); }
        }
        /// <summary>
        /// 将一种数据类型转换成另一种类型,一般用于基元类型
        /// </summary>
        /// <typeparam name="T">目标数据类型</typeparam>
        /// <param name="source">源数据</param>
        /// <returns></returns>
        public static T ConvertType<T>(object source)
        {
            return (T)ConvertType(source, typeof(T));
        }
        /// <summary>
        /// 将一种数组数据类型转换成另一种数组类型,一般用于基元类型
        /// </summary>
        /// <typeparam name="T">目标数组类型</typeparam>
        /// <param name="source">源数组</param>
        /// <returns></returns>
        public static T[] ConvertArrType<T>(Array source)
        {
            T[] arr = new T[source.Length];
            for (int i = 0; i < arr.Length; i++) arr[i] = ConvertType<T>(source.GetValue(i));
            return arr;
        }
        /// <summary>
        /// 转换16进制字符串到Int32，失败返回0
        /// </summary>
        public static uint Base16ToUInt32(string n16)
        {
            if (string.IsNullOrEmpty(n16)) return 0;
            try { return Convert.ToUInt32(n16, 16); } catch { return 0; }
        }

        /// <summary>
        /// 将多个一维数组转合并为一个数组
        /// <param name="T">数组元素的泛型</param>
        /// <param name="args">多个数组</param>
        /// </summary>
        public static T[] PieceArray<T>(params T[][] args)
        {
            int len = 0;
            foreach (T[] arr in args)
            {
                if (arr == null) continue;
                len += arr.GetLength(0);
            }
            T[] array = new T[len];
            int index = 0;
            foreach (T[] arr in args)
            {
                if (arr == null) continue;
                arr.CopyTo(array, index);
                index += arr.Length;
            }
            return array;
        }
    }
}