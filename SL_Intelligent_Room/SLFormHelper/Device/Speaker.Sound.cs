using System;

namespace SLFormHelper
{
    public partial class Speaker
    {
        private class Sound
        {
            //KONSTANSOK
            private const byte MAX_VOLUME = 63; //63 a legnagyobb hangerő, amit az eszköznek átadhatunk
            private static readonly byte MAX_PITCH = (byte)(Enum.GetNames(typeof(Pitch)).Length - 1); //50 db hang van jelenleg a Pitch enumban, 0-tól 49-ig lehet indexelni
            private const byte MAX_SECONDS = 10; //10 másodperc maximum
            
            //VÁLTOZÓK
            private byte index; //id a frekvenciatáblázatból [0,49]
            private byte volume; //volume [0,63]
            private ushort length; //length in milliseconds [0, 10000]
            
            public Sound(byte index, byte volume, ushort length)
            {
                this.Index = index;
                this.Volume = volume;
                this.Length = length;
            }
            /// <summary>
            /// A hangszóró eszközök által lejátszott hangok hangmagassága
            /// 0 és MAX_PITCH közötti tartományban változhat (alapértelmezetten: 49).
            /// <br></br>---------------------------------------<br></br>
            /// Pitch of sound played by Speaker devices
            /// Ranges from level 0 to MAX_PITCH (default: 49).
            /// </summary>
            public byte Index
            {
                get => index; 
                set
                {
                    if (value > MAX_PITCH)
                        throw new ArgumentOutOfRangeException($"Kérem, 0 és {MAX_PITCH} között adja meg a hangmagasságot a hangtáblázat szerint!");
                    index = value;
                }
            }
            /// <summary>
            /// A hangszóró ilyen erősséggel fogja lejátszani a hangot.
            /// A 0-tól a MAX_VOLUME szintig terjed (alapértelmezett: 63).
            /// <br></br>---------------------------------------<br></br>
            /// Volume of sound played by Speaker devices.
            /// Ranges from level 0 to MAX_VOLUME (default: 63).
            /// </summary>
            public byte Volume
            {
                get => volume;
                set
                {
                    if(value > MAX_VOLUME)
                        throw new ArgumentOutOfRangeException($"Kérem, 0 és {MAX_VOLUME} közötti hangerőt adjon meg!");
                    volume = value;
                }
            }
            /// <summary>
            /// A hang lejátszásának időintervalluma.
            /// Ez 0 és MAX_SECONDS milliszekundum/ezredmásodperc között változik. (alapértelmezetten: 10 000 ms)
            /// <br></br>---------------------------------------<br></br>
            /// Time interval during which sound is played.
            /// It ranges from 0 to MAX_SECONDS millisecs. (default: 10 000 ms)
            /// </summary>
            public ushort Length { 
                get => length;
                set
                {
                    if (value > MAX_SECONDS*1000)
                        throw new ArgumentOutOfRangeException($"A lejátszott hang {MAX_SECONDS} másodpercnél nem lehet hosszabb.");
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
