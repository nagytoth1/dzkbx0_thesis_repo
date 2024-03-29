﻿using System;
using System.Drawing;

namespace SLFormHelper
{
    public enum Direction:byte { LEFT, RIGHT, BOTH }
    public class LEDArrow : LEDLight
    {
        private Direction direction;

        public LEDArrow(ushort azonos) : this(azonos, Color.Black, Direction.BOTH) { }
        public LEDArrow(ushort azonos, Color c, Direction direction) : base(azonos, c)
        {
            this.direction = direction;
        }

        public Direction Direction { get => direction; set => direction = value; }
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

        public override string GetJSONSettings()
        {
            return string.Format("{0}|{1}", base.GetJSONSettings(), (byte) direction); //255|0|0|1
        }

        public override Device Clone()
        {
            return new LEDArrow(this.azonos, this.color, this.direction);
        }
    }
}
