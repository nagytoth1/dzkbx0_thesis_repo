using System;
using System.Runtime.Serialization;

namespace SLFormHelper
{
    public abstract class Device
    {
        
        private uint azonos;
        public uint Azonos { get => azonos;} //readonly!!! - comes from Delphi when Felmeres is called, so it should be forbidden to edit deviceID-s in C#
        //ezek a mezők nem a JSON-ből jönnek, ezek állandóak, minden eszközbe bekerülnek
        public const string PRODUC = "Somodi László"; //mivel const, ezért static is lesz, egy memóriaterületen fognak tárolódni, mert minden eszköz ugyanazt kapja értékül
        public const string MANUFA = "Pluszs Kft.";
        public Device(uint azonos)
        {
            this.azonos = azonos;
        }
    }
}