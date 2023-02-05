using System;
using System.Collections.Generic;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace SLFormHelper
{
    public static partial class FormHelper //konténerosztály
    {
        #region Hívó függvények - meghívják a DLL-ből hívható metódusokat
        /// <summary>
        /// Delphi-metódust hív (Open), amely elindítja az SLDLL használatát.
        /// </summary>
        /// <param name="handle">Az ablakos alkalmazás Handle-je, ez ahhoz kell, hogy az SLDLL_Open és a többi függvény üzeneteket küldözgethessen az alkalmazásunk számára.</param>
        /// <exception cref="SLDLLException"></exception>
        /// <exception cref="USBDisconnectedException"></exception>
        /// <returns>Numerikus érték, amely a végrehajtás sikerességéről tájékoztat.</returns>
        public static int CallOpen(IntPtr handle)
        {
            //TODO: DelphiDLL-t hív, ennek milyen visszatérési értékei vannak? - ennek megfelelő Exception-öket dobni
            int result = OpenSLDLL(handle);
            if (result == 1247)
                throw new SLDLLException("Az SLDLL_Open függvény már meg lett hívva korábban.");
            if (result == 1626)
                throw new USBDisconnectedException("Nincs csatlakoztatott USB-eszköz.");
            return result;
        }
        /// <summary>
        /// Delphi-metódust hív (Felmeres), amely az USB-portra csatlakoztatott eszközöket (lámpákat, nyilakat, valamint hangszórókat) felméri
        /// </summary>
        /// <returns>Numerikus érték, amely a végrehajtás sikerességéről tájékoztat.</returns>
        public static int CallFelmeres()
        {
            //TODO: DelphiDLL-t hív, ennek milyen visszatérési értékei vannak? - ennek megfelelő Exception-öket dobni
            int result = Felmeres();

            if (result == 255)
                throw new Dev485Exception("Az eszközöket tartalmazó dev485 tömb üres!");
            if (result == 1114)
                throw new SLDLLException("Az SLDLL_Open-függvény a program ezen pontján még nem lett meghívva.");
            return result;
        }
        /// <summary>
        /// Delphi-metódust hív (Listelem), amely a Delphiben tárolt eszközök tömbjét és számát beállítja.
        /// </summary>
        /// <returns>Numerikus érték, amely a végrehajtás sikerességéről tájékoztat.</returns>
        public static int CallListelem(ref byte drb485, bool useJSON = true)
        {
            //TODO: DelphiDLL-t hív, ennek milyen visszatérési értékei vannak? - ennek megfelelő Exception-öket dobni
            int result = Listelem(ref drb485);
            if (result == 255)
                throw new Dev485Exception("Az eszközöket tartalmazó dev485 tömb üres!");
            if (result == 1114)
                throw new SLDLLException("Az SLDLL_Open-függvény a program ezen pontján még nem lett meghívva.");
            if (devices.Count != 0) //ha nem üres az eszközlista, ürítsük ki az eszköz- és ütemek listáját
            {
                devices.Clear();
                turnDurations.Clear();
            }
            if (useJSON)
                JSONToDeviceList(); //ez fogja feltölteni a C#-os listát*/
            else
                XMLToDeviceList();
            turnDurations.Add(2000); //alapból beállítjuk egy ütem hosszát
            return result;
        }
        /// <summary>
        /// Delphi-metódust hív, amely a dev485-öt 3 eszközzel tölti fel attól függetlenül, hogy milyen eszközök vannak ténylegesen csatlakoztatva.
        /// <br></br>Csak és kizárólag tesztelésre használjuk.
        /// <para/>1 db LED-lámpa, 1 db Hangszóró és 1 db LED-nyíl eszköz
        /// </summary>
        public static void CallFillDev485Static(bool useJSON = true)
        {
            //TODO: DelphiDLL-t hív, ennek milyen visszatérési értékei vannak? - ennek megfelelő Exception-öket dobni
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
        /// <summary>
        /// Delphi-függvényt hív, amelyben minden egyes csatlakoztatott (tehát felmért) eszköznek kiküld egy ütemnyi jelet az adott ütemre vonatkozó beállításainak megfelelően. 
        /// A LED-lámpa és LED-nyíl típusú eszközökre az SLDLL_SetLista-függvény, addig Hangszóró típusú eszközök esetében az SLDLL_Hangkuldes-függvény kerül meghívásra.
        /// </summary>
        /// <param name="json_source">DEV485 eszközbeállításainak JSON-formátumú reprezentációja. <br></br> Ezt a Helperosztály "DevicesToJSON"-függvénye el is készíti számunkra a devices-lista elemei alapján.</param>
        public static void CallSetTurnForEachDevice(ref string json_source)
        {
            //TODO: DelphiDLL-t hív, ennek milyen visszatérési értékei vannak? - ennek megfelelő Exception-öket dobni
            SetTurnForEachDevice(ref json_source);
        }
        /// <summary>
        /// Ez lényegében a Delphiben található uzfeld-metódus C#-os változata
        /// Feldolgozza a Win32-es üzeneteket a Form és a rendszer/DLL között.
        /// </summary>
        /// <param name="msg">A feldolgozandó Win32-szabványnak megfelelő üzenet.</param>
        public static void CallWndProc(ref Message msg)
        {
            if (msg.Msg != 0x0400 || msg.WParam.ToInt32() == 0) 
                return;
            ErrorCodes responseCode = (ErrorCodes)msg.WParam.ToInt32();
            switch (responseCode)
            {
                //-------Pozitív válaszkódok (tájékoztatások) esetei--------
                case ErrorCodes.FELMOK:
                    drb485 = (byte)msg.LParam;
                    CallListelem(ref drb485, true).ToString();
                    break;
                case ErrorCodes.AZOOKE: break;
                //megváltoztattam az eszköz számát, akkor jön ez a válasz  
                case ErrorCodes.LEDRGB: break;
                //ledbea(PELVSTA(Msg.LParam) ^); - relayelni
                case ErrorCodes.NYIRGB: break;
                //nyilbe(PELVSTA(Msg.LParam)^); - relayelni
                case ErrorCodes.HANGEL: break;
                //hanbea(PELVSTA(Msg.LParam)^); - relayelni - elég a Msg.LPARAM-ot átadni mindhárom esetben - egész szám értékként kell átadni
                case ErrorCodes.STATKV: break;
                //itt kapom vissza az értéket
                case ErrorCodes.LISVAL: break; //A lista_hívás adja vissza message-ben
                                    //-------Negatív válaszkódok (hibakódok) esetei--------
                case ErrorCodes.USBREM: break;
                // Az USB vezérlő eltávolításra került
                case ErrorCodes.VALTIO: break;
                // Válaszvárás time-out következett be
                case ErrorCodes.FELMHK: break;
                // Felmérés vége hibával
                //s := Format(ENDHIK, [Msg.LParam]);
                case ErrorCodes.FELMHD: break;
                // Nincs egy darab sem hibakód (elvben sem lehet ilyen)
                //s := DARSEM;
                case ErrorCodes.FELMDE: break;
                // A 16 és 64 bites darabszám nem egyforma
                //s := DARELT;
                default:
                    break;
            }
        }
        private static byte drb485;
        public static byte DRB485 { 
            get { return drb485; } 
            set { 
                if (value < 0) 
                    throw new ArgumentException("Eszközök darabszáma nem lehet negatív!");
                drb485 = value;
            } 
        }
        enum ErrorCodes:sbyte
        {
            FELMOK = 1,                       // A felmérés rendben lezajlott
            AZOOKE = 2,                       // Az azonosító váltás rendben lezajlott
            LEDRGB = 5,                       // A LED lámpa RGB értéke
            NYIRGB = 6,                       // A nyíl RGB és irány értéke
            HANGEL = 7,                       // A hangstring állapota
            STATKV = 8,                       // A státusz értéke
            LISVAL = 9,                       // A táblázat végének a válasza 
            USBREM = -1,                        // Az USB vezérlő eltávolításra került
            VALTIO = -2,                        // Felmérés közben válaszvárás time-out következett be
            FELMHK = -3,                        // Felmérés vége hibával
            FELMHD = -4,                        // Nincs egy darab sem hibakód (elvben sem lehet ilyen)
            FELMDE = -5                       // A 16 és 64 bites darabszám nem egyforma (elvben sem lehet ilyen)
        }
        #endregion
        #region RelayDLL által exportált (publikus) függvények C#-os átirata
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

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "Felmeres")]
        extern private static int Felmeres();

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "Listelem")]
        extern private static int Listelem([In] ref byte drb485);

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "ConvertDEV485ToXML")]
        extern private static byte ConvertDeviceListToXML([MarshalAs(UnmanagedType.BStr)][In] ref string outputStr);

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "ConvertDEV485ToJSON")]
        extern private static byte ConvertDeviceListToJSON([MarshalAs(UnmanagedType.BStr)][Out] out string outputStr);

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "SetTurnForEachDeviceJSON")]
        extern private static byte SetTurnForEachDevice([MarshalAs(UnmanagedType.BStr)][In] ref string json_source);

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "fill_devices_list_with_devices")]
        extern private static byte FillDev485WithStaticData();
        #endregion
        #region Mezők
        private const string DLLPATH = "..\\SLDLL_relay\\relay.dll";
        private static List<Device> devices = new List<Device>();
        private static List<ushort> turnDurations = new List<ushort>();
        public static List<ushort> Durations { get { return turnDurations; } set { turnDurations = value; } }
        public static List<Device> Devices { get { return devices; } }
        #endregion
    }
}
