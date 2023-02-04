using System;
using System.IO;
using System.Xml;

namespace SLFormHelper
{
    public static partial class FormHelper //konténerosztály
    {
        public const string XMLPATH = ".\\devices.xml";
        /// <summary>
        /// Delphi-függvényt hív, amely a felmért eszközök tömbjét, a `dev485`-öt XML-formátumra alakítja (szerializálja), majd ezt a standard formátumot (lényegében csak az eszközök azonosítóját) a C# számára közli.
        /// Ebből a C# legyártja a saját eszközlistáját (`devices`-lista) a megfelelő típusú eszközök példányaival (LED-lámpa, LED-nyíl, Hangszóró).
        /// Ezen az eszközlistán beállításokat tudunk végezni, amelyet ki tudunk küldeni végül a megfelelő eszközök részére.<br></br>
        /// A lista elérhető FormHelper.Devices property-n keresztül.
        /// </summary>
        /// <exception cref="XmlException"></exception>
        public static void XMLToDeviceList()
        {
            XmlNodeList nodeList;
            string path = "devices.xml";
            try
            {
                //TODO: DelphiDLL-t hív, ennek milyen visszatérési értékei vannak? - ennek megfelelő Exception-öket dobni
                ConvertDeviceListToXML(ref path);
                nodeList = ReadXMLDocument();
            }
            catch (XmlException xmlEx)
            {
                Logger.WriteLog(xmlEx.Message, SeverityLevel.ERROR);
                return;
            }

            SerializedDevice serialized; Device deviceToAdd;
            for (int i = 0; i < nodeList.Count; i++)
            {
                if (!uint.TryParse(nodeList[i].Attributes[0].Value, out uint azonos))
                {
                    Logger.WriteLog("Az XML-ből olvasott azonosító nem szám!", SeverityLevel.WARNING);
                }
                serialized = new SerializedDevice(azonos);
                deviceToAdd = serialized.CreateDevice();
                devices.Add(deviceToAdd);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <exception cref="IOException"></exception>
        /// <exception cref="Exception"></exception>
        /// <returns></returns>
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
                Logger.WriteLog(string.Format("XML-forrásfájl nem található: {0}", XMLPATH));
            }
            catch (Exception e)
            {
                Logger.WriteLog(string.Format("Hiba XML beolvasásakor: {0}", e.Message));
            }

            XmlNodeList nodeList = xmlDocument.GetElementsByTagName(TAG_NAME);

            if (nodeList.Count == 0) //if no nodes match name, the collection will be empty
                throw new XmlException(string.Format("XML-ben {0} név alatt nem találhatóak eszközök.", TAG_NAME));

            return nodeList;
        }
    }
}
