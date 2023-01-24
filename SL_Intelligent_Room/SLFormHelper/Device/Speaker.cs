using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SLFormHelper
{
    public class Speaker : Device
    {
        private float volume;

        public Speaker(uint azonos) : this(azonos, .2f) { }
        public Speaker(uint azonos, float volume) : base(azonos)
        {
            this.volume = volume;
        }

        public float Volume
        {
            get { return volume; }
            set { volume = value; }
        }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder("{");
            sb.Append(string.Format("\"type\" : \"N\",\"settings\" : \"{0}|{1}|{2}\"", volume));
            sb.Append("}");
            return sb.ToString();
        }
    }
}
