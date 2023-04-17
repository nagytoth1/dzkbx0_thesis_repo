using SLFormHelper;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using static SLFormHelper.FormHelper;

namespace SLHelperTestForm
{
    public partial class HelperForm : Form
    {
        private static readonly List<Device> devices = Devices;
        private static List<Device>[] utemek;

        private ushort i = 0;
        private ushort[] ticks = { 2000, 1000, 2000, 1000, 2000, 1000 };
        private Color[] arrowColors = { Color.Green, Color.Red, Color.Blue, Color.Green, Color.Black };
        private Direction[] arrowDirections = { Direction.LEFT, Direction.RIGHT, Direction.LEFT, Direction.RIGHT, Direction.BOTH };
        private Color[] lightColors = { Color.Green, Color.Blue, Color.Black, Color.Blue, Color.Black };
        public HelperForm()
        {
            InitializeComponent();
        }
        private void HelperForm_Load(object sender, EventArgs e)
        {
            try
            {
                //CallOpen(this.Handle);
                //CallFillDev485Static();
                CallFillDev485Static(CJSONDeviceListConverter.GetInstance()); //feltöltöm a tömböt statikus elemekkel
                //CallFillDev485Static(XMLDeviceListConverter.GetInstance());
                utemek = new List<Device>[] //ütemeket veszek fel (ezek a datagrid sorai)
                {
                    DevicesDeepCopy(),
                    DevicesDeepCopy(),
                    DevicesDeepCopy(),
                    DevicesDeepCopy()
                }; // 4 különböző devices lista
                listBox1.DataSource = devices;
                Console.WriteLine("ütemek beállítgatása...");
                for (int i = 0; i < utemek.Length; i++)
                {
                    if(utemek[i][2] is LEDLight light) //minden ütemben a 2. elem lámpa lesz (statikus feltöltés miatt)
                    {
                        light.Color = lightColors[i]; //beállítok színeket ütemenként a lámpának
                    }
                }
                
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
            listBox1.DataSource = devices;
        }
        private void btnLampaPiros_Click(object sender, EventArgs e)
        {
            Device light = devices.Find(x => x is LEDLight);
            if (light == null)
            {
                MessageBox.Show("Nincs lámpa csatlakoztatva!");
                return;
            }
            ((LEDLight)light).Color = Color.FromArgb(255, 0, 0);

            string json_source = JSONDeviceListConverter.DevicesToJSON();
            Console.WriteLine(json_source);
            CallSetTurnForEachDevice(ref json_source);
        }

        private void btnLampaZold_Click(object sender, EventArgs e)
        {
            Device light = devices.Find(x => x is LEDLight);
            if (light == null)
            {
                MessageBox.Show("Nincs lámpa csatlakoztatva!");
                return;
            }
            ((LEDLight)light).Color = Color.FromArgb(0, 255, 0);

            string json_source = JSONDeviceListConverter.DevicesToJSON();
            CallSetTurnForEachDevice(ref json_source);
        }
        private void btnKek_Click(object sender, EventArgs e)
        {
            Device light = devices.Find(x => x is LEDLight);
            if (light == null)
            {
                MessageBox.Show("Nincs lámpa csatlakoztatva!");
                return;
            }
            ((LEDLight)light).Color = Color.FromArgb(0, 0, 255);

            string json_source = JSONDeviceListConverter.DevicesToJSON();
            CallSetTurnForEachDevice(ref json_source);
        }

        private void btnUres_Click(object sender, EventArgs e)
        {
            foreach (Device d in devices)
            {
                if (d is LEDArrow arrow)
                {
                    arrow.Color = Color.Black;
                    arrow.Direction = Direction.BOTH; //0|0|0|2
                    continue;
                }
                if (d is LEDLight light)
                {
                    light.Color = Color.Black; //0|0|0
                    continue;
                }
                if (d is Speaker speaker)
                {
                    speaker.ClearSounds(); //""
                }
            }
            string json_source = JSONDeviceListConverter.DevicesToJSON();
            Console.WriteLine(json_source);
            CallSetTurnForEachDevice(ref json_source);
        }
        private void btnNyil3_Click(object sender, EventArgs e)
        {
            //a felhasználó azt tapasztalja, hogy a kattintásra kék 2 mp-ig, lekapcsol, újból kék 2 mp-ig, majd ismét lekapcsol
            turnTimer.Interval = 1; //a kattintáskor állítsa be a legelső intervallumot 1-re (tehát szinte a kattintás pillanta azonnal aktiválja a Tick-et)
            turnTimer.Enabled = true; //indul a stopwatch, ha letelik x idő (timer.Interval), akkor a Tick
            if (Devices[0] == null)
            {
                MessageBox.Show("Devices tömb üres!"); return;
            }

            if (!(Devices[0] is LEDLight))
            {
                MessageBox.Show("Az eszköz nem lámpa!"); return;
            }
        }
        private void button2Utem_Click(object sender, EventArgs e)
        {
            //a felhasználó azt tapasztalja, hogy a kattintásra kék 2 mp-ig, lekapcsol, újból kék 2 mp-ig, majd ismét lekapcsol
            turnTimerKeteszkoz.Interval = 1; //a kattintáskor állítsa be a legelső intervallumot 1-re (tehát szinte a kattintás pillanta azonnal aktiválja a Tick-et)
            turnTimerKeteszkoz.Enabled = true; //indul a stopwatch, ha letelik x idő (timer.Interval), akkor a Tick
            button2Utem.Enabled = false;
            if (devices.Count < 2)
            {
                MessageBox.Show("Devices tömb nem 2 eszközt tartalmaz!"); return;
            }

            if (!(devices[0] is LEDLight))
            {
                MessageBox.Show("Az első eszköz nem lámpa!"); return;
            }
            if (!(devices[1] is LEDArrow))
            {
                MessageBox.Show("A második eszköz nem nyíl!"); return;
            }
        }

        private void turnTimerKeteszkoz_Tick(object sender, EventArgs e)
        {
            if (devices.Count != 2)
            {
                MessageBox.Show("Két eszköznek kell lennie!");
                return;
            }
            if (!(devices[0] is LEDLight))
            {
                MessageBox.Show("Az első eszköz nem lámpa!\nA nyilat csatlakoztasd közvetlenül a számítógéphez az USB-porton keresztül, aztán a nyílhoz a lámpát. A lámpának adj tápfeszültséget is!");
                return;
            }
            if (!(devices[1] is LEDArrow))
            {
                MessageBox.Show("A második eszköz nem nyíl!\nA nyilat csatlakoztasd közvetlenül a számítógéphez az USB-porton keresztül, aztán a nyílhoz a lámpát. A lámpának adj tápfeszültséget is!");
                return;
            }
            LEDLight light = (LEDLight)devices[0];
            LEDArrow arrow = (LEDArrow)devices[1];
            if (i == 4) //vége a tickelésnek, 2 tick már lezajlott, negyedikre nincs szükségünk
            {
                //állítson vissza mindent eredeti, kezdeti állapotba
                i = 0;
                turnTimerKeteszkoz.Enabled = false;
                button2Utem.Enabled = true;
                //ha vége, akkor kikapcsolja őket
                light.Color = Color.Black;
                arrow.Color = Color.Black;
                string json_s = JSONDeviceListConverter.DevicesToJSON();
                CallSetTurnForEachDevice(ref json_s);
                return;
            }
            turnTimerKeteszkoz.Interval = ticks[i]; //tickenként változzon az ütem hossza
            light.Color = lightColors[i]; //felvillan kéken
            arrow.Color = arrowColors[i];
            arrow.Direction = arrowDirections[i]; //jobbra nyíl
            string json_source = JSONDeviceListConverter.DevicesToJSON();
            try
            {
                CallSetTurnForEachDevice(ref json_source);
                i++; //növelje a "ciklusváltozót", amikor eléri a 4-et, akkor vége a ticknek
            }
            catch (Exception exc)
            {
                MessageBox.Show(exc.Message);
            }
        }
        //JSON-formátum kimentése
        private void kimentBtn_Click(object sender, EventArgs e)
        {
            SaveFileDialog sfd = new SaveFileDialog
            {
                InitialDirectory = Environment.SpecialFolder.MyDocuments.ToString(),
                Filter = "JSON-file (*.json)|*.json"
            };
            string jsonfile;
            if (sfd.ShowDialog() == DialogResult.OK)
            {
                jsonfile = sfd.FileName;
                for (int i = 0; i < utemek.Length; i++) //utemek.Length ugyanaz, mint a dataGrid.Rows.Count lenne
                {
                    JSONSourceHandler.SaveTurn(utemek[i], ref ticks[i]); //ütemenként feltöltjük a tömböt, amit ki akarunk menteni
                }
                JSONSourceHandler.SaveJSON(ref jsonfile); //kimenti egy fájlba a tömböt
            }
        }
        //JSON-fájl betöltése
        private void betoltBtn_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog
            {
                InitialDirectory = Environment.SpecialFolder.MyDocuments.ToString(),
                Filter = "JSON-file (*.json)|*.json"
            };
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    string jsonfile = ofd.FileName;
                    JSONSourceHandler.LoadJSON(ref jsonfile); //betölti a fájlt, feltölti a tömböt
                }
                catch (Exception exc)
                {
                    MessageBox.Show(exc.Message);
                    Logger.WriteLog(exc.Message, SeverityLevel.WARNING);
                    return;
                }
            }
        }
        private void btnLejatszas_MouseClick(object sender, MouseEventArgs e)
        {
            turnTimer.Interval = 1;
            ushort utemCounter = 0;
            turnTimer.Tick += (senderObj, eventArgs) => timer_Tick(ref utemCounter, (ushort)utemek.Length);
            turnTimer.Start();
            btnLejatszas.Enabled = false; //érdemes letiltani a lejátszás idejére a gombot, ne tudja még egyszer megnyomni, amíg futnak az ütemek
            Console.WriteLine("kiküldve!");
        }

        /// <summary>
        /// timer.Enabled = true (vagy timer.Start()) elindít egy Stopwatch-mérést, majd amikor a timer.Interval lejár, a Tick-event kódja lefut.<br></br>
        /// Például ha a timer.Interval = 1000, akkor másodpercenként (1000 millisec időközönként) meghívódik a Tick-event kódja, tehát az alábbi függvény.<br></br>
        /// timer.Enabled = false (vagy timer.Stop()) kikapcsolja a Tick-ek vizsgálatát, az ütemezést
        /// </summary>
        private void timer_Tick(ref ushort act, ushort max)
        {
            if (i == max) //vége a tickelésnek, ha n db tick már lezajlott
            {
                Console.WriteLine("minden kiküldve!");
                //állítson vissza mindent eredeti, kezdeti állapotba
                i = 0;
                turnTimer.Stop();
                btnLejatszas.Enabled = true; //amikor végzett az ütemek kiküldésével, vissza feloldjuk a gombot
                return;
            }
            try
            {
                JSONSourceHandler.LoadTurn(ref i, utemek[i], out ushort turnTime); //i. ütemet betölti
                string json_source = JSONDeviceListConverter.DevicesToJSON(utemek[i].ToArray());
                Console.WriteLine(json_source);
                //turnTimer.Interval = ticks[i]; //1000, 2000, stb... legyen az intervallum
                turnTimer.Interval = 2000;
                //CallSetTurnForEachDevice(ref json_source);
            }
            catch (Exception exc)
            {
                MessageBox.Show(exc.Message);
            }
            i++; //növelje a "ciklusváltozót", amikor eléri a 4-et, akkor vége a tickelésnek
            act++;
            Console.WriteLine($"\t i = {i} \t act = {act}");
        }
    }
}
