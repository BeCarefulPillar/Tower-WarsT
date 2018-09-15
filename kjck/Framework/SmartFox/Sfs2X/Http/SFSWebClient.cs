namespace Sfs2X.Http
{
    using System;
    using System.IO;
    using System.Net;
    using System.Net.Sockets;
    using System.Text;
    using System.Text.RegularExpressions;

    public class SFSWebClient
    {
        private HttpResponseDelegate onHttpResponse;

        public void UploadValuesAsync(Uri uri, string paramName, string encodedData)
        {
            TcpClient client = null;
            Exception exception;
            try
            {
                //IPAddress address = IPAddress.Parse(uri.Host);
                //client = new TcpClient();
                //client.Client.Connect(address, uri.Port);
                client = new TcpClient(uri.Host, uri.Port);//ipv6
            }
            catch (Exception exception1)
            {
                exception = exception1;
                this.OnHttpResponse(true, "Http error creating http connection: " + exception.ToString());
                return;
            }
            try
            {
                int num;
                string s = paramName + "=" + encodedData;
                byte[] bytes = Encoding.UTF8.GetBytes(s);
                StringBuilder builder = new StringBuilder();
                builder.Append("POST /BlueBox/BlueBox.do HTTP/1.0\r\n");
                builder.Append("Content-Type: application/x-www-form-urlencoded; charset=utf-8\r\n");
                builder.AppendFormat("Content-Length: {0}\r\n", bytes.Length);
                builder.Append("\r\n");
                builder.Append(s);
                StreamWriter writer = new StreamWriter(client.GetStream());
                string str2 = builder.ToString() + '\0';
                char[] buffer = str2.ToCharArray(0, str2.Length);
                writer.Write(buffer);
                writer.Flush();
                StringBuilder builder2 = new StringBuilder();
                for (byte[] buffer2 = new byte[0x1000]; (num = client.GetStream().Read(buffer2, 0, 0x1000)) > 0; buffer2 = new byte[0x1000])
                {
                    byte[] dst = new byte[num];
                    Buffer.BlockCopy(buffer2, 0, dst, 0, num);
                    builder2.Append(Encoding.UTF8.GetString(dst));
                }
                string[] strArray = Regex.Split(builder2.ToString(), "\r\n\r\n");
                if (strArray.Length < 2)
                {
                    this.OnHttpResponse(true, "Error during http response: connection closed by remote side");
                }
                else
                {
                    char[] trimChars = new char[] { ' ' };
                    string message = strArray[1].TrimEnd(trimChars);
                    this.OnHttpResponse(false, message);
                }
            }
            catch (Exception exception2)
            {
                exception = exception2;
                this.OnHttpResponse(true, "Error during http request: " + exception.ToString() + " " + exception.StackTrace);
            }
            finally
            {
                try
                {
                    client.Close();
                }
                catch (Exception exception3)
                {
                    exception = exception3;
                    this.OnHttpResponse(true, "Error during http scocket shutdown: " + exception.ToString() + " " + exception.StackTrace);
                }
            }
        }

        public HttpResponseDelegate OnHttpResponse
        {
            get
            {
                return this.onHttpResponse;
            }
            set
            {
                this.onHttpResponse = value;
            }
        }
    }
}

