using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using SLFormHelper;

namespace SLHelperTestForm
{
    public partial class HelperForm : Form
    {
        public HelperForm()
        {
            InitializeComponent();
            Console.WriteLine("Form handle: 0x{0:X}", this.Handle.ToInt64());
            label1.Text = FormHelper.CallOpen(this.Handle).ToString();
            label2.Text = FormHelper.CallFelmeres().ToString();
            /*//Console.WriteLine(FormHelper.CallListElem());
            //FormHelper.CallFillDev485Static();
            FormHelper.FillDevicesList();
            List<Device> devlist = FormHelper.Devices;
            listBox1.DataSource = devlist;*/
        }

        private int drb485;
        /// <summary>
        /// Ez lényegében a Delphi-ből érkező uzfeld-metódus C#-os változata
        /// Feldolgozza a Win32-es üzeneteket a Form és a rendszer/DLL között.
        /// </summary>
        /// <param name="msg">A feldolgozandó Win32-szabványnak megfelelő üzenet.</param>
        protected override void WndProc(ref Message msg)
        {
            //TODO: itt van a baj, amikor az msg értékeit (WParam, LParam) akarjuk elérni, akkor baj van
            //int responseCode = Marshal.ReadInt32(msg.WParam); //32bites egész értéket olvasunk ki belőle
            //if (responseCode == 0) return;
            //switch (responseCode)
            //{
            //    //-------Pozitív válaszkódok (tájékoztatások) esetei--------
            //    case FELMOK:
            //        this.DRB485 = Marshal.ReadInt32(msg.LParam);
            //        //SLDLL_Listelem(@dev485);

            //        break;
            //    //itt van egy while/for-ciklus, de egyébként nem csinál semmit
            //    case AZOOKE: break;
            //    //megváltoztattam az eszköz számát, akkor jön ez a válasz  
            //    case LEDRGB: break;
            //    //ledbea(PELVSTA(Msg.LParam) ^); - relayelni
            //    case NYIRGB: break;
            //    //nyilbe(PELVSTA(Msg.LParam)^); - relayelni
            //    case HANGEL: break;
            //    //hanbea(PELVSTA(Msg.LParam)^); - relayelni - elég a Msg.LPARAM-ot átadni mindhárom esetben - egész szám értékként kell átadni
            //    case STATKV: break;
            //    //itt kapom vissza az értéket
            //    case LISVAL: break;
            //    //A lista_hívás adja vissza message-ben

            //    //-------Negatív válaszkódok (hibakódok) esetei--------
            //    case USBREM: break;
            //    // Az USB vezérlő eltávolításra került
            //    case VALTIO: break;
            //    // Válaszvárás time-out következett be
            //    case FELMHK: break;
            //    // Felmérés vége hibával
            //    //s := Format(ENDHIK, [Msg.LParam]);
            //    case FELMHD: break;
            //    // Nincs egy darab sem hibakód (elvben sem lehet ilyen)
            //    //s := DARSEM;
            //    case FELMDE: break;
            //    // A 16 és 64 bites darabszám nem egyforma
            //    //s := DARELT;
            //    default:
            //        break;
            //}
            base.WndProc(ref msg);
        }

        //////////////////////////////////////////////////////////////////////////////////////
        //  A DLL használatának megkezdése után az ott megadott üzenetszámra küldött        //
        //  üzenetekkel tartja a kapcsolatot a hívóval. Az üzenet (Message) WParam értéke   //
        //  tartalmazza az üzenet kódját. Ez vagy nagyobb vagy kisebb mint nulla.           //
        //  A negatív érték hibaüzenetet jelent, míg a pozitív az elvégzett művelet         //
        //  végrehajtásáról ad tájékoztatást. Ha az üzenethez tartozik paraméter, adat,     //
        //  akkor arra az üzenet LParam értéke hivatkozik.                                  //
        //////////////////////////////////////////////////////////////////////////////////////
        // Válaszkódok
        private const byte FELMOK = 1;                              // A felmérés rendben lezajlott
        private const byte AZOOKE = 2;                              // Az azonosító váltás rendben lezajlott
                                                                    //private const byte FIRMUZ  = 3;                              // Förmvercsere információs kódja
                                                                    //private const byte FIRMEN  = 4;                              // Förmvercsere vége, újraindítás elndul
        private const byte LEDRGB = 5;                              // A LED lámpa RGB értéke
        private const byte NYIRGB = 6;                              // A nyíl RGB és irány értéke
        private const byte HANGEL = 7;                              // A hangstring állapota
        private const byte STATKV = 8;                              // A státusz értéke
        private const byte LISVAL = 9;                              // A táblázat végének a válasza
                                                                    //Negatív érték 
        private const sbyte USBREM = -1;                             // Az USB vezérlő eltávolításra került
        private const sbyte VALTIO = -2;                             // Felmérés közben válaszvárás time-out következett be
        private const sbyte FELMHK = -3;                             // Felmérés vége hibával
        private const sbyte FELMHD = -4;                             // Nincs egy darab sem hibakód (elvben sem lehet ilyen)
        private const sbyte FELMDE = -5;                             // A 16 és 64 bites darabszám nem egyforma (elvben sem lehet ilyen)

        public int DRB485
        {
            get
            {
                return this.drb485;
            }
            set
            {
                if (value < 0)
                    throw new ArgumentOutOfRangeException("Az eszközök darabszáma nem lehet negatív!");
                drb485 = value;
            }
        }
    }
}
