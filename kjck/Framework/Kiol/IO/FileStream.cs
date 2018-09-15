using System;
#if NETFX_CORE
using System.IO;
using Windows.Storage;
using Windows.Storage.Streams;
using Windows.Foundation;
using System.Runtime.InteropServices.WindowsRuntime;
#endif

namespace Kiol.IO
{
    public class FileStream : IDisposable
    {
#if NETFX_CORE
        private IRandomAccessStream stream;
        private string name;

        public FileStream(string path, FileMode mode)
        {
            OpenStream(path, mode, FileAccess.ReadWrite);
        }
        public FileStream(string path, FileMode mode, FileAccess access)
        {
            OpenStream(path, mode, access);
        }
        private void OpenStream(string path, FileMode mode, FileAccess access)
        {
            StorageFile file = null;
            IAsyncOperation<StorageFile> async = null;
            try
            {
                async = StorageFile.GetFileFromPathAsync(path);
                async.AsTask().Wait();
                file = async.GetResults();
            }
            catch (Exception e)
            {
                if(IOHelper.CheckFileNotFoundException(e))
                {
                    file = null;
                }
                else
                {
                    throw e;
                }
            }

            if (file == null)
            {
                if(mode == FileMode.Open || mode == FileMode.Truncate)
                {
                    throw new System.IO.IOException("file [" + path + "] not exisits!");
                }
                IAsyncOperation<StorageFolder> async3 = StorageFolder.GetFolderFromPathAsync(Path.GetDirectoryName(path));
                async3.AsTask().Wait();
                async = async3.GetResults().CreateFileAsync(Path.GetFileName(path));
                async.AsTask().Wait();
                file = async.GetResults();
            }
            else
            {
                if(mode == FileMode.CreateNew)
                {
                    throw new System.IO.IOException("file [" + path + "] is exisits!");
                }
            }
            IAsyncOperation<IRandomAccessStream> async2 = file.OpenAsync(access == FileAccess.ReadWrite ? FileAccessMode.ReadWrite : FileAccessMode.Read);
            async2.AsTask().Wait();
            stream = async2.GetResults();
            name = path;
            if ((mode == FileMode.Create || mode == FileMode.Truncate) && stream.CanWrite)
            {
                stream.Size = 0;
            }
        }
        /// <summary>
        /// 获取流对象
        /// </summary>
        public System.IO.Stream Stream { get { return stream.AsStream(); } }
        /// <summary>
        /// 指示流是否可读
        /// </summary>
        public bool CanRead { get { return stream.CanRead; } }
        /// <summary>
        /// 指示流是否可写
        /// </summary>
        public bool CanWrite { get { return stream.CanWrite; } }
        /// <summary>
        /// 获取流的大小
        /// </summary>
        public long Length { get { return (long)stream.Size; } }
        /// <summary>
        /// 文件全名
        /// </summary>
        public string Name { get { return name; } }
        /// <summary>
        /// 获取该流的字节偏移量
        /// </summary>
        public long Position { get { return (long)stream.Position; } }
        /// <summary>
        /// 设置流的位置
        /// </summary>
        public void Seek(long offset)
        {
            stream.Seek((ulong)offset);
        }
        /// <summary>
        /// 设置流的大小
        /// </summary>
        public void SetLength(long value)
        {
            if (CanWrite) stream.Size = (ulong)value;
        }
        /// <summary>
        /// 读取流中指定字节数的数据到给定的缓存中
        /// </summary>
        /// <param name="array">缓存</param>
        /// <param name="offset">缓存起始偏移</param>
        /// <param name="count">需要读取的字节数量</param>
        /// <returns>实际读取的字节数</returns>
        public int Read(byte[] array, int offset, int count)
        {
            if (array == null || offset < 0 || offset >= array.Length || (offset + count - 1) >= array.Length)
            {
                throw new System.IO.IOException("array range error!");
            }
            IAsyncOperationWithProgress<IBuffer, uint> async = stream.ReadAsync(array.AsBuffer(offset, count), (uint)count, InputStreamOptions.None);
            async.AsTask().Wait();
            return (int)async.GetResults().Length;
        }
        /// <summary>
        /// 将缓存中指定范围的数据写入到流
        /// </summary>
        /// <param name="array">缓存数据</param>
        /// <param name="offset">缓存起始偏移</param>
        /// <param name="count">要写入的字节数</param>
        public void Write(byte[] array, int offset, int count)
        {
            if (array == null || offset < 0 || offset >= array.Length || (offset + count - 1) >= array.Length)
            {
                throw new System.IO.IOException("array range error!");
            }
            if (CanWrite) stream.WriteAsync(array.AsBuffer(offset, count)).AsTask().Wait();
        }
        /// <summary>
        /// 将一个字节写入到流
        /// </summary>
        public void WriteByte(byte value)
        {
            if (CanWrite) stream.WriteAsync(new byte[1] { value }.AsBuffer()).AsTask().Wait();
        }
        /// <summary>
        /// 在有序流中刷新数据
        /// </summary>
        public void Flush()
        {
            stream.FlushAsync().AsTask().Wait();
        }
        /// <summary>
        /// 关闭释放当前文件流
        /// </summary>
        public void Dispose()
        {
            stream.Dispose();
        }
#else
        private System.IO.FileStream stream;

