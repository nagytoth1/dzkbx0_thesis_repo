using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SLFormHelper
{
    [Serializable]
    public class SerializedTurnSettings
    {
        public SerializedTurnSettings(SerializedDeviceSettings[] devices, ushort time)
        {
            Devices = devices;
            Time = time;
        }
        public SerializedDeviceSettings[] Devices
        {
            get { return Devices; }
            set { if (value == null) throw new ArgumentNullException("Tömb nem lehet null!"); }
        }
        public ushort Time { get; set; }
    }
    [Serializable]
    public class SerializedDeviceSettings
    {
        public SerializedDeviceSettings(char type, string settings)
        {
            this.Type = type;
            this.Settings = settings;
        }
        public char Type { get; set; }
        public string Settings { get; set; }
    }
}
