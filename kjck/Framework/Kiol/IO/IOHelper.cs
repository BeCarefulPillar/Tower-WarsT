using System;
using System.IO;

namespace Kiol.IO
{
    public static class IOHelper
    {
        public static bool CheckFileNotFoundException(Exception e)
        {
            if (e is FileNotFoundException)
            {
                return true;
            }
            if (e.GetBaseException() is FileNotFoundException)
            {
                return true;
            }
            if (e.InnerException is FileNotFoundException)
            {
                return true;
            }
#if NETFX_CORE
            if (e is AggregateException)
            {
                System.Collections.ObjectModel.ReadOnlyCollection<Exception> col = (e as AggregateException).InnerExceptions;
                foreach (Exception item in col)
                {
                    if (item is FileNotFoundException)
                    {
                        return true;
                    }
                }
            }
#endif
            return false;
        }
    }
}
