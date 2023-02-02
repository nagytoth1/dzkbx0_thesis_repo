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
            catch(ArgumentOutOfRangeException ex) {
                Console.WriteLine($"Nem adom hozzá a hanglistához a következő miatt: {ex.Message}.");
            }
        }
        public void ClearSounds()
        {
            soundList.Clear();
        }
        public override string ToString()
        {
            StringBuilder sb = new StringBuilder('{');
            sb.Append(string.Format("\"type\":\"H\",\"settings\":\""));
            if (soundList.Count == 0)
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
        public override void LoadDeviceSettings(string[] splitSettings)
        {
            if (splitSettings.Length % 3 != 0)
                throw new ArgumentException("A hangszóróhoz nem megfelelő a beállítási lista.");
            for (int i = 0; i < soundList.Count - 2; i += 3)
            {
                if (!Enum.TryParse(splitSettings[i], out Pitch parsedPitch))
                    throw new Exception("A megadott hangmagasság nem létezik.");
                
                AddSound(pitch: parsedPitch,
                        volume: byte.Parse(splitSettings[i + 1]),
                        length: ushort.Parse(splitSettings[i + 2]));
            }
        }
        public override char GetJSONType()
        {
            return 'H';
        }
        internal override string GetJSONSettings()
        {
            StringBuilder sb = new StringBuilder();
            if (soundList.Count == 0) 
                return "";
            int i;
            for (i = 0; i < soundList.Count - 1; i++)
            {
                sb.Append(soundList[i].ToString()).Append('|'); //index|volume|length
            }
            sb.Append(soundList[i].ToString());
            return sb.ToString();
        }
    }
}
