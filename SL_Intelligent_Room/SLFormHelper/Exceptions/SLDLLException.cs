using System;
using System.Runtime.Serialization;

namespace SLFormHelper
{
    [Serializable]
    internal class SLDLLException : Exception
    {
        public SLDLLException(string message) : base(message) { }
    }
}