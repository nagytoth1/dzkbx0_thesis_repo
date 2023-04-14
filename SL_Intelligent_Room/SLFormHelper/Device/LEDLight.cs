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
        /// <summary>
        /// Ilyen színnel fog világítani az eszköz.
        /// <br></br>---------------------------------------<br></br>
        /// This is the colour the device will light up in.
        /// </summary>
        protected Color color;
        /// <summary>
        /// A lámpa egyparaméteres konstruktora, ennek elegendő az azonosítót átadni, alapértelmezetten fekete színre állítja be az eszközt, amely számára a kikapcsolt állapotot jelzi.
        /// <br></br>---------------------------------------<br></br>
        /// The one-parameter constructor of LEDLight, which only needs to be passed the identifier, defaults the device to black, indicating the off state.
        /// </summary>
        /// <param name="azonos">Az eszköz azonosítója (relayDLL-en keresztül kerül átadásra)</param>
        public LEDLight(uint azonos)
            : this(azonos, Color.Black) { } //legyen kikapcsolva alapjáraton - fekete színt küldünk ki a lámpának
        /// <summary>
        /// A lámpa eszköz konstruktora, az eszköz azonosítóját, és a beállítani kívánt színt kéri.
        /// <br></br>---------------------------------------<br></br>
        /// The constructor of LEDLight, asks for the device identifier and the colour to set.
        /// </summary>
        /// <param name="azonos">Eszköz azonosítója (relayDLL-en keresztül kerül átadásra)</param>
        /// <param name="c">A beállítani kívánt szín.</param>
        public LEDLight(uint azonos, Color c) : base(azonos)
        {
            this.color = c;
        }

        public Color Color {
            get { return color; }
            set { color = value; }
        }

        public override void LoadDeviceSettings(string[] splitSettings)
        {
            if (splitSettings.Length != 3)
                throw new ArgumentException("A lámpához nem megfelelő a beállítási lista.");
            
            this.color = Color.FromArgb(
                red: byte.Parse(splitSettings[0]),
                green: byte.Parse(splitSettings[1]),
                blue: byte.Parse(splitSettings[2]));
        }

        public override char GetJSONType()
        {
            return 'L';
        }
        public override string GetJSONSettings()
        {
            return string.Format($"{color.R}|{color.G}|{color.B}"); //255|0|0
        }

        public override Device Clone()
        {
            return new LEDLight(this.azonos, this.color);
        }
    }
}
