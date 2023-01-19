using System;
using System.Runtime.Serialization;

namespace SLFormHelper
{
    [Serializable]
    public class Dev485Exception : Exception
    {
        public Dev485Exception(string message) : base(message) { }
    }
}