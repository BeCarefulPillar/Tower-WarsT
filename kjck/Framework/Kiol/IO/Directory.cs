using System;
#if NETFX_CORE
using Windows.Storage;
using Windows.Foundation;
#endif

namespace Kiol.IO
{
    public static class Directory
    {
        /// <summary>
        /// 删除指定目录
        /// </summary>
        /// <param name="path">目录路径</param>
        public static void Delete(string path)
        {
            try
            {
#if NETFX_CORE
                IAsyncOperation<StorageFolder> async = StorageFolder.GetFolderFromPathAsync(path);
                async.AsTask().Wait();
                async.GetResults().DeleteAsync(StorageDeleteOption.PermanentDelete).AsTask().Wait();
#else
                System.IO.Directory.Delete(path);
#endif
            }
            catch
            {
                
            }
        }
        /// <summary>
        /// 指定目录是否存在
        /// </summary>
        /// <param name="path">目录路径</param>
        public static bool Exists(string path)
        {
#if NETFX_CORE
            try
            {

                IAsyncOperation<StorageFolder> async = StorageFolder.GetFolderFromPathAsync(path);
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
            return System.IO.Directory.Exists(path);
#endif
        }
        /// <summary>
        /// 创建一个目录，若已存在则返回当前
        /// </summary>
        /// <param name="path">目录路径</param>
        /// <returns>创建成功/已存在返回路径，否则返回null</returns>
        public static string CreateDirectory(string path)
        {
#if NETFX_CORE
            StorageFolder folder = GetAndCreatDir(path);
            return folder != null ? folder.Path : null;
        }
        private static StorageFolder GetAndCreatDir(string path)
        {
            StorageFolder folder = null;
            try
            {
                IAsyncOperation<StorageFolder> async = StorageFolder.GetFolderFromPathAsync(path);
                async.AsTask().Wait();
                folder = async.GetResults();
            }
            catch (Exception e)
            {
                if (!IOHelper.CheckFileNotFoundException(e))
                {
                    return null;
                }
            }
            if (folder == null)
            {
                string parent = System.IO.Path.GetDirectoryName(path);
                if (!string.IsNullOrEmpty(parent) && parent != path)
                {
                    folder = GetAndCreatDir(System.IO.Path.GetDirectoryName(path));
                    if (folder != null)
                    {
                        try
                        {
                            IAsyncOperation<StorageFolder> async = folder.CreateFolderAsync(System.IO.Path.GetFileName(path), CreationCollisionOption.OpenIfExists);
                            async.AsTask().Wait();
                            folder = async.GetResults();
                        }
                        catch
                        {
                            folder = null;
                        }
                    }
                }
            }
            return folder;
        }
#else
            System.IO.DirectoryInfo di = System.IO.Directory.CreateDirectory(path);
            return di != null ? di.FullName : null;
        }
#endif
        /// <summary>
        /// 获取目录下的所有目录路径
        /// </summary>
        /// <param name="path">目录路径</param>
        /// <returns>目录路径列表</returns>
        public static string[] GetDirectories(string path)
        {
#if NETFX_CORE
            try
            {
                IAsyncOperation<StorageFolder> async = StorageFolder.GetFolderFromPathAsync(path);
                async.AsTask().Wait();
                IAsyncOperation<System.Collections.Generic.IReadOnlyList<StorageFolder>> async2 = async.GetResults().GetFoldersAsync();
                async2.AsTask().Wait();
                System.Collections.Generic.IReadOnlyList<StorageFolder> list = async2.GetResults();
                string[] folders = new string[list.Count];
                for (int i = 0; i < folders.Length; i++) folders[i] = list[i].Path;
                return folders;
            }
            catch
            {
                return null;
            }
#else
            return System.IO.Directory.GetDirectories(path);
#endif
        }
        /// <summary>
        /// 获取目录下的所有文件路径
        /// </summary>
        /// <param name="path">目录路径</param>
        /// <returns>文件路径列表</returns>
        public static string[] GetFiles(string path)
        {
#if NETFX_CORE
            try
            {
                IAsyncOperation<StorageFolder> async = StorageFolder.GetFolderFromPathAsync(path);
                async.AsTask().Wait();
                IAsyncOperation<System.Collections.Generic.IReadOnlyList<StorageFile>> async2 = async.GetResults().GetFilesAsync();
                async2.AsTask().Wait();
                System.Collections.Generic.IReadOnlyList<StorageFile> list = async2.GetResults();
                string[] files = new string[list.Count];
                for (int i = 0; i < files.Length; i++) files[i] = list[i].Path;
                return files;
            }
            catch
            {
                return null;
            }
#else
            return System.IO.Directory.GetFiles(path);
#endif
        }
    }
}
