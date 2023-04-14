using Newtonsoft.Json;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Windows.Forms;

namespace SLFormHelper
{
    public static partial class FormHelper
    {
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
                throw new JsonException("Hibás forrásfájl: Az ütemek listája üres. Jó a JSON-formátum?");
            int turnNumber = turnSettings.Length; //ennyi ütem van a fájlban (legalább 1)
            int devicesPerTurn; //aktuális ütemben ennyi eszköz beállítását olvasta ki a fájlból
            char deviceType; //JSON-ből kiolvasott típus
            int i, j;
            for(j = 0; j < turnNumber; j++) //ütemeken végigmegyünk
            {
                devicesPerTurn = turnSettings[j].Devices.Length; 
                if (devicesPerTurn != devices.Count) //ha valamelyik ütemnél is eltérne az eszközök száma, utasítsuk el a fájlt
                {
                    throw new JsonException($"Hibás forrásfájl: A beolvasott fájlban {j}. ütemnél az eszközök darabszáma ({devicesPerTurn} db) eltér a korábban észlelt eszközök számától {devices.Count}");
                }
                
                for (i = 0; i < devices.Count; i++) //az adott ütemen belül végigmegyek az eszközök listáján, hogy azok típusra megegyeznek-e
                {
                    deviceType = turnSettings[j].Devices[i].Type; //adott ütemhez tartozó eszköz típusa megegyezik-e a tárolt (jelenleg csatlakoztatott) eszközzel
                    if (deviceType != devices[i].GetJSONType())
                        throw new JsonException(
                            string.Format($"Hibás a forrásfájl {j}. ütem {i + 1}. eszközénél: A beolvasott fájlban az eszköz típusa ({deviceType}) eltér a korábban észlelt eszköz  típusától ({devices[i].GetJSONType()})"));
                }
            }
            //ha minden jó, akkor nem dob Exception-t
            MessageBox.Show("A forrásfájlt rendben találtam.");
        }

        /// <summary>
        /// Az eszközlistát JSON-formátumú szöveggé alakítja (szerializálja).
        /// <br></br>---------------------------------------<br></br>
        /// Converts the device list to a JSON-formatted string. In other words, it does the serialization-process from this side.
        /// </summary>
        /// <returns>Az eszközlista JSON-reprezentációja.</returns>
        public static string DevicesToJSON()
        {
            if (Devices.Count == 0)
                return "[]";
            StringBuilder sBuilder = new StringBuilder("[");
            foreach (Device device in Devices)
            {
                //{"type":"L",\"settings\":\"255|0|0\"}
                sBuilder.Append("{\"type\":\"").Append(device.GetJSONType()).Append("\","). //{"type":"L"
                        Append("\"settings\":\"").Append(device.GetJSONSettings()).Append("\"},"); //,"settings":"255|0|0"}
            }
            sBuilder.Remove(sBuilder.Length - 1, 1);
            sBuilder.Append(']');
            return sBuilder.ToString();
        }
        //ütemenként ebbe mentegeti a szerializált dolgokat
        private static List<SerializedTurnSettings> turnsSettings = new List<SerializedTurnSettings>(); 
        /// <summary>
        /// Egyetlen ütemet ment ki JSON-ba. Az eszközök beállítása után kell meghívni, ekkor snapshotot készít a paraméterben kapott devices-lista beállításairól.
        /// </summary>
        /// <param name="turnDevices">A menteni kívánt eszközlista, ami a beállításokat tartalmazza.</param>
        /// <param name="turnTime">A menteni kívánt ütem hossza.</param>
        public static void SaveTurn(List<Device> turnDevices, ref ushort turnTime)
        {
            if (turnDevices == null || turnDevices.Count == 0)
            {
                MessageBox.Show("Az ütembeállítások elmentése meghiúsult: Nincs eszköz feltöltve az ütemben.");
                return;
            }

            SerializedTurnSettings serializedTurn = new SerializedTurnSettings(
                            devices: new SerializedDeviceSettings[turnDevices.Count],
                            time: turnTime);
            
            for(int i = 0; i < turnDevices.Count; i++) //ütemben lévő eszközöket beletesszük
            {
                serializedTurn.Devices[i] = new SerializedDeviceSettings(
                        type: turnDevices[i].GetJSONType(), //aktuális ütem i. eszközének típusa
                        settings: turnDevices[i].GetJSONSettings()); //aktuális ütem i. eszközének beállításai
            }
            turnsSettings.Add(serializedTurn);
        }

