using NUnit.Framework;
namespace SLFormHelper.UnitTests
{
    [TestFixture]
    public class SerializedDeviceTests
    {
        SerializedDevice target = new SerializedDevice();
        [Test]
        public void CreateDevice_Scenario_Speaker()
        {
            target.Azonos = 0xc004; //speaker típusú azonosítót adok neki

            Device d = target.CreateDevice();

            Assert.IsInstanceOf(typeof(Speaker), d);
        }

        [Test]
        public void CreateDevice_Scenario_LEDArrow()
        {
            target.Azonos = 0x8004; 

            Device d = target.CreateDevice();

            Assert.IsInstanceOf(typeof(LEDArrow), d);
        }
        [Test]
        public void CreateDevice_Scenario_LEDLight()
        {
            target.Azonos = 0x4004;

            Device d = target.CreateDevice();

            Assert.IsInstanceOf(typeof(LEDLight), d);
        }

        [Test]
        public void CreateDevice_Scenario_None()
        {
            target.Azonos = 0;

            Device d = target.CreateDevice();

            Assert.That(d == null);
        }
        [Test]
        public void CreateDevice_Scenario_Speaker_max()
        {
            target.Azonos = 0xcfff;

            Device d = target.CreateDevice();

            Assert.IsInstanceOf<Speaker>(d);
        }
        public void CreateDevice_Scenario_LEDArrow_max()
        {
            target.Azonos = 0x8fff;

            Device d = target.CreateDevice();

            Assert.IsInstanceOf<LEDArrow>(d);
        }
        public void CreateDevice_Scenario_LEDLight_max()
        {
            target.Azonos = 0x4fff;

            Device d = target.CreateDevice();

            Assert.IsInstanceOf<LEDLight>(d);
        }
        
        public void CreateDevice_Scenario_None_max()
        {
            target.Azonos = 0xd000;

            Device d = target.CreateDevice();

            Assert.IsNull(d);
        }
    }
}
