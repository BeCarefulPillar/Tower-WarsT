namespace Kiol.IO
{
    [System.Serializable]
    public enum FileMode
    {
        /// <summary>
        /// 创建新文件。如果文件已存在，则将引发IOException
        /// </summary>
        CreateNew = 1,
        /// <summary>
        /// 创建新文件。如果文件已存在，它将被覆盖
        /// </summary>
        Create = 2,
        /// <summary>
        /// 打开现有文件。如果该文件不存在，则引发System.IO.FileNotFoundException
        /// </summary>
        Open = 3,
        /// <summary>
        /// 打开现有文件。如果文件不存在，则创建新文件
        /// </summary>
        OpenOrCreate = 4,
        /// <summary>
        /// 打开现有文件并，文件一旦打开，就将被截断为零字节大小。如果文件不存在，则引发System.IO.FileNotFoundException
        /// </summary>
        Truncate = 5,
    }
}