        /// <summary>
        /// Létrehoz egy JSON-fájlt, amelyben az eszközlista aktuális beállításainak állapotát elkészíti (snapshot) minden az elmentett ütemekre.
        /// Az elkészült fájl a LoadDeviceSettings-metódussal betölthető.
        /// <br></br>
        /// UPDATE: priváttá tettem, mivel a kimentés implementációja Levente formjában került megírásra. Ezt a metódust nem használjuk.<br></br>
        /// Ez a metódus akkor működne, ha:<br></br>
        ///     1. a turnDurations-listát aktívan használnánk, tehát minden egyes ütemhez külön ütemidők lennének rendelve, jelenleg egyetlen konstans értékkel dolgozunk (pl. ütemenként 2 másodperc)
        ///     2. a DataGrid sorain végighaladva egy Devices-listának állítgatnánk be az elemeit, és ezekről készülhetne pillanatkép/snapshot ütemenként, előtte természetesen az eredeti Devices-listából kellene egy másolatot képezni, ezt tömbbé alakítani
        /// <br></br>---------------------------------------<br></br>
        /// Creates a JSON file with the current state of the device list settings (snapshot).
        /// The created file can be loaded using the LoadDeviceSettings method.
        /// </summary>
        /// <param name="jsonPathToFile">A menteni kívánt fájl elérési útja.</param>
        public static void SaveJSON(ref string jsonPathToFile)
        {
            if (turnsSettings.Count == 0)
            {
                MessageBox.Show("A fájl mentése meghiúsult: Nincs eszköz feltöltve ütemenként.");
                return;
            }

            File.WriteAllText(path: jsonPathToFile,
                contents: JsonConvert.SerializeObject(turnsSettings, Formatting.Indented));
        }

        /// <summary>
        /// Beolvassa a megadott elérési úton szereplő JSON-fájlt, amely az eszközbeállításokat tartalmaz.<br></br>
        /// Ezt a metódust használva betölthetünk előre beállított eszközlistákat a programunkba futásidőben.<br></br>
        /// Az eszközbeállítások mentéséről és tárolásáról az UnloadDeviceSettings-metódus gondoskodik.
        /// <br></br>---------------------------------------<br></br>
        /// Reads the JSON file containing the device settings from the specified path.
        ///Using this method, you can load preconfigured device lists into your program at runtime.
        ///The UnloadDeviceSettings method is used to save and store the device settings.
        /// </summary>
        /// <param name="turn">Hanyadik ütemet szeretnénk betölteni.</param>
        /// <param name="turnDevices">Eszközök listája, amit ki szeretnénk küldeni majd</param>
        /// <param name="turnTime">Ütemek egységes időtartama</param>
        /// <exception cref="JsonException"></exception>
        public static void LoadTurn(ref int turn, List<Device> turnDevices, out ushort turnTime)
        {
            turnTime = 0;
            if (turnsSettings == null || turnsSettings.Count == 0)
            {
                MessageBox.Show("Betöltés meghiúsult: Üres az ütemek listája.");
                return;
            }
            if(turn >= turnsSettings.Count)
            {
                MessageBox.Show($"Betöltés meghiúsult: A betölteni kívánt ütem száma ({turn}) nem haladhatja meg a tárolt ütemek számát ({turnsSettings.Count}).");
                return;
            }
            turnTime = turnsSettings[turn].Time;
            for (int i = 0; i < turnsSettings[turn].Devices.Length; i++)
            {
                turnDevices[i].LoadDeviceSettings(turnsSettings[turn].Devices[i].Settings.Split('|'));
            }
        }

        /// <summary>
        /// Betölti a JSON-fájlból az eszközbeállításokat.
        /// </summary>
        /// <param name="jsonFile">Beolvasni kívánt JSON-fájl elérési útvonala.</param>        
        public static void LoadJSON(ref string jsonFile)
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
                Logger.WriteLog($"Hiba történt fájlbeolvasás közben...{e.Message}", SeverityLevel.ERROR);
                return;
            }
            SerializedTurnSettings[] turnSettings;
            try
            {
                turnSettings = JsonConvert.DeserializeObject<SerializedTurnSettings[]>(fileContent);
                ValidateSettings(turnSettings);
                //innentől valid JSON van, legalább 1 ütem, minden ütemnél stimmel az eszközök típusa
            }
            catch (JsonException e)
            {
                Logger.WriteLog($"Hibás JSON-formátum...{e.Message}", SeverityLevel.WARNING);
                MessageBox.Show(e.Message);
                return;
            }
            turnsSettings = new List<SerializedTurnSettings>(turnSettings);
        }
    }
}