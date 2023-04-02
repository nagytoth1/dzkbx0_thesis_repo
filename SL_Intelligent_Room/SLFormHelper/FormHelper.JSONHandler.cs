using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Windows.Forms;

namespace SLFormHelper
{
    public static partial class FormHelper
    {
        /// <summary>
        /// Beolvassa a megadott elérési úton szereplő JSON-fájlt, amely az eszközbeállításokat tartalmaz.<br></br>
        /// Ezt a metódust használva betölthetünk előre beállított eszközlistákat a programunkba futásidőben.<br></br>
        /// Az eszközbeállítások mentéséről és tárolásáról az UnloadDeviceSettings-metódus gondoskodik.
        /// <br></br>---------------------------------------<br></br>
        /// Reads the JSON file containing the device settings from the specified path.
        ///Using this method, you can load preconfigured device lists into your program at runtime.
        ///The UnloadDeviceSettings method is used to save and store the device settings.
        /// </summary>
        /// <param name="jsonFile">Beolvasni kívánt JSON-fájl elérési útvonala.</param>
        /// <exception cref="JsonException"></exception>
        public static void LoadDeviceSettings(string jsonFile)
        {
            string fileContent;
            try
            {
                using (StreamReader reader = new StreamReader(jsonFile))
                {
                    fileContent = reader.ReadToEnd();
                }
            }
            catch (IOException e)
            {
                Logger.WriteLog($"Hiba történt fájlbeolvasás közben...{e.Message}", SeverityLevel.WARNING);
                return;
            }
            SerializedTurnSettings[] turnSettings = JsonConvert.DeserializeObject<SerializedTurnSettings[]>(fileContent);
            try
            {
                ValidateSettings(turnSettings);
            }
            catch (JsonException) { throw; }
            for (int j = 0; j < turnSettings.Length; j++)
            {
                for (int i = 0; i < devices.Count; i++)
                {
                    devices[i].LoadDeviceSettings(
                        turnSettings[j].Devices[i]
                            .Settings
                            .Split('|'));
                }
                Durations[j] = turnSettings[j].Time;
            }
        }

        /// <summary>
        /// Megvizsgálja a bemeneti JSON-fájlról, hogy valós adatokat tartalmaz-e. Ez a következőket jelenti:
        /// <br></br>
        /// 1. Az ütemet nem üres eszközlistával próbáljuk meg beállítani.
        /// <br></br>
        /// 2. Az eszközbeállítások eszközeinek sorrendje rendre megegyezik a felmért és tárolt eszközök sorrendjével. 
        /// Ez biztosítja, hogy például egy lámpának ne tudjunk hangértékeket beállítani.
        /// <br></br>---------------------------------------<br></br>
        /// Checks whether the input JSON file contains real data. This means the following:
        /// <br></br>
        /// 1. Attempt to set the turn with a non-empty device list.
        /// <br></br>
        /// 2. The order of the devices in the device settings should be the same as the order of the devices that are mapped and stored. 
        /// This will ensure that, for example, you cannot set sound values for a lamp.
        /// </summary>
        /// <param name="turnSettings"></param>
        /// <exception cref="JsonException"></exception>
        private static void ValidateSettings(SerializedTurnSettings[] turnSettings)
        {
            if (turnSettings == null || turnSettings.Length == 0)
                throw new JsonException("Hibás forrásfájl, az eszközbeállítások helytelen JSON-formátumban vannak tárolva.");

            char readDeviceType; //json-ből érkezik
            foreach (SerializedTurnSettings turn in turnSettings) //Az ütemeket végig kell nézni
            {
                for (int i = 0; i < Devices.Count; i++) //az adott ütemen belül végigmegyek az eszközök listáján, hogy azok típusra megegyeznek-e
                {
                    readDeviceType = turn.Devices[i].Type; //adott ütemhez tartozó eszköz típusa megegyezik-e a tárolt (jelenleg csatlakoztatott) eszközzel
                    if (readDeviceType != devices[i].GetJSONType())
                        throw new JsonException(
                            string.Format($"A beolvasott JSON-forrás helytelen {i + 1}. eszköznél, mert {Devices[i].GetJSONType()} típusú eszköz következne, de {readDeviceType}-típusút olvastam."));
                }
            }
        }
        /// <summary>
        /// Létrehoz egy JSON-fájlt, amelyben az eszközlista aktuális beállításainak állapotát elkészíti (snapshot).
        /// Az elkészült fájl a LoadDeviceSettings-metódussal betölthető.
        /// <br></br>---------------------------------------<br></br>
        /// Creates a JSON file with the current state of the device list settings (snapshot).
        /// The created file can be loaded using the LoadDeviceSettings method.
        /// </summary>
        /// <param name="jsonPathToFile">A menteni kívánt fájl elérési útja.</param>
    public static void UnloadDeviceSettings(string jsonPathToFile)
        {
            SerializedTurnSettings[] turnSettings = new SerializedTurnSettings[turnDurations.Count];
            for (int j = 0; j < turnDurations.Count; j++)
            {
                turnSettings[j] = 
                    new SerializedTurnSettings(
                        devices: new SerializedDeviceSettings[devices.Count],
                        time: turnDurations[j]);
                for (int i = 0; i < devices.Count; i++)
                {
                    turnSettings[j].Devices[i] = new SerializedDeviceSettings(
                        type: devices[i].GetJSONType(),
                        settings: devices[i].GetJSONSettings());
                }
            }
            File.WriteAllText(
                path: jsonPathToFile,
                contents: JsonConvert.SerializeObject(turnSettings, Formatting.Indented));
        }

