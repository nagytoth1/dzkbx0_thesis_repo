using System;
using System.Runtime.Serialization;

namespace SLFormHelper
{
    [Serializable]
    public class SLDLLException : Exception
    {
        public SLDLLException(string message) : base(message) { }
    }
}