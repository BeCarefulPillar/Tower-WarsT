using System.Threading;

namespace Kiol.Util
{
#if JOY_TOOL
    public class CRC32
#else
    public class CRC32 : IProgress
#endif
    {
        /// <summary>
        /// 校验超时时间(10S)
        /// </summary>
        public const int TIME_OUT_TICKS = 100000000;

        public static readonly uint[] Table;

        static CRC32()
        {
            Table = new uint[256];
            const uint kPoly = 0xEDB88320;
            for (uint i = 0; i < 256; i++)
            {
                uint r = i;
                for (int j = 0; j < 8; j++)
                    if ((r & 1) != 0)
                        r = (r >> 1) ^ kPoly;
                    else
                        r >>= 1;
                Table[i] = r;
            }
        }

        /// <summary>
        /// 计算字节组的CRC32
        /// </summary>
        /// <param name="data">字节数据</param>
        /// <param name="count">计算长度</param>
        /// <returns></returns>
        public static uint CalculateCRC32(byte[] data, int count = 0)
        {
            if (data == null) return 0;
            uint value = 0xFFFFFFFF;
            count = count > 0 ? System.Math.Min(count, data.Length) : data.Length;
            for (int i = 0; i < count; i++)
            {
                // 1.value 右移8位(相当于除以256)  
                // 2.value与进来的数据进行异或运算后再与0xFF进行与运算  
                //    得到一个索引index，然后查找CRC16_TABLE表相应索引的数据  
                // 1和2得到的数据再进行异或运算。  
                value = (value >> 8) ^ Table[(value ^ data[i]) & 0xff];
            }
            // 取反  
            return ~value & 0xFFFFFFFF;
        }

        /// <summary>
        /// 计算文件的CRC32
        /// </summary>
        public static uint CalculateCRC32(string filePath)
        {
            if (string.IsNullOrEmpty(filePath)) return 0;
            uint value = 0xFFFFFFFF;
            System.IO.FileStream fs = null;
            try
            {
                fs = new System.IO.FileStream(filePath, System.IO.FileMode.Open);
                while (fs.Position < fs.Length)
                {
                    value = (value >> 8) ^ Table[(value ^ fs.ReadByte()) & 0xff];
                }
            }
            catch (System.Exception e)
            {
                value = 0xFFFFFFFF;
                KLogger.Log("CalculateCRC32 For " + filePath + " Error:" + e);
            }
            finally
            {
                if (fs != null)
                {
                    fs.Dispose();
                    fs.Close();
                }
            }
            // 取反  
            return ~value & 0xFFFFFFFF;
        }

        private Thread _thread;
        private uint _crc;
        private long _expTime;

        public CRC32(string fileName)
        {
            _crc = 0;
            _expTime = System.DateTime.Now.Ticks + TIME_OUT_TICKS;
            _thread = new Thread(OnCRC);
            _thread.Start(fileName);
        }

        public CRC32(byte[] data, int count = 0)
        {
            _crc = 0;
            _expTime = System.DateTime.Now.Ticks + TIME_OUT_TICKS;
            _thread = new Thread(OnCRC);
            _thread.Start(new object[] { data, count });
        }

        private void OnCRC(object data)
        {
            if (data is string)
            {
                _crc = CalculateCRC32(data as string);
            }
            else if (data is object[])
            {
                object[] arr = data as object[];
                if (arr.Length > 1 && arr[0] is byte[] && arr[1] is int)
                {
                    _crc = CalculateCRC32(arr[0] as byte[], (int)arr[1]);
                }
            }
        }

        public uint crc { get { return _crc; } }

        public float process { get { return isDone ? 1f : 0f; } }

        public bool isDone { get { return _thread == null || !_thread.IsAlive || isTimeOut; } }

        public bool isTimeOut { get { return System.DateTime.Now.Ticks > _expTime; } }

        public string processMessage { get { return string.Empty; } }
    }
}