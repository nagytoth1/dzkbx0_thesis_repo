using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml;

namespace SLFormHelper
{
    public static partial class FormHelper //konténerosztály
    {
        public const string XMLPATH = ".\\devices.xml";
        public const string DLLPATH = "..\\SLDLL_relay\\relay.dll";
        #region CallMethods - I want only them public 
        /// <summary>
        /// Calls the function in converterDLL that calls SLDLL_Open to use SLDLL's functionality.
        /// </summary>
        /// <param name="handle">Form's Handle, SLDLL_Open requires it</param>
        /// <returns></returns>
        /// <exception cref="SLDLLException">When SLDLL_Open was already called.</exception>
        public static int CallOpen(IntPtr handle)
        {
            int result = OpenSLDLL(handle);
            if (result == 1247)
                throw new SLDLLException("Az SLDLL_Open függvény már meg lett hívva korábban.");
            if (result == 1626)
                throw new USBDisconnectedException("Nincs csatlakoztatott USB-eszköz.");
            return result;
        }
        /// <summary>
        /// Detects devices from the USB-port.
        /// </summary>
        /// <returns></returns>
        public static int CallFelmeres()
        {
            int result = Felmeres();

            if (result == 255)
                throw new Dev485Exception("Az eszközöket tartalmazó dev485 tömb üres!");
            if (result == 1114)
                throw new SLDLLException("Az SLDLL_Open-függvény a program ezen pontján még nem lett meghívva.");
            return result;
        }
        /// <summary>
        /// Set 'dev485', the array of devices in Delphi-code.
        /// </summary>
        /// <returns></returns>
        public static int CallListelem(ref int drb485, bool useJSON = true)
        {
            int result = Listelem(ref drb485);
            if (result == 255)
                throw new Dev485Exception("Az eszközöket tartalmazó dev485 tömb üres!");
            if (result == 1114)
                throw new SLDLLException("Az SLDLL_Open-függvény a program ezen pontján még nem lett meghívva.");
            if (useJSON)
                JSONToDeviceList(); //ez fogja feltölteni a C#-os listát*/
            else
                XMLToDeviceList();
            turnDurations.Add(2000); //alapból beállítjuk egy ütem hosszát
            return result;
        }

