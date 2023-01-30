using System;
using System.Collections.Generic;
using System.Text;

namespace SLFormHelper
{
    public partial class Speaker : Device
    {
        private readonly List<Sound> soundList;
        public Speaker(uint azonos) : base(azonos) {
            this.soundList = new List<Sound>();
        }
        public void AddSound(Pitch pitch, byte volume, ushort length)
        {
            if (soundList.Count > 30)
                throw new Exception("A lejátszható hangok listája megtelt.");
            Sound soundToAdd;
            try
            {
                soundToAdd = new Sound((byte)pitch, volume, length);
                this.soundList.Add(soundToAdd);
            }
            catch(ArgumentOutOfRangeException) {
                Console.WriteLine("Nem adom hozzá a hanglistához.");
            }
        }
        public override string ToString()
        {
            StringBuilder sb = new StringBuilder('{');
            sb.Append(string.Format("\"type\":\"H\",\"settings\":\""));
            if(soundList.Count == 0)
                return sb.Append("\"}").ToString();
            int i;
            for (i = 0; i < soundList.Count - 1; i++)
            {
                sb.Append(soundList[i].ToString()).Append('|');
            }
            sb.Append(soundList[i].ToString())
                .Append("\"}");
            return sb.ToString();
        }

        public void ClearSounds()
        {
            soundList.Clear();
        }
    }
}
