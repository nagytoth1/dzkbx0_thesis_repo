using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace SLFormHelper
{
    public static partial class FormHelper
    {
        /// <summary>
        /// Beolvassa a megadott elérési úton szereplő JSON-fájlt, amely az eszközbeállításokat tartalmaz.<br></br>
        /// Ezt a metódust használva betölthetünk előre beállított eszközlistákat a programunkba futásidőben.<br></br>
        /// Az eszközbeállítások mentéséről és tárolásáról az UnloadDeviceSettings-metódus gondoskodik.
        /// </summary>
        /// <param name="jsonFile">Beolvasni kívánt JSON-fájl elérési útvonala.</param>
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
            catch (JsonException e)
            {
                Logger.WriteLog(e.Message, SeverityLevel.WARNING);
                return;
            }
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
        /// 1. Az ütemet nem üres eszközlistával próbáljuk meg beállítani.
        /// 2. Az eszközbeállítások eszközeinek sorrendje rendre megegyezik a felmért és tárolt eszközök sorrendjével. 
        /// Ez biztosítja, hogy például egy lámpának ne tudjunk hangértékeket beállítani.
        /// </summary>
        /// <param name="turnSettings"></param>
        /// /// <exception cref="JsonException"></exception>
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
        /// </summary>
        /// <returns>Az eszközlista JSON-reprezentációja.</returns>
        public static string DevicesToJSON()
        {
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
        /// </summary>
        /// <exception cref="JsonException"></exception>
        private static void JSONToDeviceList()
        {
            //TODO: DelphiDLL-t hív, ennek milyen visszatérési értékei vannak? - ennek megfelelő Exception-öket dobni
            ConvertDeviceListToJSON(out string jsonFormat);
            //[{"azonos":16388}, {"azonos": 36543}, ...] JSON-formátumú dev485 betöltése a C# környezete számára
            if (!jsonFormat.IsValidJSON())
            {
                throw new JsonException($"Az eszközök leírása helytelen JSON-formátumban történt: {jsonFormat}");
            }
            List<SerializedDevice> deserializedDeviceList = JsonConvert.DeserializeObject<List<SerializedDevice>>(jsonFormat);
            if (deserializedDeviceList == null)
                throw new JsonException($"Eszközlista létrehozása sikertelen: {jsonFormat}");
            for (int i = 0; i < deserializedDeviceList.Count; i++)
                devices.Add(deserializedDeviceList[i].CreateDevice());
        }
        /// <summary>
        /// Szöveg-típusú változóra meghívható kiegészítő (extension) függvény. <br></br>
        /// Eldönti a bemenő JSON-forrásszövegről, hogy az helyes JSON-formátumban van-e.
        /// </summary>
        /// <param name="source">Forrásszöveg</param>
        /// <returns>Logikai érték.</returns>
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