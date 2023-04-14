using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace SLFormHelper
{
    /// <summary>
    /// Egy osztály, amely végrehajtja a dev485 tömb átalakítását a relayDLL-ből JSON-formátumú karakterlánccá.
    /// Ezt a Delphi-implementáció alapján végzi, a ConvertDEV485ToJSON-függvényt meghívva.
    /// GetInstance statikus függvénnyel lehet példányosítani.
    /// <br></br>-----------------------------------------<br></br>
    /// A class that executes converting dev485 array from relayDLL into JSON-formatted string.
    /// Can only be instantiated using GetInstance static method.
    /// </summary>
    public class JSONDeviceListConverter : DeviceListConverter
    {
        private static JSONDeviceListConverter instance;
        private JSONDeviceListConverter() { }

        public static JSONDeviceListConverter GetInstance() {
            if (instance == null)
                instance = new JSONDeviceListConverter();
            return instance;
        }
        /// <summary>
        /// Eldönti a bemenő JSON-forrásszövegről, hogy az helyes JSON-formátumban van-e.
        /// <br></br>---------------------------------------<br></br>
        /// Extension method for strings.
        /// This function makes a decision whether the given string is in valid JSON-format or not.
        /// </summary>
        /// <param name="source">Forrásszöveg, amit meg akarunk vizsgálni.</param>
        /// <returns>true, ha JSON-formátumban van, különben false.</returns>
        private static bool IsValidJSON(string source) //extension method for string
        {
            if (source == null || source == "")
                return false;
            try
            {
                JToken.Parse(source);
                return true;
            }
            catch (JsonException) //ha bármi hiba van a JSON-parse közben, akkor nem lehet valid a JSON-formátum
            {
                return false;
            }
        }
        /// <summary>
        /// Delphi-függvényt (ConvertDEV485ToJSON) hív, amely a felmért eszközök tömbjét, a `dev485`-öt JSON-formátumra alakítja (szerializálja), majd ezt a standard formátumot (lényegében csak az eszközök azonosítóját) a C# számára közli.
        /// Ebből a C# legyártja a saját eszközlistáját (`devices`-lista) a megfelelő típusú eszközök példányaival (LED-lámpa, LED-nyíl, Hangszóró).
        /// Ezen az eszközlistán beállításokat tudunk végezni, amelyet ki tudunk küldeni végül a megfelelő eszközök részére.
        /// A lista elérhető FormHelper.Devices property-n keresztül.
        /// <br></br>---------------------------------------<br></br>
        /// A Delphi-function is called that converts (serializes) the array of devices being surveyed, `dev485`, into JSON format, and then communicates this standard format (essentially just the device identifier) to C#.
        /// From this, C# derives its own list of devices (`devices`-list) with instances of the appropriate type of devices (LED lamp, LED arrow, Speaker).
        /// On this device list you can make settings, which you can eventually send out to the appropriate devices.
        /// The list is accessible via the FormHelper.Devices property.
        /// </summary>
        /// <param name="use_c">Használjuk-e a converter32.dll-jében található C-függvényt</param>
        /// <exception cref="JsonException"></exception>
        public void ToDeviceList()
        {
            ConvertDeviceListToJSON(out string jsonFormat);
            //[{"azonos":16388}, {"azonos": 36543}, ...] JSON-formátumú dev485 betöltése a C# környezete számára
            if (!IsValidJSON(jsonFormat))
                throw new JsonException($"Az eszközök leírása helytelen JSON-formátumban történt: {jsonFormat}");
            List<SerializedDevice> deserializedDeviceList = JsonConvert.DeserializeObject<List<SerializedDevice>>(jsonFormat);


            if (deserializedDeviceList == null)
                throw new JsonException($"Eszközlista létrehozása sikertelen: {jsonFormat}");

            for (int i = 0; i < deserializedDeviceList.Count; i++)
                FormHelper.Devices.Add(deserializedDeviceList[i].CreateDevice());
        }

        [DllImport(FormHelper.DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "ConvertDEV485ToJSON")]
        extern private static byte ConvertDeviceListToJSON([MarshalAs(UnmanagedType.BStr)][Out] out string outputStr);
    }
}
