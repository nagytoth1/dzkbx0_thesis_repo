using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SLFormHelper
{
    enum Pitch
    {
        C, E, EOktav //TODO: ...
    }
    public class Speaker : Device
    {
        private byte volume; //volume [0,63]
        private byte index; //id from frequencies array [0,32]
        private ushort length; //length in milliseconds [0, 10000] let's say it can't extend to more than 10 seconds

        public Speaker(uint azonos) : this(azonos, 10, 20, 1000) { }

        public Speaker(uint azonos, byte volume, byte index, ushort length):base(azonos)
        {
            this.volume = volume;
            this.index = index;
            this.length = length;
        }

        public byte Volume { get => volume; set => volume = value; }
        public byte Index { get => index; set => index = value; }
        public ushort Length { get => length; set => length = value; }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder('{');
            sb.Append(string.Format("\"type\":\"H\",\"settings\":\"{0}|{1}|{2}\"", index, volume, length));
            sb.Append('}');
            //{"type":"H","settings":"10|10|1000"}
            return sb.ToString();
        }
    }
}
