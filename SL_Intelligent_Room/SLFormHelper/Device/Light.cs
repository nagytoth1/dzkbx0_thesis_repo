using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SLFormHelper
{
    public class LEDLight:Device
    {
        protected Color color; //rgb - milyen színnel világítson

        public LEDLight(uint azonos)
            : this(azonos, Color.Red) { }
        public LEDLight(uint azonos, Color c) : base(azonos)
        {
            this.color = c;
        }

        public Color Color {
            get { return color; }
            set { color = value; }
        }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder("{");
            sb.Append(string.Format("\"type\" : \"L\",\"settings\" : \"{0}|{1}|{2}\"", color.R, color.G, color.B));
            sb.Append("}");
            return sb.ToString();
        }
    }
}
