using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;

namespace SLFormHelper
{
    public static partial class FormHelper
    {
        /// <summary>
        /// Reads a JSON-file, a snapshot storing the current state of device settings.
        /// Using this method we can create and load pre-set devicelists into the program at runtime.
        /// </summary>
        /// <param name="jsonFile">The path for JSON to be loaded into the program.</param>
        /// <param name="turnNumber">The quantity of devices' turns in the program.</param>
        public static void LoadDeviceSettings(string jsonFile)
        {
            StreamReader reader; string fileContent;
            try
            {
                reader = new StreamReader(jsonFile);
                fileContent = reader.ReadToEnd();
                reader.Close();
            }
            catch (IOException e)
            {
                //TODO:logolás fájlba
                Console.WriteLine($"Hiba történt fájlbeolvasás közben...{e.Message}");
                return;
            }
            List<SerializedTurnSettings> turnSettings = JsonConvert.DeserializeObject<List<SerializedTurnSettings>>(fileContent);
            try
            {
                CheckValidSourceFile(turnSettings.ToArray());
            }
            catch (ArgumentException e)
            {
                //TODO: logolás fájlba
                Console.WriteLine(e.Message);
            }
            for (int j = 0; j < turnSettings.Count; j++)
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

        private static void CheckValidSourceFile(SerializedTurnSettings[] turnSettings)
        {
            if (turnSettings == null || turnSettings.Length == 0)
                throw new ArgumentException("Hibás forrásfájl, az eszközök beállítása helytelen JSON-formátumban van");

            char readDeviceType; //json-ből érkezik
            foreach (SerializedTurnSettings turn in turnSettings) //végigmegyek az ütemeken
            {
                for (int i = 0; i < Devices.Count; i++) //az adott ütemen belül végigmegyek az eszközök listáján, hogy azok típusra megegyeznek-e
                {
                    readDeviceType = turn.Devices[i].Type;
                    if (readDeviceType != devices[i].GetJSONType())
                        throw new ArgumentException(
                            string.Format($"Helytelen forráskód {i + 1}. eszköznél, mert {Devices[i].GetJSONType()} kéne, de {readDeviceType}-t olvastam"));
                }
            }
        }
        /// <summary>
        /// Creates a JSON-file, a snapshot storing the current state of device settings.
        /// The created file can be loaded by method LoadDeviceSettings.
        /// </summary>
        /// <param name="jsonPathToFile">The file JSON should be saved into.</param>
        /// <param name="turnNumber">The quantity of devices' turns in the program.</param>
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
                    Console.WriteLine(devices[i]);
                    turnSettings[j].Devices[i] = new SerializedDeviceSettings(
                        type: devices[i].GetJSONType(),
                        settings: devices[i].GetJSONSettings());
                }
            }
            File.WriteAllText(jsonPathToFile,
                JsonConvert.SerializeObject(turnSettings, Formatting.Indented));
        }
    }
}