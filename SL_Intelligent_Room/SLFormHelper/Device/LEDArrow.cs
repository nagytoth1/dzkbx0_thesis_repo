using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;

namespace SLFormHelper
{
    public enum Direction:byte { LEFT, RIGHT, BOTH }
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
            sb.Append(string.Format("\"type\":\"N\",\"settings\":\"{0}|{1}|{2}|{3}\"", color.R, color.G, color.B, (byte)direction));
            sb.Append("}");
            return sb.ToString();
        }

        public override void LoadDeviceSettings(string[] splitSettings)
        {
            if (splitSettings.Length != 4)
                throw new ArgumentException("A nyílhoz nem megfelelő a beállítási lista.");
            if (!Enum.TryParse(splitSettings[3], out Direction parsedDirection))
                throw new Exception("A megadott nyílirány nem létezik!");
            
            this.color = Color.FromArgb(
                red: byte.Parse(splitSettings[0]),
                green: byte.Parse(splitSettings[1]),
                blue: byte.Parse(splitSettings[2]));
            this.direction = parsedDirection;
        }

        public override char GetJSONType()
        {
            return 'N';
        }

        internal override string GetJSONSettings()
        {
            return string.Format("{0}|{1}", base.GetJSONSettings(), (byte) direction); //255|0|0|1
        }
    }
}
