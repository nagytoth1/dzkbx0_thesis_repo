using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;

namespace SLFormHelper
{
    public enum Direction:byte { LEFT=0, RIGHT=1, BOTH=2 }
    public class LEDArrow : LEDLight
    {
        private Direction direction;

        public LEDArrow(uint azonos) : this(azonos, Color.Red, Direction.LEFT) { }
        public LEDArrow(uint azonos, Direction irany) : this(azonos, Color.Red, irany) { }
        public LEDArrow(uint azonos, Color c, Direction direction) : base(azonos)
        {
            this.color = c;
            this.direction = direction;
        }

        public Direction Direction { get => direction; set => direction = value; }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder("{");
            sb.Append(string.Format("\"type\" : \"N\",\"settings\" : \"{0}|{1}|{2}|{3}\"", color.R, color.G, color.B, (byte)direction));
            sb.Append("}");
            return sb.ToString();
        }
    }
}
