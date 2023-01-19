using NUnit.Framework;
using System;
using System.Windows.Forms;
using SLFormHelper;

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
            Assert.That(FormHelper.CallOpen(testForm.Handle) == 0);
        }
        [Test]
        public void SLDLL_Open_Scenario_Called()
        {
            //call this when USB device is disconnected
            Assert.Throws<SLDLLException>(() => FormHelper.CallOpen(testForm.Handle));
        }
        [Test]
        public void SLDLL_Felmeres_Scenario_OpenNotCalled()
        {
            Assert.Throws<SLDLLException>(() => FormHelper.CallFelmeres());
        }

        [Test]
        public void SLDLL_Felmeres_Scenario_Success()
        {
            FormHelper.CallOpen(testForm.Handle);
            Assert.That(FormHelper.CallFelmeres() == 0);
        }
        [Test]
        public void CallListElem_Scenario_Success()
        {
            Assert.That(FormHelper.CallListelem() == 0);
        }

        //call this when HelperForm.DLLPATH is set wrong
        //[Test]
        //public void SLDLL_Open_Scenario_NoDLL()
        //{
        //    Assert.Throws<DllNotFoundException>(() => FormHelper.CallOpen(testForm.Handle));
        //}
        //[Test]
        //call this when USB device is disconnected
        //public void SLDLL_Open_Scenario_NoUSB()
        //{
        //    Assert.Throws<USBDisconnectedException>(() => FormHelper.CallOpen(testForm.Handle));
        //}
    }
}
