using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SLFormHelper
{
    public enum SeverityLevel
    {
        DEBUG, INFO, WARNING, ERROR
    }   
    public static class Logger
    {
        private static readonly string LOG_PATH = string.Format($"{Path.GetTempPath()}\\sl_log.txt"); //jelenlegi felhasználó TEMP-mappája;
        /// <summary>
        /// Meghatározott fajtájú üzenetet ír egy fájlba.
        /// A sl_log.txt nevű fájl a C:\Users\<felhasználónév>\AppData\Local\Temp (%TEMP%) mappában megtalálható Windows-rendszerek esetében.
        /// <br></br>---------------------------------------<br></br>
        /// Writes a message with defined type into a file.
        /// The file named sl_log.txt is located at %TEMP% (a.k.a. C:\Users\<username>\AppData\Local\Temp) folder in Windows.
        /// </summary>
        /// <param name="message">A fájlba írandó üzenet.</param>
        /// <param name="level">A naplózandó üzenet típusa, súlyossága. Alapértelmezetten: INFO</param>
        public static void WriteLog(string message, SeverityLevel level = SeverityLevel.INFO)
        {
            using (StreamWriter writer = new StreamWriter(path: LOG_PATH, append: true)) //automatically delete StreamWriter
            {
                writer.WriteLine($"[{level}] {DateTime.Now:yyyy'-'MM'-'dd HH':'mm':'ss}: {message}");
            }
        }
    }
}
