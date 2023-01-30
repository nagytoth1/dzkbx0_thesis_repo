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
        public uint Azonos { get => azonos; set => azonos = value; }

        public Device CreateDevice() //refactoring: should be an abstract factory
        {
            switch (azonos & 0xc000)
            {
                case SLLELO:
                    return new LEDLight(azonos);
                case SLNELO:
                    return new LEDArrow(azonos);
                case SLHELO:
                    return new Speaker(azonos);
                default:
                    return null;
            }
        }
    }
}
