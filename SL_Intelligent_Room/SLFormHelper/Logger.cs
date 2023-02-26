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
    public static class Logger  //I don't want to instantiate it every single time
    {
        private static readonly string LOG_PATH = string.Format($"{Path.GetTempPath()}\\sl_log.txt"); //current users tempfolder;
        /// <summary>
        /// Writes a message with defined type into a file.
        /// The file named sl_log.txt is located at %TEMP% (a.k.a. C:\Users\<username>\AppData\Local\Temp) folder in Windows.
        /// </summary>
        /// <param name="message">Message to write into the file.</param>
        /// <param name="level">The type of the message to log. Default: INFO</param>
        public static void WriteLog(string message, SeverityLevel level = SeverityLevel.INFO)
        {
            using (StreamWriter writer = new StreamWriter(path: LOG_PATH, append: true)) //automatically delete StreamWriter
            {
                writer.WriteLine($"[{level}] {DateTime.Now:yyyy'-'MM'-'dd HH':'mm':'ss}: {message}");
            }
        }
    }
}
