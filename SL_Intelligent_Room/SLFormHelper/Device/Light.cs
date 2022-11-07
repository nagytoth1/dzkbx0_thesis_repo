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
        protected Color color;

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
            return string.Format("{0} RGB({1}, {2}, {3})", base.ToString(), color.R, color.G, color.B);
        }
    }
}
