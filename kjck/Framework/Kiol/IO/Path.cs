namespace Kiol.IO
{
    public static class Path
    {
        public static readonly char AltDirectorySeparatorChar = '/';
        public static readonly char DirectorySeparatorChar = '\\';
        public static readonly char PathSeparator = ';';
        public static readonly char VolumeSeparatorChar = ':';

        /// <summary>
        /// 将2个路径组合成一个路径
        /// </summary>
        /// <param name="path1">路径1</param>
        /// <param name="path2">路径2</param>
        /// <returns>组合后的路径</returns>
        public static string Combine(string path1, string path2)
        {
            return System.IO.Path.Combine(path1, path2);
        }
        /// <summary>
        /// 更改路径字符串的扩展名
        /// </summary>
        /// <param name="path">要修改的路径信息。 该路径不能包含在 System.IO.Path.GetInvalidPathChars() 中定义的任何字符</param>
        /// <param name="extension">新的扩展名（有或没有前导句点）。 指定 null 以从 path 移除现有扩展名</param>
        /// <returns>已修改的路径信息。 在基于 Windows 的桌面平台上，如果 path 是 null 或空字符串 ("")，则返回的路径信息是未修改的。 如果
        /// extension 是 null，则返回的字符串包含指定的路径，其扩展名已移除。 如果 path 不具有扩展名，并且 extension 不是 null，则返回的路径字符串包含
        /// extension，它追加到 path 的结尾</returns>
        public static string ChangeExtension(string path, string extension)
        {
            return System.IO.Path.ChangeExtension(path, extension);
        }
        /// <summary>
        /// 返回指定路径字符串的目录信息
        /// </summary>
        /// <param name="path">文件或目录的路径</param>
        /// <returns>path 的目录信息，如果 path 表示根目录或为 null，则该目录信息为 null。 如果 path 没有包含目录信息，则返回 System.String.Empty</returns>
        public static string GetDirectoryName(string path)
        {
            return System.IO.Path.GetDirectoryName(path);
        }
        /// <summary>
        /// 返回指定的路径字符串的扩展名
        /// </summary>
        /// <param name="path">从其获取扩展名的路径字符串</param>
        /// <returns>指定的路径的扩展名（包含句点“.”）、null 或 System.String.Empty。 如果 path 为 null，则 System.IO.Path.GetExtension(System.String)
        /// 返回 null。 如果 path 不具有扩展名信息，则 System.IO.Path.GetExtension(System.String) 返回
        /// System.String.Empty</returns>
        public static string GetExtension(string path)
        {
            return System.IO.Path.GetExtension(path);
        }
        /// <summary>
        /// 返回指定路径字符串的文件名和扩展名
        /// </summary>
        /// <param name="path">从其获取文件名和扩展名的路径字符串</param>
        /// <returns>path 中最后的目录字符后的字符。 如果 path 的最后一个字符是目录或卷分隔符，则此方法返回 System.String.Empty。 如果
        /// path 为 null，则此方法返回 null</returns>
        public static string GetFileName(string path)
        {
            return System.IO.Path.GetFileName(path);
        }
        /// <summary>
        /// 返回不具有扩展名的指定路径字符串的文件名
        /// </summary>
        /// <param name="path">文件的路径</param>
        /// <returns>System.IO.Path.GetFileName(System.String) 返回的字符串，但不包括最后的句点 (.) 以及之后的所有字符</returns>
        public static string GetFileNameWithoutExtension(string path)
        {
            return System.IO.Path.GetFileNameWithoutExtension(path);
        }
        /// <summary>
        /// 获取包含不允许在文件名中使用的字符的数组
        /// </summary>
        /// <returns>包含不允许在文件名中使用的字符的数组</returns>
        public static char[] GetInvalidFileNameChars()
        {
            return System.IO.Path.GetInvalidFileNameChars();
        }
        /// <summary>
        /// 获取包含不允许在路径名中使用的字符的数组
        /// </summary>
        /// <returns>包含不允许在路径名中使用的字符的数组</returns>
        public static char[] GetInvalidPathChars()
        {
            return System.IO.Path.GetInvalidPathChars();
        }
        /// <summary>
        /// 获取指定路径的根目录信息
        /// </summary>
        /// <param name="path">从其获取根目录信息的路径</param>
        /// <returns>path 的根目录，例如“C:\”；如果 path 为 null，则为 null；如果 path 不包含根目录信息，则为空字符串</returns>
        public static string GetPathRoot(string path)
        {
            return System.IO.Path.GetPathRoot(path);
        }
        /// <summary>
        /// 返回随机文件夹名或文件名
        /// </summary>
        /// <returns>随机文件夹名或文件名</returns>
        public static string GetRandomFileName()
        {
            return System.IO.Path.GetRandomFileName();
        }
        /// <summary>
        /// 确定路径是否包括文件扩展名
        /// </summary>
        /// <param name="path">用于搜索扩展名的路径</param>
        /// <returns>如果路径中最后的目录分隔符（\\ 或 /）或卷分隔符 (:) 之后的字符包括句点 (.)，并且后面跟有一个或多个字符，则为 true；否则为 false</returns>
        public static bool HasExtension(string path)
        {
            return System.IO.Path.HasExtension(path);
        }
        /// <summary>
        /// 获取一个值，该值指示指定的路径字符串是否包含根
        /// </summary>
        /// <param name="path">要测试的路径</param>
        /// <returns>如果 path 包含根；则为 true；否则为 false</returns>
        public static bool IsPathRooted(string path)
        {
            return System.IO.Path.IsPathRooted(path);
        }
    }
}
