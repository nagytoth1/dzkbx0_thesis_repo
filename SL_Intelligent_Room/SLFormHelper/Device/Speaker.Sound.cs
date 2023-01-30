using System;

namespace SLFormHelper
{
    public partial class Speaker
    {
        private class Sound
        {
            private byte index; //id from frequencies array [0,32]
            private byte volume; //volume [0,63]
            private ushort length; //length in milliseconds [0, 10000] let's say it can't extend to more than 10 seconds

            public Sound(byte index, byte volume, ushort length)
            {
                this.Index = index;
                this.Volume = volume;
                this.Length = length;
            }

            public byte Index
            {
                get => index; 
                set
                {
                    if (value > 49)
                        throw new ArgumentOutOfRangeException("Kérem, 0 és 49 között adja meg a hangmagasságot a hangtáblázat szerint!");
                    index = value;
                }
            }
            public byte Volume
            {
                get => volume;
                set
                {
                    if(value > 63)
                        throw new ArgumentOutOfRangeException("Kérem, 0 és 63 között adja meg a hangerőt!");
                    volume = value;
                }
            }
            public ushort Length { 
                get => length;
                set
                {
                    if (value > 10000)
                        throw new ArgumentOutOfRangeException("A lejátszott hang 10 másodpercnél nem lehet hosszabb.");
                    length = value;
                }
            }

            public override string ToString()
            {
                return string.Format("{0}|{1}|{2}", index, volume, length);
            }
        }
    }
}
