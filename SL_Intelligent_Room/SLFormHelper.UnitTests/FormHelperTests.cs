using NUnit.Framework;
using SLHelperTestForm;
using System;
using System.Threading;
using System.Windows.Forms;
using static SLFormHelper.FormHelper;
namespace SLFormHelper.UnitTests
{
    [TestFixture]
    public class FormHelperTests
    {
        HelperForm testForm =  new HelperForm();
        [Test]
        public void SLDLL_Open_Scenario_Success()
        {
            //call this when USB device is disconnected
            Assert.DoesNotThrow(() => testForm.Show());
        }
        
        [Test]
        public void SLDLL_Open_Scenario_Called()
        {
            testForm.Show();
            Assert.Throws<SLDLLException>(() => CallOpen(testForm.Handle), "Az SLDLL_Open függvény már meg lett hívva korábban.");
        }

        [Test]
        public void SLDLL_Felmeres_Scenario_OpenNotCalled()
        {
            Assert.Throws<SLDLLException>(() => CallFelmeres(), "Az SLDLL_Open-függvény a program ezen pontján még nem lett meghívva.");
        }

        [Test]
        public void CallListElem_Scenario_Success_NDeviceConnected()
        {
            byte expected = 1;
            testForm.Show();
            MessageBox.Show("Form megnyílt...");
            Assert.That(DRB485 == expected);
        }

        [Test]
        public void CallListElem_Scenario_OpenNotCalled()
        {
            byte actual = 0;
            Assert.Throws<SLDLLException>(() => CallListelem(ref actual), "Az SLDLL_Open-függvény a program ezen pontján még nem lett meghívva.");
        }

        [Test]
        public void SLDLL_Felmeres_Scenario_Success()
        {
            testForm.Show();
            CallFelmeres();
        }

        //call this when HelperForm.DLLPATH is set wrong
        [Test]
        public void SLDLL_Open_Scenario_NoDLL()
        {
            Assert.Throws<DllNotFoundException>(() => CallOpen(testForm.Handle));
        }
        [Test]
        //call this when USB device is disconnected
        public void SLDLL_Open_Scenario_NoUSB()
        {
            Assert.Throws<USBDisconnectedException>(() => CallOpen(testForm.Handle));
        }
    }
}
