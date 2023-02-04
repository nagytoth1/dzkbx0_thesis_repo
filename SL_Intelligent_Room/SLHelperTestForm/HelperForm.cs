using SLFormHelper;
using System;
using System.Drawing;
using System.Windows.Forms;
using static SLFormHelper.FormHelper;

namespace SLHelperTestForm
{
    public partial class HelperForm : Form
    {
        public HelperForm()
        {
            InitializeComponent();
        }

        private void HelperForm_Load(object sender, EventArgs e)
        {
            label1.Text = CallOpen(this.Handle).ToString();
        }

        private int drb485;
        private bool dev485Set = false;
        /// <summary>
        /// Ez lényegében a Delphi-ből érkező uzfeld-metódus C#-os változata
        /// Feldolgozza a Win32-es üzeneteket a Form és a rendszer/DLL között.
        /// </summary>
        /// <param name="msg">A feldolgozandó Win32-szabványnak megfelelő üzenet.</param>
        protected override void WndProc(ref Message msg)
        {
            if (msg.Msg == 0x0400)
            {
                int responseCode = msg.WParam.ToInt32();
                if (responseCode != 0)
                switch (responseCode)
                {
                    //-------Pozitív válaszkódok (tájékoztatások) esetei--------
                    case FELMOK:
                            this.DRB485 = (int)msg.LParam;
                            if (!dev485Set)
                            {
                                label2.Text = CallListelem(ref drb485).ToString();
                                dev485Set = true;
                                listBox1.DataSource = Devices;
                            }
                        break;
                    //itt van egy while/for-ciklus, de egyébként nem csinál semmit
                    case AZOOKE: break;
                    //megváltoztattam az eszköz számát, akkor jön ez a válasz  
                    case LEDRGB: break;
                    //ledbea(PELVSTA(Msg.LParam) ^); - relayelni
                    case NYIRGB: break;
                    //nyilbe(PELVSTA(Msg.LParam)^); - relayelni
                    case HANGEL: break;
                    //hanbea(PELVSTA(Msg.LParam)^); - relayelni - elég a Msg.LPARAM-ot átadni mindhárom esetben - egész szám értékként kell átadni
                    case STATKV: break;
                    //itt kapom vissza az értéket
                    case LISVAL: break; //A lista_hívás adja vissza message-ben
                    //-------Negatív válaszkódok (hibakódok) esetei--------
                    case USBREM: break;
                    // Az USB vezérlő eltávolításra került
                    case VALTIO: break;
                    // Válaszvárás time-out következett be
                    case FELMHK: break;
                    // Felmérés vége hibával
                    //s := Format(ENDHIK, [Msg.LParam]);
                    case FELMHD: break;
                    // Nincs egy darab sem hibakód (elvben sem lehet ilyen)
                    //s := DARSEM;
                    case FELMDE: break;
                    // A 16 és 64 bites darabszám nem egyforma
                    //s := DARELT;
                    default:
                        break;
                }
            }
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

        private void btnOpen_Click(object sender, EventArgs e)
        {
            label1.Text = CallOpen(this.Handle).ToString();
        }
        private void btnFelmeres_Click(object sender, EventArgs e)
        {
            if (dev485Set)
                btnFelmeres.Enabled = false;
            label2.Text = CallFelmeres().ToString();
            dev485Set = true;
            listBox1.DataSource = Devices;
        }

        private void btnKek_Click(object sender, EventArgs e)
        {
            LEDArrow arrow; LEDLight light; Speaker speaker;
            for (int i = 0; i < drb485; i++)
            {
                if (Devices[i] is LEDArrow)
                {
                    arrow = (LEDArrow)Devices[i];
                    arrow.Color = Color.Blue;
                    arrow.Direction = Direction.RIGHT;
                    continue;
                }
                if (Devices[i] is LEDLight)
                {
                    light= (LEDLight)Devices[i];
                    light.Color = Color.Blue;
                    continue;
                }
                speaker = (Speaker)Devices[i]; //itt baj van, mert egy hangtömböt kéne kiküldeni
                speaker.AddSound(Pitch.G_OKTAV3, volume:64, length:300);
                speaker.AddSound(Pitch.D, volume:63, length:11000);
            }
            string json_source = DevicesToJSON();
            Console.WriteLine(json_source);
            CallSetTurnForEachDevice(ref json_source);
        }

        private void btnUres_Click(object sender, EventArgs e)
        {
            //amikor ki van küldve neki a jel, akkor nem lehet meghívni a felmérést újra, mert mert másik állapotban van az eszköz
            //TODO: ezt még lekezelni
            for (int i = 0; i < drb485; i++)
            {
                if (Devices[i] is LEDArrow arrow)
                {
                    arrow.Color = Color.Black;
                    arrow.Direction = Direction.RIGHT;
                    continue;
                }
                if (Devices[i] is LEDLight light)
                {
                    light.Color = Color.Black;
                    continue;
                }
                if (Devices[i] is Speaker speaker)
                {
                    speaker.ClearSounds();
                    continue;
                }
            }
            string json_source = DevicesToJSON();
            Console.WriteLine(json_source);
            CallSetTurnForEachDevice(ref json_source);
        }

        private void betoltBtn_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.InitialDirectory = Environment.SpecialFolder.MyDocuments.ToString();
            ofd.Filter = "JSON-file (*.json)|*.json";
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                LoadDeviceSettings(ofd.FileName);
                Console.WriteLine("Betöltés miatt {0} lett.", Devices[0]);
                string json_source = DevicesToJSON();
                Console.WriteLine(json_source);
                CallSetTurnForEachDevice(ref json_source);
            }
        }

        private void kimentBtn_Click(object sender, EventArgs e)
        {
            SaveFileDialog sfd = new SaveFileDialog();
            sfd.InitialDirectory = Environment.SpecialFolder.MyDocuments.ToString();
            sfd.Filter = "JSON-file (*.json)|*.json";
            if (sfd.ShowDialog() == DialogResult.OK)
            {
                UnloadDeviceSettings(sfd.FileName);
            }
        }
    }
}
