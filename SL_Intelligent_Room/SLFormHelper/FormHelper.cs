using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Xml;

namespace SLFormHelper
{
    public static class FormHelper //konténerosztály
    {
        private const string XMLPATH = "scanned_devices.xml";
        public const string DLLPATH = "SLDLL_relay\\relay.dll";
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
            /*if (result == 1247)
                throw new SLDLLException("You have already called SLDLL_Open");*/
            //if (result == 1626)
            //    throw new USBDisconnectedException("There is no USB device connected.");
            return result;
        }
        /// <summary>
        /// Detects devices from the USB-port.
        /// </summary>
        /// <returns></returns>
        public static int CallFelmeres()
        {
            int result = Felmeres();

            if(result == 255)
                throw new Dev485Exception("Dev485 is null or empty");
            if (result == 1114)
                throw new SLDLLException("You should call SLDLL_Open first!");
            return result;
        }        
        /// <summary>
        /// Set 'dev485', the array of devices in Delphi-code.
        /// </summary>
        /// <returns></returns>
        public static int CallListelem()
        {
            int result = Listelem();
            if (result == 255)
                throw new Dev485Exception("Dev485 is null or empty");
            if (result == 1114)
                throw new SLDLLException("You should call SLDLL_Open first!");
            return result;
        }

        /// <summary>
        /// Converts array `dev485` (in Delphi's converterDLL) into a standard JSON-formatted string.<para/>
        /// From the JSON, it creates Device instances depending on the type of device getting detected by converterDLL and adds it to a list in this FormHelper.
        /// List can be reached by calling property FormHelper.Devices
        /// </summary>
        /// <exception cref="Dev485Exception">When empty or unitialized array is given.</exception>
        public static void FillDevicesList()
        {
            byte result = ConvertDeviceListToJSON(out string jsonstring); //calls a Delphi-function to convert dev485 to a more understandable json-format
            //from this json-format, we create list of SerializedDevices

            if (result == 255) //ha dev485 üres
                throw new Dev485Exception("Dev485 is null or empty");
                
            List<SerializedDevice> serialized = JsonConvert.DeserializeObject<List<SerializedDevice>>(jsonstring);

            for (int i = 0; i < serialized.Count; i++)
                devices.Add(serialized[i].CreateDevice());
        }
        /// <summary>
        /// Fills dev485 with static data, like so: 
        /// <para/>1xLEDLight, 
        /// 1xSpeaker 
        /// and 1xLEDArrow device) 
        /// </summary>
        public static void CallFillDev485Static()
        {
            byte result = FillDev485WithStaticData();
            if (result == 254)
                throw new Dev485Exception("Dev485 is already filled");
        }
        public static void XMLToDeviceList()
        {
            CreateXMLReader(out XmlReader reader);

            if (reader == null)
                return;

            SerializedDevice dev;
            while (reader.Read())
            {
                if (reader.HasAttributes && reader.Name == "device")
                {
                    Console.WriteLine($"Eszköz azonosítója: {reader.GetAttribute("azonos")}");
                    uint.TryParse(reader.GetAttribute("azonos"), out uint devID);
                    dev = new SerializedDevice();
                    dev.Azonos = devID;
                    devices.Add(dev.CreateDevice());
                }
            }
                
        }
        #endregion
        private static void CreateXMLReader(out XmlReader reader)
        {
            reader = null;
            try
            {
                reader = XmlReader.Create(XMLPATH);
            }
            catch (FileNotFoundException)
            {
                throw new FileNotFoundException(string.Format("{0} not found", XMLPATH));
            }
            catch (Exception)
            {
                throw;
            }
        }
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
        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "Listelem")]
        extern private static byte Listelem();

        //function convertDeviceListToJSON(dev485 : PDEVLIS):string; stdcall;
        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "ConvertDEV485ToJSON")]
        extern private static byte ConvertDeviceListToJSON([MarshalAs(UnmanagedType.BStr)] [Out] out string outputStr);

        //procedure fillDeviceListWithDevices(dev485 : PDEVLIS); stdcall;
        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "fill_devices_list_with_devices")]
        extern private static byte FillDev485WithStaticData();

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "ConvertDEV485ToXML")]
        extern private static byte ConvertDeviceListToXML();
        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "SetTurnForEachDeviceJSON")]
        extern private static byte SetTurnForEachDevice();


        private static List<Device> devices = new List<Device>();
        public static List<Device> Devices { get { return new List<Device>(devices); } }
    }
}
