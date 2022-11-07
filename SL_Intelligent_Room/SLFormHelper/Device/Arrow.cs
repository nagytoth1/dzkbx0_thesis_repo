using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;

namespace SLFormHelper
{
    public enum Direction { LEFT, RIGHT, BOTH }
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
            return string.Format("{0} {1} direction", base.ToString(), direction);
        }
    }
}