        /// <summary>
        /// Converts array `dev485` (in Delphi's converterDLL) into a standard JSON-formatted string.<para/>
        /// From the JSON, it creates Device instances depending on the type of device getting detected by converterDLL and adds it to a list in this FormHelper.
        /// List can be reached by calling property FormHelper.Devices
        /// </summary>
        /// <exception cref="Dev485Exception">When empty or unitialized array is given.</exception>
        private static void JSONToDeviceList()
        {
            ConvertDeviceListToJSON(out string jsonFormat);
            //[{"azonos":16388}, {"azonos": 36543}, ...] JSON-formátumú dev485 betöltése a C# környezete számára
            Console.WriteLine("dev485 in JSON-format: " + jsonFormat);
            List<SerializedDevice> deserializedDeviceList = JsonConvert.DeserializeObject<List<SerializedDevice>>(jsonFormat);

            for (int i = 0; i < deserializedDeviceList.Count; i++)
                devices.Add(deserializedDeviceList[i].CreateDevice());
            if (!jsonFormat.IsValidJSON())
            {
                //TODO: logolás fájlba
                Console.WriteLine($"Az eszközök leírása helytelen JSON-formátumban történt: {jsonFormat}");
            }

        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="source"></param>
        /// <returns></returns>
        private static bool IsValidJSON(this string source) //extension method for string
        {
            try
            {
                JToken.Parse(source);
                return true;
            }
            catch (JsonReaderException)
            {
                //TODO: logolás fájlba
                return false;
            }
        }
        /// <summary>
        /// Fills dev485 with static data, like so: 
        /// <para/>1xLEDLight, 
        /// 1xSpeaker 
        /// and 1xLEDArrow device) 
        /// </summary>
        public static void CallFillDev485Static(bool useJSON = true)
        {
            //statikus feltöltés
            FillDev485WithStaticData(); //Delphiben feltölti a dev485-tömböt, drb485-öt beállítja 3-ra
            turnDurations.Add(2000);
            if (useJSON)
                JSONToDeviceList();
            else
                XMLToDeviceList();
            //hangszóró
            Speaker speaker = (Speaker)devices[0];
            speaker.AddSound(Pitch.C_OKTAV4, 63, 500);
            
            //nyíl
            LEDArrow arrow = (LEDArrow)devices[1];
            arrow.Color = Color.Red;
            arrow.Direction = Direction.LEFT;
            
            //lámpa
            LEDLight light = (LEDLight)devices[2];
            light.Color = Color.Green;

            Console.WriteLine(speaker);
            Console.WriteLine(arrow);
            Console.WriteLine(light);
        }
        public static void XMLToDeviceList()
        {
            XmlNodeList nodeList;
            string path = "devices.xml";
            try
            {
                ConvertDeviceListToXML(ref path);
                nodeList = ReadXMLDocument();
            }
            catch (XmlException)
            {
                //TODO: logolás fájlba
                return;
            }

            SerializedDevice serialized; Device deviceToAdd;
            for (int i = 0; i < nodeList.Count; i++)
            {
                if (!uint.TryParse(nodeList[i].Attributes[0].Value, out uint azonos))
                {
                    //TODO: logolás fájlba
                    Console.WriteLine("Az XML-ből kiolvasott azonosító nem szám!");
                }
                serialized = new SerializedDevice(azonos);
                deviceToAdd = serialized.CreateDevice();
                devices.Add(deviceToAdd);
            }
        }

        private static XmlNodeList ReadXMLDocument()
        {
            XmlDocument xmlDocument = new XmlDocument();
            const string TAG_NAME = "device";
            try
            {
                xmlDocument.Load(XMLPATH);
            }
            catch (IOException)
            {
                //TODO: logolás fájlba
                Console.WriteLine("Fájl nem található: {0}", XMLPATH);
            }
            catch (Exception e)
            {
                //TODO: logolás fájlba
                Console.WriteLine("Hiba: {0}", e.Message);
            }

            XmlNodeList nodeList = xmlDocument.GetElementsByTagName(TAG_NAME);
            if (nodeList.Count == 0)
                throw new XmlException(string.Format("XML-ben {0} név alatt nem találhatóak eszközök.", TAG_NAME));
            return nodeList;
        }

        public static void CallSetTurnForEachDevice(ref string json_source)
        {
            SetTurnForEachDevice(ref json_source);
        }
        #endregion
        /// <summary>
        /// A DLL használatának megkezdése.
        /// </summary>
        /// <param name="hwnd">A HWND a Win32 API része. A HWND-ek lényegében olyan értékekkel rendelkező mutatók (IntPtr), amelyek egy Form adataira mutatnak.
        /// <br></br>Ha egy Control HWND-jét szeretnéd látni, használd a Control.Handle mezőt! Ez egy IntPtr típusú változó (egy pointer), amelynek értéke egy HWND-cím.
        /// <br></br>Mivel a HWND-k nem a .NET részei, ezért őket manuálisan kell felszabadítani, a Garbage Collector itt nem lesz a segítségünkre.
        /// <br></br>A felszabadítást a Control.DestroyHandle() paranccsal lehet megtenni a Control életciklusának végén.
        /// <br></br>Az objektumok megsemmisítésének felelőssége szokatlan a .NETben, ebből fakadóan könnyen hibák és memóriaszivárgás forrása lehet.
        /// </param>
        /// <returns>Numerikus érték, amely a végrehajtás sikerességéről tájékoztat.</returns>
        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "Open")]
        extern private static int OpenSLDLL(IntPtr hwnd);

        //2 eszköz -> tömb, SetList függvény, megfelelő paraméterlistával, elemek felmérés, megadod a tömböt, és feltölti, ha a SetList elindul
        //amikor visszajön a SetList, adja vissza a tömböt, nézzük meg, mi van benne dev485
        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "Felmeres")]
        extern private static int Felmeres();

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "Listelem")]
        extern private static byte Listelem([In] ref int drb485);

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "ConvertDEV485ToXML")]
        extern private static byte ConvertDeviceListToXML([MarshalAs(UnmanagedType.BStr)][In] ref string outputStr);

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "ConvertDEV485ToJSON")]
        extern private static byte ConvertDeviceListToJSON([MarshalAs(UnmanagedType.BStr)][Out] out string outputStr);

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "SetTurnForEachDeviceJSON")]
        extern private static byte SetTurnForEachDevice([MarshalAs(UnmanagedType.BStr)][In] ref string json_source);
        
        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "fill_devices_list_with_devices")]
        extern private static byte FillDev485WithStaticData();

        private static List<Device> devices = new List<Device>();
        public static List<Device> Devices { get { return devices; } } //or new List<Device>(devices);
        private static List<ushort> turnDurations = new List<ushort>();
        public static List<ushort> Durations { get { return turnDurations; } set { turnDurations = value; } }

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
    }
}
