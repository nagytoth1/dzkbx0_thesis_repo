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
        public SerializedDeviceSettings[] Devices { get; set; }
        public ushort Time { get; set; }
    }
    [Serializable]
    public class SerializedDeviceSettings
    {
        public string Type { get; set; }
        public string Settings { get; set; }
    }
}
