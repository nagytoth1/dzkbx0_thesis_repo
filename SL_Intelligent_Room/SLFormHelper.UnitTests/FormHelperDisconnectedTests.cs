using NUnit.Framework;
using SLHelperTestForm;
using System;
using System.Threading;
using System.Windows.Forms;
using static SLFormHelper.FormHelper;
namespace SLFormHelper.UnitTests
{
    /// <summary>
    /// Run these tests when no device is connected to the USB port.
    /// </summary>
    [TestFixture]
    public class FormHelperDisconnectedTests
    {
        readonly HelperForm testForm =  new HelperForm();
        [Test]
        public void SLDLL_Felmeres_Scenario_OpenNotCalled()
        {
            Assert.Throws<SLDLLException>(() => CallFelmeres(), "Az SLDLL_Open-függvény a program ezen pontján még nem lett meghívva.");
        }

        [Test]
        public void SLDLL_Open_Scenario_NotCalled()
        {
            testForm.Show();
            Assert.Throws<USBDisconnectedException>(() => CallOpen(testForm.Handle));
        }

        [Test]
        public void CallFillDev485Static_FillNotCalled()
        {
            bool actual = false;
            CallFillDev485Static();
            if ((Devices[0] is Speaker) &&
               (Devices[1] is LEDArrow) &&
               (Devices[2] is LEDLight))
               actual = true;
            Assert.IsTrue(actual);
        }
        [Test]
        public void CallFillDev485Static_FillCalled()
        {
            CallFillDev485Static();
            Assert.Throws<Dev485Exception>(()=> CallFillDev485Static(), "Az eszközök tömbje már fel lett töltve!");
        }


    }
}
