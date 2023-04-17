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
        /// A relayDLL egy metódusát hívja (Open), amely elindítja az SLDLL használatát.
        /// Az ablakos alkalmazás Handle-jét várja, ami ahhoz szükséges, hogy az SLDLL_Open és a többi függvény üzeneteket küldözgethessen az alkalmazásunk számára.
        /// <br></br>---------------------------------------<br></br>
        /// Calls a method in relayDLL (Open) which starts the SLDLL.
        /// It expects the Handle of the windowed application to be passed, this is needed to allow SLDLL_Open and other functions to send messages to our application.
        /// </summary>
        /// <param name="handle">Az ablakos alkalmazás Handle-mezője.</param>
        /// <exception cref="SLDLLException"></exception>
        /// <exception cref="USBDisconnectedException"></exception>
        /// <exception cref="DllNotFoundException"></exception>
        public static void CallOpen(IntPtr handle)
        {
            ushort result = OpenSLDLL(handle);
            if (result == (ushort) Win32Error.ERROR_SUCCESS)
                return;
            if (result == (ushort) Win32Error.ERROR_ALREADY_INITIALIZED)
                throw new SLDLLException("Hiba az SLDLL megnyitásakor: Az SLDLL_Open függvény már meg lett hívva korábban.");
            if (result == (ushort) Win32Error.ERROR_FUNCTION_NOT_CALLED)
                throw new USBDisconnectedException("Hiba az SLDLL megnyitásakor: Nincs csatlakoztatott USB-eszköz.");
        }
        /// <summary>
        /// A relayDLL egy metódusát hívja (Felmeres), amely az USB-portra csatlakoztatott eszközöket (lámpákat, nyilakat, valamint hangszórókat) felméri
        /// <br></br>---------------------------------------<br></br>
        /// Calls a method in relayDLL (Felmeres), which detects devices (lights, arrows and speakers) connected to the USB port
        /// </summary>
        /// <exception cref="DllNotFoundException"></exception>
        /// <exception cref="Dev485Exception"></exception>
        /// <exception cref="SLDLLException"></exception>
        public static void CallFelmeres()
        {
            ushort result = Felmeres();

            if (result == (ushort)Win32Error.ERROR_SUCCESS)
                return;
            if (result == 254)
                throw new Dev485Exception("Hiba felmérés közben: Az eszközöket tartalmazó dev485 tömb üres!");
            if (result == (ushort) Win32Error.ERROR_DLL_INIT_FAILED)
                throw new SLDLLException("Hiba felmérés közben: SLDLL_Open még nem került meghívásra.");
            else
                throw new Exception("Hiba felmérés közben: Egyéb műveleti hiba.");
        }
        /// <summary>
        /// A relayDLL egy metódusát hívja (Listelem), amely a Delphiben tárolt eszközök tömbjét és számát beállítja.
        /// <br></br>---------------------------------------<br></br>
        /// Calls a method in relayDLL (Listelem) that sets the array and number of devices stored in Delphi.
        /// </summary>
        /// <exception cref="DllNotFoundException">Nem találja a DLL-fájlt, az SLDLL_relay mappába helyezett relay.dll állományt.</exception>
        /// <exception cref="Dev485Exception">Nem került beállításra a dev485-tömb (Delphi-oldalon felbukkanó probléma).</exception>
        /// <exception cref="SLDLLException">Az SLDLL_Open nem került még meghívásra.</exception>
        public static void CallListelem(ref byte drb485, DeviceListConverter converter)
        {
            ushort result = Listelem(ref drb485);
            if (result == 254)
                throw new Dev485Exception("Az eszközöket tartalmazó dev485 tömb üres!");
            if (result == (ushort)Win32Error.ERROR_DLL_INIT_FAILED)
                throw new SLDLLException("Hiba az eszközök beállítása közben: SLDLL_Open még nem került meghívásra.");
            if (result == (ushort)Win32Error.ERROR_SUCCESS) //sikeres lefutás esetén
            {
                devices.Clear();
                turnDurations.Clear();
                //megoldás switch-case kiváltására
                converter.ToDeviceList();
                turnDurations.Add(2000); //alapból beállítjuk egy ütem hosszát - 2 másodpercre
            }
        }
        public static void CallListelem(ref byte drb485)
        {
            CallListelem(ref drb485, JSONDeviceListConverter.GetInstance());
        }
        /// A relayDLL egy metódusát hívja (fill_device_list_with_devices), amely a dev485-öt 3 eszközzel tölti fel attól függetlenül, hogy milyen eszközök vannak ténylegesen csatlakoztatva.
        /// <br></br>Csak és kizárólag tesztelésre használjuk.
        /// <para/>1 db LED-lámpa, 1 db Hangszóró és 1 db LED-nyíl eszköz kerül hozzáadásra a devices-listához
        /// <br></br>---------------------------------------<br></br>
        /// Calls a method in relayDLL, which loads dev485 with 3 devices regardless of what devices are actually connected.
        /// <br></br>It is used only for testing purposes.
        /// <para/>1 piece LEDLight, 1 piece Speaker, and 1 piece LEDArrow gets added to device list.
        /// </summary>
        public static void CallFillDev485Static(DeviceListConverter converter)
        {
            byte result = FillDev485WithStaticData(); //Delphiben feltölti a dev485-tömböt, drb485-öt beállítja 3-ra
            if (result == 253)
                throw new Dev485Exception("Az eszközök tömbje már fel lett töltve!");
            turnDurations.Add(2000);
            /*switch (method)
            {
                case ToDeviceList_UsedMethod.JSON:
                    JSONToDeviceList();
                    break;
                case ToDeviceList_UsedMethod.JSON_C:
                    JSONToDeviceList_C();
                    break;
                case ToDeviceList_UsedMethod.XML:
                    XMLToDeviceList();
                    break;
                default:
                    break;
            }*/
            //megoldás switch-case helyett
            converter.ToDeviceList();

            /*
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
            */
        }
        /// <summary>
        /// paraméter nélküli változat, alapból JSONDeviceListConverter osztállyal hívja meg
        /// </summary>
        public static void CallFillDev485Static()
        {
            CallFillDev485Static(JSONDeviceListConverter.GetInstance());
        }
        /// <summary>
        /// Delphi-függvényt hív, amelyben minden egyes csatlakoztatott (tehát felmért) eszköznek kiküld egy ütemnyi jelet 
        /// az adott ütemre vonatkozó beállításainak megfelelően. 
        /// A LED-lámpa és LED-nyíl típusú eszközökre az SLDLL_SetLista-függvény, 
        /// addig Hangszóró típusú eszközök esetében az SLDLL_Hangkuldes-függvény kerül meghívásra.
        /// <br></br>---------------------------------------<br></br>
        /// </summary>
        /// <param name="json_source">DEV485 eszközbeállításainak JSON-formátumú reprezentációja. 
        /// <br></br> Ezt a Helperosztály "DevicesToJSON"-függvénye el is készíti számunkra a devices-lista elemei alapján.</param>
        public static void CallSetTurnForEachDevice(ref string json_source)
        {
            ushort result = SetTurnForEachDevice(ref json_source);
            if (result == (ushort) Win32Error.ERROR_SUCCESS) 
                return;
            if (result == (ushort) Win32Error.ERROR_DLL_INIT_FAILED) 
                throw new SLDLLException("Hiba a beállítások kiküldése közben: SLDLL_Open még nem került meghívásra.");
            if (result == (ushort) Win32Error.ERROR_REQ_NOT_ACCEP) 
                throw new SLDLLException("Hiba a beállítások kiküldése közben: Jelenleg épp fut egy végrehajtás.");
            else throw new Exception($"Egyéb hiba a beállítások kiküldése közben. Hibakód: {result}");
        }
        /// <summary>
        /// Ez lényegében a Delphiben található uzfeld-metódus C#-os változata
        /// Feldolgozza a Win32-es üzeneteket a Form és a rendszer/DLL között.
        /// <br></br>---------------------------------------<br></br>
        /// This is essentially the C# version of the uzfeld method in Delphi
        /// Processes Win32 messages between the Form and the opsystem or DLL.
        /// </summary>
        /// <param name="msg">A feldolgozandó Win32-szabványnak megfelelő üzenet.</param>
        /// <exception cref="ArgumentException"></exception>
        /// <exception cref="SLDLLException"></exception>
        public static void CallWndProc(ref Message msg)
        {
            if (msg.Msg != 0x0400 || msg.WParam.ToInt32() == 0) 
                return;
            ErrorCodes responseCode = (ErrorCodes)msg.WParam.ToInt32();
            switch (responseCode)
            {
                //-------Pozitív válaszkódok (tájékoztatások) esetei--------
                case ErrorCodes.FELMOK:
                    try
                    {
                        DRB485 = (byte)msg.LParam;
                    }
                    catch (ArgumentException) { throw; }
                    //CallListelem(ref drb485, JSONDeviceListConverter.GetInstance()); //ez az alapértelmezett
                    CallListelem(ref drb485, CJSONDeviceListConverter.GetInstance());
                    //CallListelem(ref drb485, XMLDeviceListConverter.GetInstance());
                    break;
                case ErrorCodes.AZOOKE: break;
                //megváltoztattam az eszköz számát, akkor jön ez a válasz  
                case ErrorCodes.LEDRGB: break;
                case ErrorCodes.NYIRGB: break;
                case ErrorCodes.HANGEL: break;
                case ErrorCodes.STATKV: break;
                case ErrorCodes.LISVAL: break; //A lista_hívás adja vissza message-ben
                //-------Negatív válaszkódok (hibakódok) esetei--------
                case ErrorCodes.USBREM:
                    MessageBox.Show("Az USB el lett távolítva!");
                    throw new USBDisconnectedException("Az USB el lett távolítva!");
                // Az USB vezérlő eltávolításra került
                case ErrorCodes.VALTIO: break;
                // Válaszvárás time-out következett be
                case ErrorCodes.FELMHK:
                    throw new SLDLLException("Az eszközök felmérése meghiúsult. Kérlek, csatlakoztasd újra az eszközeidet!");
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
        /// <summary>
        /// Eszközök darabszáma, a Listelem-függvény állítja be.
        /// <br></br>---------------------------------------<br></br>
        /// Number of devices, set by the Listelem function.
        /// </summary>
        private static byte drb485;
        public static byte DRB485 { 
            get { return drb485; } 
            set { 
                if (value < 0)
                    throw new ArgumentException("Eszközök darabszáma nem lehet negatív!");
                drb485 = value;
            } 
        }
        /// <summary>
        /// Hibakódok listája, CallWndProc-függvényhez készítve olvashatóság növelése céljából.
        /// <br></br>---------------------------------------<br></br>
        /// Error code list, created for CallWndProc function in order to increase readability.
        /// </summary>
        private enum ErrorCodes:sbyte
        {
            FELMOK = 1,                       // A felmérés rendben lezajlott
            AZOOKE = 2,                       // Az azonosító váltás rendben lezajlott
            LEDRGB = 5,                       // A LED lámpa RGB értéke
            NYIRGB = 6,                       // A nyíl RGB és irány értéke
            HANGEL = 7,                       // A hangstring állapota
            STATKV = 8,                       // A státusz értéke
            LISVAL = 9,                       // A táblázat végének a válasza 
            USBREM = -1,                      // Az USB vezérlő eltávolításra került
            VALTIO = -2,                      // Felmérés közben válaszvárás time-out következett be
            FELMHK = -3,                      // Felmérés vége hibával
            FELMHD = -4,                      // Nincs egy darab sem hibakód (elvben sem lehet ilyen)
            FELMDE = -5                       // A 16 és 64 bites darabszám nem egyforma (elvben sem lehet ilyen)
        }
        /// <summary>
        /// Szabványos Win32-hibakódok listája, amelyeket az relayDLL-en keresztül az SLDLL dobhat.
        /// <br></br>---------------------------------------<br></br>
        /// List of standard Win32 error codes that can be thrown by SLDLL via relayDLL.
        /// </summary>
        private enum Win32Error:ushort
        {
            ERROR_SUCCESS = 0,
            ERROR_INVALID_DATA = 13,
            ERROR_BAD_LENGTH = 24,
            ERROR_REQ_NOT_ACCEP = 71,
            ERROR_ALREADY_ASSIGNED = 85,
            ERROR_OPEN_FAILED = 110,
            ERROR_MOD_NOT_FOUND = 126,
            ERROR_DLL_INIT_FAILED = 1114,
            ERROR_ALREADY_INITIALIZED = 1247,
            ERROR_FUNCTION_NOT_CALLED = 1626
        }
        #endregion
        #region RelayDLL által exportált (publikus) függvények C#-os átirata
        /// <summary>
        /// SLDLL használatának megkezdése.
        /// <br></br>A HWND a Win32 API része. A HWND-ek lényegében olyan értékekkel rendelkező mutatók (IntPtr), amelyek egy Form adataira mutatnak.
        /// <br></br>Ha egy Control HWND-jét szeretnéd látni, használd a Control.Handle mezőt! Ez egy IntPtr típusú változó (egy pointer), amelynek értéke egy HWND-cím.
        /// <br></br>Mivel a HWND-k nem a .NET részei, ezért őket manuálisan kell felszabadítani, a Garbage Collector itt nem lesz a segítségünkre.
        /// <br></br>A felszabadítást a Control.DestroyHandle() paranccsal lehet megtenni a Control életciklusának végén.
        /// <br></br>Az objektumok megsemmisítésének felelőssége szokatlan a .NETben, ebből fakadóan könnyen hibák és memóriaszivárgás forrása lehet.
        /// <br></br>---------------------------------------<br></br>
        /// <br></br>HWND is a part of the Win32 API. HWNDs are essentially pointers(IntPtr) with values that point to data in a Form.
        /// <br></br>To see the HWND of a Control, use the Control.Handle field. This is an IntPtr variable (a pointer) whose value is a HWND address.
        /// <br></br>Mivel a HWND-k nem a.NET részei, ezért őket manuálisan kell felszabadítani, a Garbage Collector itt nem lesz a segítségünkre.
        /// <br></br>A felszabadítást a Control.DestroyHandle() paranccsal lehet megtenni a Control életciklusának végén.
        /// <br></br>The responsibility of destroying objects is unusual in .NET, hence it can easily be a source of errors and memory leaks.
        /// A method to start using SLDLL.
        /// </summary>
        /// <param name="hwnd">Window Handle of the WinForm application</param>
        /// <returns>Numerikus érték, amely a végrehajtás sikerességéről tájékoztat.</returns>
        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "Open")]
        extern private static ushort OpenSLDLL(IntPtr hwnd);

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "Felmeres")]
        extern private static ushort Felmeres();

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "Listelem")]
        extern private static ushort Listelem([In] ref byte drb485);      

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "SetTurnForEachDeviceJSON")]
        extern private static ushort SetTurnForEachDevice([MarshalAs(UnmanagedType.BStr)][In] ref string json_source);

        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Ansi, EntryPoint = "fill_devices_list_with_devices")]
        extern private static byte FillDev485WithStaticData();
        [DllImport(DLLPATH, CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode, EntryPoint = "set_turn_static")]
        extern private static byte SetTurnWithStaticStatic([MarshalAs(UnmanagedType.BStr)][In] ref string json_source);
        
        #endregion
        #region Mezők
        /// <summary>
        /// The path of relayDLL.
        /// </summary>
        public const string DLLPATH = "..\\SLDLL_relay\\relay.dll";
        private static readonly List<Device> devices = new List<Device>(); //DLL-en belül lista típusú, mivel nem tudjuk, pontosan milyen hosszú lesz
        private static List<ushort> turnDurations = new List<ushort>();
        /// <summary>
        /// Eszközbeállítások ütemezésére használt lista. Egy programban tetszőleges számú ütemet küldhetünk ki az eszközök részére, ezért lista adatszerkezetet választottam.
        /// <br></br>---------------------------------------<br></br>
        /// List used to schedule device settings. In the program, you can send out any number of turns to devices, this is why I have chosen the list data structure.
        /// </summary>
        public static List<ushort> Durations { get { return turnDurations; } set { turnDurations = value; } }
        /// <summary>
        /// SLDLL-eszközök (LED-lámpák, LED-nyilak és hangszórók) listája, ez a relayDLL dev485-tömbjének C#-megfelelője. CallListelem-függvény meghívásakor kerül átadásra és feltöltésre.
        /// <br></br>---------------------------------------<br></br>
        /// List of SLDLL-devices (LED lights, LED arrows and speakers), this is basically the C# equivalent of the dev485 block of relayDLL. It is passed and populated when the CallListelem function is called.
        /// </summary>
        public static List<Device> Devices { get { return devices; } }
        //public static List<Device> DevicesCopy(){ return new List<Device>(devices); } //shallow copy lesz, az eszközök referenciái meg fognak egyezni
        public static List<Device> DevicesDeepCopy() 
        { 
            List<Device> devicesCopy = new List<Device>();
            
            foreach (Device d in devices)
            {
                devicesCopy.Add(d.Clone());
            }

            return devicesCopy;
        }
        #endregion
    }
}
