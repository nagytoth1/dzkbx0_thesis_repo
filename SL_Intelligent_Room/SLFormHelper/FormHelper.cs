using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;

namespace SLFormHelper
{
    public static class FormHelper //konténerosztály
    {
        private static List<Device> devices = new List<Device>();
        public static List<Device> Devices
        {
            get { return new List<Device>(devices); }
        }

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
                throw new SLDLLException("You have already called SLDLL_Open");
            //if (result == 1626) - what is error 1626?
                //throw new SLDLLException("");
            return result;
        }
        /// <summary>
        /// Detects devices from the USB-port.
        /// </summary>
        /// <returns></returns>
        public static int CallFelmeres()
        {
            int result = DetectDevices();

            if(result == 255)
                throw new Dev485Exception("Dev485 is null or empty");
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
            Console.WriteLine(result);

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
                //Console.WriteLine("dev485 already filled"); //TODO: saját kivétel ide 
        }
        public static void XMLToDeviceList()
        {
            createReader(out XmlReader reader);

            if (reader == null)
                return;

            SerializedDevice dev;
            while (reader.Read())
                if (reader.HasAttributes && reader.Name == "device")
                {
                    Console.WriteLine($"Eszköz azonosítója: {reader.GetAttribute("azonos")}");
                    uint.TryParse(reader.GetAttribute("azonos"), out uint devID);
                    dev = new SerializedDevice();
                    dev.Azonos = devID;
                    devices.Add(dev.CreateDevice());
                }
        }
        #endregion
        private static void createReader(out XmlReader reader)
        {
            reader = null;
            try
            {
                reader = XmlReader.Create("scanned_devices.xml");
            }
            catch (FileNotFoundException)
            {
                Console.WriteLine("scanned_devices.xml not found");
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }
        [DllImport(@"converterDLL\relay.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "openDLL")]
        extern private static int OpenSLDLL(IntPtr handle);

        //2 eszköz -> tömb, SetList függvény, megfelelő paraméterlistával, elemek felmérés, megadod a tömböt, és feltölti, ha a SetList elindul
        //amikor visszajön a SetList, adja vissza a tömböt, nézzük meg, mi van benne dev485
        [DllImport(@"converterDLL\relay.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "detectDevices")]
        extern private static int DetectDevices();

        //function convertDeviceListToJSON(dev485 : PDEVLIS):string; stdcall;
        [DllImport(@"converterDLL\relay.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "convertDeviceListToJSON")]
        extern private static byte ConvertDeviceListToJSON([MarshalAs(UnmanagedType.BStr)] [Out] out string outputStr);

        //procedure fillDeviceListWithDevices(dev485 : PDEVLIS); stdcall;
        [DllImport(@"converterDLL\relay.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "fillDeviceListWithDevices")]
        extern private static byte FillDev485WithStaticData();

        [DllImport(@"converterDLL\relay.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "convertDeviceListToXML")]
        extern private static byte ConvertDeviceListToXML();
    }
}
