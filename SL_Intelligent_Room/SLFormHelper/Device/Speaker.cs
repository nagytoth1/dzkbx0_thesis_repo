using System;
using System.Collections.Generic;
using System.Text;

namespace SLFormHelper
{
    public partial class Speaker : Device
    {
        private const byte SOUNDLIST_MAX = 30; //hanglista hossza maximum
        private readonly List<Sound> soundList; //readonly = nem engedi átírni a memóriacímet
        public Speaker(uint azonos) : base(azonos) {
            this.soundList = new List<Sound>();
        }
        /// <summary>
        /// Listakezelő metódus, hozzáad egy hangot a lejátszandó hangok listájához.
        /// <br></br>---------------------------------------<br></br>
        /// List handler method, it adds a single sound-element to the list of sounds to be played.
        /// </summary>
        /// <param name="pitch">Hangmagasság</param>
        /// <param name="volume">Hangerő</param>
        /// <param name="length">Adott hang lejátszásának időtartama (hanghossz).</param>
        public void AddSound(Pitch pitch, byte volume, ushort length)
        {
            if (soundList.Count == SOUNDLIST_MAX)
                throw new Exception("A lejátszható hangok listája megtelt. Maximum 30 db hang játszható le összesen.");
            try
            {
                Sound soundToAdd = new Sound((byte)pitch, volume, length);
                this.soundList.Add(soundToAdd);
            }
            catch(ArgumentOutOfRangeException ex) {
                Console.WriteLine($"Nem adom hozzá a hanglistához a következő miatt: {ex.Message}.");
            }
        }
        /// <summary>
        /// Kiüríti a lejátszható hangok listáját.
        /// <br></br>---------------------------------------<br></br>
        /// It makes the soundList empty.
        /// </summary>
        public void ClearSounds()
        {
            soundList.Clear();
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
                //üres beállítások - ha üres lenne a string, akkor a relayDLL küldhet olyan üzenetet,
                //hogy "eszközbeállítások üresek vagy nem megfelelő formátumúak"
                //ha üres a lista, lényegében olyan, mintha üres jelet küldenénk ki neki
                return "0|0|0"; 
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
