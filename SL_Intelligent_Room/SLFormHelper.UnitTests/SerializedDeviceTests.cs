using NUnit.Framework;
namespace SLFormHelper.UnitTests
{
    [TestFixture]
    public class SerializedDeviceTests
    {
        SerializedDevice target;
        [Test]
        public void CreateDevice_Scenario_Speaker()
        {
            target = new SerializedDevice();
            target.Azonos = 49156; //speaker típusú azonosítót adok neki

            Device d = target.CreateDevice();

            Assert.IsInstanceOf(typeof(Speaker), d);
        }

        [Test]
        public void CreateDevice_Scenario_LEDArrow()
        {
            target = new SerializedDevice();
            target.Azonos = 32772;

            Device d = target.CreateDevice();

            Assert.IsInstanceOf(typeof(LEDArrow), d);
        }
        [Test]
        public void CreateDevice_Scenario_LEDLight()
        {
            target = new SerializedDevice();
            target.Azonos = 16388;

            Device d = target.CreateDevice();

            Assert.IsInstanceOf(typeof(LEDLight), d);
        }

        [Test]
        public void CreateDevice_Scenario_None()
        {
            target = new SerializedDevice();
            target.Azonos = 0;

            Device d = target.CreateDevice();

            Assert.That(d == null);
        }
    }
}
