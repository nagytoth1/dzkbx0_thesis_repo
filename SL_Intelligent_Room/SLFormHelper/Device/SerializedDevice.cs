using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SLFormHelper
{
    [Serializable]
    public class SerializedDevice
    {
        private const int SLLELO = 0x4000;
        private const int SLNELO = 0x8000;
        private const int SLHELO = 0xc000;

        private uint azonos;

        public SerializedDevice(uint devID) { this.azonos = devID; }
        public SerializedDevice() { }
        public uint Azonos { get => azonos; set => azonos = value; }

        public Device CreateDevice() //refactoring: should be an abstract factory
        {
            switch (azonos & 0xc000)
            {
                case SLLELO:
                    return Device.Factory.CreateLight(azonos);
                case SLNELO:
                    return Device.Factory.CreateArrow(azonos);
                case SLHELO:
                    return Device.Factory.CreateSpeaker(azonos);
                default:
                    return null;
            }
        }
    }
}
