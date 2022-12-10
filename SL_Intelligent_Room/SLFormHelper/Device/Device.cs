﻿using System;
using System.Runtime.Serialization;

namespace SLFormHelper
{
    public abstract class Device
    {
        //nem a JSON-ből jönnek, ezek állandóak, minden eszközbe bekerülnek
        private const string PRODUC = "Somodi László"; //mivel const, ezért static is lesz, egy memóriaterületen fognak tárolódni, mert minden eszköz ugyanazt kapja értékül
        private const string MANUFA = "Pluszs Kft.";

        private uint azonos;

        public uint Azonos { get => azonos; set => azonos = value; }

        public Device(uint azonos)
        {
            this.azonos = azonos;
        }

        public override string ToString()
        {
            return string.Format($"({this.GetType().Name};{Azonos};{PRODUC};{MANUFA})");
        }
    }
}