        /// <summary>
        /// Az eszközlistát JSON-formátumú szöveggé alakítja (szerializálja).
        /// <br></br>---------------------------------------<br></br>
        /// Converts the device list to a JSON-formatted string. In other words, it does the serialization-process from this side.
        /// </summary>
        /// <returns>Az eszközlista JSON-reprezentációja.</returns>
        public static string DevicesToJSON()
        {
            if (devices.Count == 0) 
                return "[]";
            StringBuilder sb = new StringBuilder("[");
            int i;
            for (i = 0; i < devices.Count - 1; i++)
            {
                sb.Append(devices[i].ToString()).Append(",");
            }
            sb.Append(devices[i].ToString()).Append(']');

            return sb.ToString();
        }

        /// <summary>
        /// Delphi-függvényt hív, amely a felmért eszközök tömbjét, a `dev485`-öt JSON-formátumra alakítja (szerializálja), majd ezt a standard formátumot (lényegében csak az eszközök azonosítóját) a C# számára közli.
        /// Ebből a C# legyártja a saját eszközlistáját (`devices`-lista) a megfelelő típusú eszközök példányaival (LED-lámpa, LED-nyíl, Hangszóró).
        /// Ezen az eszközlistán beállításokat tudunk végezni, amelyet ki tudunk küldeni végül a megfelelő eszközök részére.
        /// A lista elérhető FormHelper.Devices property-n keresztül.
        /// <br></br>---------------------------------------<br></br>
        /// A Delphi-function is called that converts (serializes) the array of devices being surveyed, `dev485`, into JSON format, and then communicates this standard format (essentially just the device identifier) to C#.
        /// From this, C# derives its own list of devices (`devices`-list) with instances of the appropriate type of devices (LED lamp, LED arrow, Speaker).
        /// On this device list you can make settings, which you can eventually send out to the appropriate devices.
        /// The list is accessible via the FormHelper.Devices property.
        /// </summary>
        /// <exception cref="JsonException"></exception>
        private static void JSONToDeviceList()
        {
            ConvertDeviceListToJSON(out string jsonFormat);
            //[{"azonos":16388}, {"azonos": 36543}, ...] JSON-formátumú dev485 betöltése a C# környezete számára
            if (!jsonFormat.IsValidJSON())
                throw new JsonException($"Az eszközök leírása helytelen JSON-formátumban történt: {jsonFormat}");
            
            List<SerializedDevice> deserializedDeviceList = JsonConvert.DeserializeObject<List<SerializedDevice>>(jsonFormat);
            
            if (deserializedDeviceList == null)
                throw new JsonException($"Eszközlista létrehozása sikertelen: {jsonFormat}");
            
            for (int i = 0; i < deserializedDeviceList.Count; i++)
                devices.Add(deserializedDeviceList[i].CreateDevice());
        }
        /// <summary>
        /// Szöveg-típusú változóra meghívható kiegészítő (extension) függvény. <br></br>
        /// Eldönti a bemenő JSON-forrásszövegről, hogy az helyes JSON-formátumban van-e.
        /// <br></br>---------------------------------------<br></br>
        /// Extension method for strings.
        /// This function makes a decision whether the given string is in valid JSON-format or not.
        /// </summary>
        /// <param name="source">Forrásszöveg, amit meg akarunk vizsgálni.</param>
        /// <returns>true, ha JSON-formátumban van, különben false.</returns>
        private static bool IsValidJSON(this string source) //extension method for string
        {
            try
            {
                JToken.Parse(source);
                return true;
            }
            catch (JsonReaderException) //ha bármi hiba van a JSON-parse közben, akkor nem lehet valid a JSON-formátum
            {
                return false;
            }
        }
    }
}