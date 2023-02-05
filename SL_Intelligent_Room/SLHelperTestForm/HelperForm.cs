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
                label1.Text = CallOpen(this.Handle).ToString();
            }
            catch (DllNotFoundException ex)
            {
                Logger.WriteLog(ex.Message, SeverityLevel.ERROR);
            }catch (Dev485Exception ex)
            {
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
            //CallWndProc(ref msg, ref dev485Set);
            CallWndProc(ref msg);
            base.WndProc(ref msg);
        }

        private void btnOpen_Click(object sender, EventArgs e)
        {
            label1.Text = CallOpen(this.Handle).ToString();
        }
        private void btnFelmeres_Click(object sender, EventArgs e)
        {
            btnFelmeres.Enabled = false;
            label2.Text = CallFelmeres().ToString();
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
