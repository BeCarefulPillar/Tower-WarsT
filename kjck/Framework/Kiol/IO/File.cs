//#define NETFX_CORE
using System;
using System.Collections.Generic;
#if NETFX_CORE
using Windows.Storage;
using Windows.Storage.Streams;
using Windows.Storage.FileProperties;
using Windows.Foundation;
using System.Runtime.InteropServices.WindowsRuntime;
#endif
using Kiol.Util;

namespace Kiol.IO
{
    /// <summary>
    /// 文件是否存在
    /// </summary>
    public static class File
    {
#if !NETFX_CORE
        private struct FileTask
        {
            public string path;
            public byte[] data;
            public Action<byte[]> readCallBack;
            public Action<bool> writeCallBack;
            public byte type;//1读，2写，3删
        }
        private static Queue<FileTask> tasks = new Queue<FileTask>();
        private static System.Threading.Thread thread = new System.Threading.Thread(StartTask);
#endif
        /// <summary>
        /// 指定路径的文件是否存在
        /// </summary>
        /// <param name="path">文件路径</param>
        public static bool Exists(string path)
        {
#if NETFX_CORE
            try
            {
                IAsyncOperation<StorageFile> async = StorageFile.GetFileFromPathAsync(path);
                async.AsTask().Wait();
                return async.Status == AsyncStatus.Completed && async.GetResults() != null;
            }
            catch (Exception e)
            {
                if (IOHelper.CheckFileNotFoundException(e))
                {
                    return false;
                }
                else
                {
                    throw e;
                }
            }
#else
            return System.IO.File.Exists(path);
#endif
        }
        public static long Length(string path)
        {
#if NETFX_CORE
            try
            {
                IAsyncOperation<StorageFile> async = StorageFile.GetFileFromPathAsync(path);
                async.AsTask().Wait();
                IAsyncOperation<BasicProperties> async2 = async.GetResults().GetBasicPropertiesAsync();
                async2.AsTask().Wait();
                return (long)async2.GetResults().Size;
            }
            catch (Exception e)
            {
                if (IOHelper.CheckFileNotFoundException(e))
                {
                    return 0L;
                }
                else
                {
                    throw e;
                }
            }
#else
            return System.IO.File.Exists(path) ? new System.IO.FileInfo(path).Length : 0L;
#endif
        }
        /// <summary>
        /// 删除一个文件
        /// </summary>
        /// <param name="path">文件路径</param>
        public static void Delete(string path)
        {
            try
            {
#if NETFX_CORE
                IAsyncOperation<StorageFile> async = StorageFile.GetFileFromPathAsync(path);
                async.AsTask().Wait();
                async.GetResults().DeleteAsync(StorageDeleteOption.PermanentDelete).AsTask().Wait();
#else
                if (System.IO.File.Exists(path))
                {
                    System.IO.File.Delete(path);
                }
#endif
            }
            catch (Exception e)
            {
                KLogger.Log("Delete File [" + path + "] error detail:\n" + e);
            }
        }
        /// <summary>
        /// 删除目录下的所有文件
        /// </summary>
        public static void DeleteFiles(string dir)
        {
            try
            {
#if NETFX_CORE
                IAsyncOperation<StorageFolder> async = StorageFolder.GetFolderFromPathAsync(dir);
                async.AsTask().Wait();
                IAsyncOperation<IReadOnlyList<StorageFile>> async2 = async.GetResults().GetFilesAsync();
                async2.AsTask().Wait();
                IReadOnlyList<StorageFile> files = async2.GetResults();
                foreach (StorageFile file in files)
                {
                    file.DeleteAsync(StorageDeleteOption.PermanentDelete).AsTask().Wait();
                }
#else
                if (System.IO.Directory.Exists(dir))
                {
                    string[] fs = System.IO.Directory.GetFiles(dir);
                    if (fs != null)
                    {
                        for (int i = 0; i < fs.Length; i++)
                        {
                            System.IO.File.Delete(fs[i]);
                        }
                    }
                }
#endif
            }
            catch (Exception e)
            {
                KLogger.Log("Delete Dir Files [" + dir + "] error detail:\n" + e);
            }
        }
        /// <summary>
        /// 删除目录下所有指定格式的文件
        /// </summary>
        /// <param name="dir"></param>
        /// <param name="searchPattern">搜索匹配</param>
        public static void DeleteFiles(string dir, string searchPattern)
        {
            try
            {
#if NETFX_CORE
                IAsyncOperation<StorageFolder> async = StorageFolder.GetFolderFromPathAsync(dir);
                async.AsTask().Wait();
                IAsyncOperation<IReadOnlyList<StorageFile>> async2 = async.GetResults().GetFilesAsync();
                async2.AsTask().Wait();
                IReadOnlyList<StorageFile> files = async2.GetResults();
                foreach (StorageFile file in files)
                {
                    file.DeleteAsync(StorageDeleteOption.PermanentDelete).AsTask().Wait();
                }
#else
                if (System.IO.Directory.Exists(dir))
                {
                    string[] fs = System.IO.Directory.GetFiles(dir, searchPattern);
                    if (fs != null)
                    {
                        for (int i = 0; i < fs.Length; i++)
                        {
                            System.IO.File.Delete(fs[i]);
                        }
                    }
                }
#endif
            }
            catch (Exception e)
            {
                KLogger.Log("Delete Dir Files [" + dir + "] error detail:\n" + e);
            }
        }
        /// <summary>
        /// 同步读取文件
        /// </summary>
        /// <param name="path">文件路径</param>
        public static byte[] ReadFile(string path)
        {
            try
            {
#if NETFX_CORE
                IAsyncOperation<IBuffer> async = PathIO.ReadBufferAsync(path);
                async.AsTask().Wait();
                IBuffer buffer = async.GetResults();
                if (buffer.Length > 0)
                {
                    return buffer.ToArray();
                }
                else
                {
                    Delete(path);
                }
#else
                if (System.IO.File.Exists(path))
                {
                    System.IO.FileInfo fi = new System.IO.FileInfo(path);
                    if (fi.Length > 0)
                    {
#if UNITY_WINRT
                        FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read);
                        byte[] data = new byte[fs.Length];
                        fs.Read(data, 0, (int)fs.Length);
                        fs.Dispose();
                        return data;
#else
                        return System.IO.File.ReadAllBytes(path);
#endif
                    }
                    else
                    {
                        System.IO.File.Delete(path);
                    }
                }
#endif
            }
            catch (Exception e)
            {
                KLogger.Log(e);
            }
            return null;
        }
        /// <summary>
        /// 同步写入文件
        /// </summary>
        /// <param name="path">文件路径</param>
        /// <param name="data">数据</param>
        /// <returns></returns>
        public static bool WriteFile(string path, byte[] data)
        {
            if (data == null) return false;
#if NETFX_CORE
            try
            {
                if (Exists(path))
                {
                    PathIO.WriteBytesAsync(path, data).AsTask().Wait();
                    return true;
                }
                else
                {
                    IAsyncOperation<StorageFolder> async = StorageFolder.GetFolderFromPathAsync(Path.GetDirectoryName(path));
                    async.AsTask().Wait();
                    IAsyncOperation<StorageFile> async2 = async.GetResults().CreateFileAsync(Path.GetFileName(path));
                    async2.AsTask().Wait();
                    FileIO.WriteBytesAsync(async2.GetResults(), data).AsTask().Wait();
                    return true;
                }
            }
            catch (Exception e)
            {
                return false;
            }
#else
            System.IO.FileStream stream = null;

            try
            {
                string dir = Path.GetDirectoryName(path);
                if (!System.IO.Directory.Exists(dir)) System.IO.Directory.CreateDirectory(dir);
                stream = System.IO.File.Create(path, data.Length);
                stream.Write(data, 0, data.Length);
                bool result = stream.Length == data.Length;
                stream.Close();
                return result;
            }
            catch (Exception e)
            {
                KLogger.Log(e);
                if (stream != null) stream.Close();
                if (System.IO.File.Exists(path)) System.IO.File.Delete(path);
                return false;
            }
#endif
        }
        /// <summary>
        /// 异步读取文件
        /// </summary>
        /// <param name="path">文件路径</param>
        /// <param name="callBack">完成后回调</param>
        public static void ReadFile(string path, Action<byte[]> callBack)
        {
#if NETFX_CORE
            AsyncReadFile(path, callBack);
#else
            FileTask task = new FileTask();
            task.path = path;
            task.readCallBack = callBack;
            task.type = 1;
            tasks.Enqueue(task);
            if (thread.ThreadState != System.Threading.ThreadState.Running) thread.Start();
#endif
        }
        /// <summary>
        /// 异步写入文件
        /// </summary>
        /// <param name="path">文件路径</param>
        /// <param name="data">文件数据</param>
        /// <param name="callBack">完成后回调</param>
        public static void WriteFile(string path, byte[] data, Action<bool> callBack)
        {
#if NETFX_CORE
            AsyncWriteFile(path, data, callBack);
#else
            FileTask task = new FileTask(); 
            task.path = path;
            task.data = data;
            task.writeCallBack = callBack;
            task.type = 2;
            tasks.Enqueue(task);
            if (thread.ThreadState != System.Threading.ThreadState.Running) thread.Start();
#endif
        }
#if NETFX_CORE
        private static async void AsyncReadFile(string path, Action<byte[]> callBack)
        {
            if (callBack == null) return;
            try
            {
                IBuffer buffer = await PathIO.ReadBufferAsync(path);
                if (buffer.Length > 0)
                {
                    callBack(buffer.ToArray());
                }
                else
                {
                    Delete(path);
                    callBack(null);
                }
            }
            catch
            {
                callBack(null);
            }
        }
        private static async void AsyncWriteFile(string path, byte[] data, Action<bool> callBack)
        {
            try
            {
                if (Exists(path))
                {
                    await PathIO.WriteBytesAsync(path, data);
                }
                else
                {
                    await FileIO.WriteBytesAsync(await (await StorageFolder.GetFolderFromPathAsync(Path.GetDirectoryName(path))).CreateFileAsync(Path.GetFileName(path)), data);
                }
                if (callBack != null) callBack(true);
            }
            catch(Exception e)
            {
                Debug.Log(e);
                if (callBack != null) callBack(false);
            }
        }
#else
        private static void StartTask()
        {
            while (tasks.Count > 0)
            {
                FileTask task = (FileTask)tasks.Dequeue();
                if (task.type == 1) Read(task);
                if (task.type == 2) Write(task);
            }
        }
        private static void Read(FileTask task)
        {
            try
            {
                if (System.IO.File.Exists(task.path))
                {
                    System.IO.FileInfo fi = new System.IO.FileInfo(task.path);
                    if (fi.Length > 0)
                    {
#if UNITY_WINRT
                        FileStream fs = new FileStream(task.path, FileMode.Open, FileAccess.Read);
                        task.data = new byte[fs.Length];
                        fs.Read(task.data, 0, (int)fs.Length);
                        fs.Dispose();
#else
                        task.data = System.IO.File.ReadAllBytes(task.path);
#endif
                    }
                    else
                    {
                        System.IO.File.Delete(task.path);
                    }
                }
            }
            catch (Exception e)
            {
                KLogger.Log(e);
            }
            finally
            {
                if (task.readCallBack != null) task.readCallBack(task.data);
            }
        }
        private static void Write(FileTask task)
        {
            bool success = false;
            try
            {
                string dir = task.path.Substring(0, task.path.LastIndexOf("/") + 1);
                if (!System.IO.Directory.Exists(dir)) System.IO.Directory.CreateDirectory(dir);
                int size = task.data.Length;
                System.IO.FileStream stream = System.IO.File.Create(task.path);
                stream.Write(task.data, 0, size);
                stream.Close();
                success = true;
            }
            catch (Exception e)
            {
                KLogger.Log(e);
            }
            finally
            {
                if (task.writeCallBack != null) task.writeCallBack(success);
            }
        }
#endif
        /// <summary>
        /// 创建一个文件，若存在则截断为0字节
        /// </summary>
        /// <param name="path">文件路径</param>
        /// <returns></returns>
        public static FileStream Create(string path)
        {
            return new FileStream(path, FileMode.Create, FileAccess.ReadWrite);
        }
        /// <summary>
        /// 打开现有文件
        /// </summary>
        /// <param name="path">文件路径</param>
        /// <returns></returns>
        public static FileStream Open(string path, FileMode mode, FileAccess access = FileAccess.ReadWrite)
        {
            return new FileStream(path, FileMode.Open, access);
        }
        /// <summary>
        /// 打开现有文件进行读取
        /// </summary>
        /// <param name="path">文件路径</param>
        /// <returns></returns>
        public static FileStream OpenRead(string path)
        {
            return new FileStream(path, FileMode.Open, FileAccess.Read);
        }
        /// <summary>
        /// 打开现有文件以进行写入
        /// </summary>
        /// <param name="path">文件路径</param>
        public static FileStream OpenWrite(string path)
        {
            return new FileStream(path, FileMode.Open, FileAccess.ReadWrite);
        }
    }
}
