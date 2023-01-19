using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SLFormHelper
{
    public class USBDisconnectedException : Exception
    {
        public USBDisconnectedException(string message) : base(message) { }
    }
}
