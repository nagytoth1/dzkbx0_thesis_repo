using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using SLFormHelper;

namespace SLHelperTestForm
{
    public partial class HelperForm : Form
    {
        public HelperForm()
        {
            InitializeComponent();


            //ha nem volt még meghívva az open, akkor felméréskor 1114-et dob
            label1.Text = FormHelper.OpenSLDLL(this.Handle).ToString();
            label2.Text = FormHelper.DetectDevices().ToString();
            
            FormHelper.ConvertDeviceListToJSON(out string json);
            Console.WriteLine(json);
            FormHelper.FillDevicesList();
            List<Device> devlist = FormHelper.Devices;
            listBox1.DataSource = devlist;


        }
    }
}
