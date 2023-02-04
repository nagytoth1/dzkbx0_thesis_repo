using Newtonsoft.Json;
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
        [JsonProperty(PropertyName = "devices")]
        public SerializedDeviceSettings[] Devices { get; set; }
        [JsonProperty(PropertyName = "time")]
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
        [JsonProperty(PropertyName = "type")]
        public char Type { get; set; }
        [JsonProperty(PropertyName = "settings")]
        public string Settings { get; set; }
    }
}
