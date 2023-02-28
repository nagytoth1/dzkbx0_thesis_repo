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
            try
            {
                CallOpen(this.Handle);
                //CallFillDev485Static(true);
            }
            catch (DllNotFoundException ex)
            {
                MessageBox.Show(ex.Message);
                Logger.WriteLog(ex.Message, SeverityLevel.ERROR);
            }catch (Dev485Exception ex)
            {
                MessageBox.Show(ex.Message);
                Logger.WriteLog(ex.Message, SeverityLevel.ERROR);
            }
        }
        //private int drb485;
        /// <summary>
        /// Ez lényegében a Delphi-ből érkező uzfeld-metódus C#-os változata
        /// Feldolgozza a Win32-es üzeneteket a Form és a rendszer/DLL között.
        /// </summary>
        /// <param name="msg">A feldolgozandó Win32-szabványnak megfelelő üzenet.</param>
        protected override void WndProc(ref Message msg)
        {
            CallWndProc(ref msg);
            base.WndProc(ref msg);
        }

        private void btnOpen_Click(object sender, EventArgs e)
        {
            CallOpen(this.Handle);
        }
        private void btnFelmeres_Click(object sender, EventArgs e)
        {
            btnFelmeres.Enabled = false;
            CallFelmeres();
            listBox1.DataSource = Devices;
        }
        private void btnKek_Click(object sender, EventArgs e)
        {
            LEDArrow arrow; LEDLight light; Speaker speaker;
            for (int i = 0; i < DRB485; i++)
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
                    light = (LEDLight)Devices[i];
                    light.Color = Color.Blue;
                    continue;
                }
                speaker = (Speaker)Devices[i]; //itt baj van, mert egy hangtömböt kéne kiküldeni
                speaker.AddSound(Pitch.G_OKTAV3, volume: 64, length: 300);
                speaker.AddSound(Pitch.D, volume: 63, length: 11000);
            }
            string json_source = DevicesToJSON();
            Console.WriteLine(json_source);
            CallSetTurnForEachDevice(ref json_source);
        }

        private void btnUres_Click(object sender, EventArgs e)
        {
            //amikor ki van küldve neki a jel, akkor nem lehet meghívni a felmérést újra, mert mert másik állapotban van az eszköz
            //TODO: ezt még lekezelni
            for (int i = 0; i < DRB485; i++)
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
                try
                {
                    LoadDeviceSettings(ofd.FileName);
                }
                catch (Exception exc)
                {
                    MessageBox.Show(exc.Message);
                    Logger.WriteLog(exc.Message, SeverityLevel.WARNING);
                    return;
                }
                string json_source = DevicesToJSON();
                Console.WriteLine(json_source);
                try
                {
                    CallSetTurnForEachDevice(ref json_source);
                    Console.WriteLine("Ütemek kiküldve!");
                }
                catch(Exception exc)
                {
                    MessageBox.Show(exc.Message);
                }
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
        private bool ledUP = true;
        private ushort[] ticks = { 2000, 1000, 2000, 1000};
        private byte i = 0;
        private void btnNyil3_Click(object sender, EventArgs e)
        {
            //a felhasználó azt tapasztalja, hogy a kattintásra kék 2 mp-ig, lekapcsol, újból kék 2 mp-ig, majd ismét lekapcsol
            turnTimer.Interval = 1; //a kattintáskor állítsa be a legelső intervallumot 1-re (tehát szinte a kattintás pillanta azonnal aktiválja a Tick-et)
            turnTimer.Enabled = true; //indul a stopwatch, ha letelik x idő (timer.Interval), akkor a Tick
            btnNyil3.Enabled = false;
            if (Devices[0] == null)
            {
                MessageBox.Show("Devices tömb üres!"); return;
            }

            if (!(Devices[0] is LEDArrow))
            {
                MessageBox.Show("Az eszköz nem nyíl!"); return;
            }
        }

        /// <summary>
        /// timer.Enabled = true elindít egy Stopwatch-mérést, majd amikor a timer.Interval lejár, a Tick-event kódja lefut.<br></br>
        /// Például ha a timer.Interval = 1000, akkor másodpercenként (1000 millisec időközönként) meghívódik a Tick-event kódja, tehát az alábbi függvény.<br></br>
        /// timer.Enabled = false kikapcsolja a Tick-ek vizsgálatát
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void turnTimer_Tick(object sender, EventArgs e) 
        {
            if (i == 4) //vége a tickelésnek, 3 tick már lezajlott, negyedikre nincs szükségünk
            {
                //állítson vissza mindent eredeti, kezdeti állapotba
                i = 0;
                ledUP = true;
                turnTimer.Enabled = false;
                btnNyil3.Enabled = true;
                return;
            }
            turnTimer.Interval = ticks[i]; //tickenként változzon az ütem hossza
            LEDArrow arrow = (LEDArrow)Devices[0];
            if (ledUP) //ha ledUP értéke igaz, akkor villanjon fel a nyíl balra kék színnel
            {
                arrow.Color = Color.Blue;
                arrow.Direction = Direction.LEFT;
                Console.WriteLine("tik");
            }
            else //ha ledUP értéke hamis, akkor "kapcsolja ki" a nyilat (küldjön fekete színt mindkét irányba)
            {
                arrow.Color = Color.Black;
                arrow.Direction = Direction.BOTH;
                Console.WriteLine("tok");
            }
            string json_source = DevicesToJSON();
            try
            {
                CallSetTurnForEachDevice(ref json_source);
            }
            catch (Exception exc)
            {
                MessageBox.Show(exc.Message);
            }
            ledUP = !ledUP; //negálja a változót, fordítsa ellentettjére, így váltakozva fog fel-le kapcsolni a nyíl
            i++; //növelje a "ciklusváltozót", amikor eléri a 4-et, akkor vége a tickelésnek
        }
    }
}
