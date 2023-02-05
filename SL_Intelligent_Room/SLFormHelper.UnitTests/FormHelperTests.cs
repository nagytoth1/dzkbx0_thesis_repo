using NUnit.Framework;
using System;
using System.Windows.Forms;
using static SLFormHelper.FormHelper;
namespace SLFormHelper.UnitTests
{
    [TestFixture]
    public class FormHelperTests
    {
        Form testForm = new Form();
        [Test]
        public void SLDLL_Open_Scenario_Success()
        {
            //call this when USB device is disconnected
            Assert.That(CallOpen(testForm.Handle) == 0);
        }
        
        [Test]
        public void SLDLL_Open_Scenario_Called()
        {
            //call this when USB device is disconnected
            Assert.Throws<SLDLLException>(() => CallOpen(testForm.Handle), "Az SLDLL_Open függvény már meg lett hívva korábban.");
        }

        [Test]
        public void SLDLL_Felmeres_Scenario_OpenNotCalled()
        {
            Assert.Throws<SLDLLException>(() => CallFelmeres(), "Az SLDLL_Open-függvény a program ezen pontján még nem lett meghívva.");
        }

        [Test]
        public void SLDLL_Felmeres_Scenario_Success()
        {
            CallOpen(testForm.Handle);
            Assert.That(CallFelmeres() == 0);
        }
        [Test]
        public void CallListElem_Scenario_Success_1Device()
        {
            int darabszam = 0;
            Assert.That(CallListelem(ref darabszam) == 1);
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
