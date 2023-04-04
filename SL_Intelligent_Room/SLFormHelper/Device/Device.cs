namespace SLFormHelper
{
    public abstract class Device
    {

        private uint azonos;
        public uint Azonos { get => azonos; } //readonly!!! - comes from Delphi when Felmeres is called, so it should be forbidden to edit deviceID-s in C#
        //ezek a mezők nem a JSON-ből jönnek, ezek állandóak, minden eszközbe bekerülnek
        public const string PRODUC = "Somodi László"; //mivel const, ezért static is lesz, egy memóriaterületen fognak tárolódni, mert minden eszköz ugyanazt kapja értékül
        public const string MANUFA = "Pluszs Kft.";
        public Device(uint azonos)
        {
            this.azonos = azonos;
        }
        /// <summary>
        /// Loads device settings from JSON-formatted string, for example: 255|0|0|1.
        /// </summary>
        /// <param name="splitSettings">Settings in an array format. Each type of device requires different type/amount of data.</param>
        public abstract void LoadDeviceSettings(string[] splitSettings);
        public abstract char GetJSONType();
        public abstract string GetJSONSettings();
        
        //inner factory solution
        public static class Factory
        {
            public static Device CreateArrow(uint azonos)
            {
                return new LEDArrow(azonos);
            }
            public static Device CreateLight(uint azonos)
            {
                return new LEDLight(azonos);
            }
            public static Device CreateSpeaker(uint azonos)
            {
                return new Speaker(azonos);
            }
        }
    }
}