using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;

namespace SLFormHelper
{
    public static partial class FormHelper
    {
        public partial class JSONHandler
        {
            /// <summary>
            /// Reads a JSON-file, a snapshot storing the current state of device settings.
            /// Using this method we can create and load pre-set devicelists into the program at runtime.
            /// </summary>
            /// <param name="jsonFile">The path for JSON to be loaded into the program.</param>
            /// <param name="turnNumber">The quantity of devices' turns in the program.</param>
            public static void LoadDeviceSettings(string jsonFile, byte turnNumber)
            {
                turnDurations = new ushort[turnNumber]; //ha 5 db ütem van felvéve, 5 hosszú tömb lesz
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
            /// <param name="jsonDirectory">The directory to which JSON should be placed.</param>
            /// <param name="turnNumber">The quantity of devices' turns in the program.</param>
            public static void UnloadDeviceSettings(string jsonDirectory, byte turnNumber)
            {
                // get the file attributes for file or directory
                FileAttributes path_attributes = File.GetAttributes(jsonDirectory);
                string path;
                //if given path is not a directory, get the folder the file belongs to and place the output there
                path = path_attributes.HasFlag(FileAttributes.Directory) ? 
                    jsonDirectory : 
                    Path.GetDirectoryName(jsonDirectory);
                
                SerializedTurnSettings[] turnSettings = new SerializedTurnSettings[turnNumber];
                for (int j = 0; j < turnSettings.Length; j++)
                {
                    turnSettings[j] = new SerializedTurnSettings(
                            devices: new SerializedDeviceSettings[devices.Count],
                            time: turnDurations[j]);
                    for (int i = 0; i < devices.Count; i++)
                    {
                        turnSettings[j].Devices[i].Type = devices[i].GetJSONType();
                        turnSettings[j].Devices[i].Settings = devices[i].GetJSONSettings();
                    }
                }
                File.WriteAllText(string.Format($"{path}\\deviceSettings.json"),
                    JsonConvert.SerializeObject(turnSettings, Formatting.Indented));
            }
        }
    }
}