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
        private const ushort SLLELO = 0x_4000;
        private const ushort SLNELO = 0x_8000;
        private const ushort SLHELO = 0x_c000;

        private ushort azonos;
        public SerializedDevice(ushort azonos) { this.azonos = azonos; }
        public ushort Azonos { get => azonos; set => azonos = value; }

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
