using System;
using System.Runtime.Serialization;

namespace SLFormHelper
{
    [Serializable]
    internal class Dev485Exception : Exception
    {
        public Dev485Exception(string message) : base(message) { }
    }
}