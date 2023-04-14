using Newtonsoft.Json;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace SLFormHelper
{
    /// <summary>
    /// Egy osztály, amely végrehajtja a dev485 tömb átalakítását a relayDLL-ből JSON-formátumú stringgé. 
    /// Ezt a C-implementáció alapján végzi, a converter32DLL függvényét meghívva.
    /// GetInstance statikus függvénnyel lehet példányosítani.
    /// <br></br>-----------------------------------------<br></br>
    /// A class that executes converting dev485 array from relayDLL into JSON-formatted string.
    /// Can only be instantiated using GetInstance static method.
    /// </summary>
    public class CJSONDeviceListConverter : DeviceListConverter
    {
        private static CJSONDeviceListConverter instance;
        private CJSONDeviceListConverter() { }

        public static CJSONDeviceListConverter GetInstance()
        {
            if (instance == null)
                instance = new CJSONDeviceListConverter();
            return instance;
        }
        public void ToDeviceList()
        {
            ConvertDeviceListToJSON_C(out string jsonFormat);
            List<SerializedDevice> deserializedDeviceList = JsonConvert.DeserializeObject<List<SerializedDevice>>(jsonFormat);

            if (deserializedDeviceList == null)
                throw new JsonException($"Eszközlista létrehozása sikertelen: {jsonFormat}");

            for (int i = 0; i < deserializedDeviceList.Count; i++)
                FormHelper.Devices.Add(deserializedDeviceList[i].CreateDevice());
        }
        [DllImport(FormHelper.DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "ConvertDEV485ToJSON_C")]
        extern private static byte ConvertDeviceListToJSON_C([MarshalAs(UnmanagedType.BStr)][Out] out string outputStr);
    }
}
