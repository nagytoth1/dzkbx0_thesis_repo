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
        public static int CallOpen(IntPtr handle)
        {
            try
            {
                return OpenSLDLL(handle);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                return e.Message.GetHashCode();
            }
        }
        public static int CallFelmeres()
        {
            int result = DetectDevices();

            if(result == 255)
            {
                Console.WriteLine("dev485 empty"); //TODO: saját kivétel ide   
            }
            return result;
        }
        public static void FillDevicesList()
        {
            byte result = ConvertDeviceListToJSON(out string jsonstring); //calls a Delphi-function to convert dev485 to a more understandable json-format
            //from this json-format, we create list of SerializedDevices
            Console.WriteLine(result);

            if (result == 255) //ha dev485 üres
            {
                Console.WriteLine("dev485 empty"); //TODO: saját kivétel ide   
                return;
            }
                
            List<SerializedDevice> serialized = JsonConvert.DeserializeObject<List<SerializedDevice>>(jsonstring);

            for (int i = 0; i < serialized.Count; i++)
                devices.Add(serialized[i].CreateDevice());
        }
        public static byte CallFillDev485Static()
        {
            byte result = FillDev485WithStaticData();
            if(result == 254)
                Console.WriteLine("dev485 already filled"); //TODO: saját kivétel ide 
            return result;
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
