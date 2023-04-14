using NUnit.Framework;
using SLHelperTestForm;
using System;
using static SLFormHelper.FormHelper;

namespace SLFormHelper.UnitTests
{
    /// <summary>
    /// Run these tests when SL Devices are connected
    /// </summary>
    [TestFixture]
    public class FormHelperConnectedTests
    {
        private HelperForm testForm = new HelperForm();

        [Test]
        public void CallListElem_Scenario_Success_NDeviceConnected()
        {
            byte expected = 1;
            testForm.Show();
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
            Assert.DoesNotThrow(() => CallFelmeres());
        }

        //call this when HelperForm.DLLPATH is set wrong
        [Test]
        public void SLDLL_Open_Scenario_NoDLL()
        {
            Assert.Throws<DllNotFoundException>(() => CallOpen(testForm.Handle));
        }
    }
}
