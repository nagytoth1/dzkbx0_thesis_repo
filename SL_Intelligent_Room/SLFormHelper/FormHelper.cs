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

        //[DllImport(@"SL_2\SLDLL.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "SLDLL_Open")]
        //extern public static int SLDLL_Open(IntPtr handle, int message, [MarshalAs(UnmanagedType.AnsiBStr)] out IntPtr nevlei, [MarshalAs(UnmanagedType.AnsiBStr)] out IntPtr device);
        [DllImport(@"..\..\..\SL_2\converter.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "Open")]
        extern public static int OpenSLDLL(IntPtr handle);

        //function SLDLL_Felmeres: Dword; stdcall; external SLDLL_PATH;
        //2 eszköz -> tömb, SetList függvény, megfelelő paraméterlistával, elemek felmérés, megadod a tömböt, és feltölti, ha a SetList elindul
        //amikor visszajön a SetList, adja vissza a tömböt, nézzük meg, mi van benne dev485
        //function Open(wndhnd:DWord): DWord; stdcall; - ő az SLDLL_Felmeres és SLDLL_Listelem metódusokat hívja
        [DllImport(@"..\..\..\SL_2\converter.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "DetectDevices")]
        extern public static int DetectDevices();

        //function convertDeviceListToJSON(dev485 : PDEVLIS):string; stdcall;
        [DllImport(@"..\..\..\SL_2\converter.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "convertDeviceListToJSON")]
        extern public static void ConvertDeviceListToJSON([MarshalAs(UnmanagedType.BStr)] [Out] out string outputStr);
        //procedure fillDeviceListWithDevices(dev485 : PDEVLIS); stdcall;
        [DllImport(@"..\..\..\SL_2\converter.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "fillDeviceListWithDevices")]
        extern public static void FillDev485WithStaticData();

        #region XMLHandling
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
        #endregion

        #region CallMethods - I want only them public 
        private static int CallOpen(IntPtr handle)
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
        private static int CallFelmeres()
        {
            try
            {
                return DetectDevices();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                return e.Message.GetHashCode();
            }
        }
        public static void FillDevicesList()
        {
            ConvertDeviceListToJSON(out string jsonstring); //calls a Delphi-function to convert dev485 to a more understandable json-format
            //from this json-format, we create list of SerializedDevices
            List<SerializedDevice> serialized = JsonConvert.DeserializeObject<List<SerializedDevice>>(jsonstring);

            for (int i = 0; i < serialized.Count; i++)
                devices.Add(serialized[i].CreateDevice());
        }
        #endregion


    }
}