        public FileStream(string path, FileMode mode)
        {
            stream = new System.IO.FileStream(path, (System.IO.FileMode)mode);
        }
        public FileStream(string path, FileMode mode, FileAccess access)
        {
            stream = new System.IO.FileStream(path, (System.IO.FileMode)mode, access == FileAccess.ReadWrite ? System.IO.FileAccess.ReadWrite : System.IO.FileAccess.Read);
        }
        /// <summary>
        /// 获取流对象
        /// </summary>
        public System.IO.Stream Stream { get { return stream; } }
        /// <summary>
        /// 指示流是否可读
        /// </summary>
        public bool CanRead { get { return stream.CanRead; } }
        /// <summary>
        /// 指示流是否可写
        /// </summary>
        public bool CanWrite { get { return stream.CanWrite; } }
        /// <summary>
        /// 获取流的大小
        /// </summary>
        public long Length { get { return stream.Length; } }
        /// <summary>
        /// 文件全名
        /// </summary>
        public string Name { get { return stream.Name; } }
        /// <summary>
        /// 获取该流的字节偏移量
        /// </summary>
        public long Position { get { return stream.Position; } }
        /// <summary>
        /// 设置流的位置
        /// </summary>
        public long Seek(long offset)
        {
            return stream.Seek(offset, System.IO.SeekOrigin.Current);
        }
        /// <summary>
        /// 设置流的大小
        /// </summary>
        public void SetLength(long value)
        {
            if (CanWrite) stream.SetLength(value);
        }
        /// <summary>
        /// 读取流中指定字节数的数据到给定的缓存中
        /// </summary>
        /// <param name="array">缓存</param>
        /// <param name="offset">缓存起始偏移</param>
        /// <param name="count">需要读取的字节数量</param>
        /// <returns>实际读取的字节数</returns>
        public int Read(byte[] array, int offset, int count)
        {
            return stream.Read(array, offset, count);
        }
        /// <summary>
        /// 将缓存中指定范围的数据写入到流
        /// </summary>
        /// <param name="array">缓存数据</param>
        /// <param name="offset">缓存起始偏移</param>
        /// <param name="count">要写入的字节数</param>
        public void Write(byte[] array, int offset, int count)
        {
            if (CanWrite) stream.Write(array, offset, count);
        }
        /// <summary>
        /// 将一个字节写入到流
        /// </summary>
        public void WriteByte(byte value)
        {
            if (CanWrite) stream.WriteByte(value);
        }
        /// <summary>
        /// 在有序流中刷新数据
        /// </summary>
        public void Flush()
        {
            stream.Flush();
        }
        /// <summary>
        /// 关闭释放当前文件流
        /// </summary>
        public void Dispose()
        {
            stream.Close();
            stream.Dispose();
        }
#endif
    }
}