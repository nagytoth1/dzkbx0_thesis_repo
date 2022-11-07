using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SLFormHelper;

namespace SLHelperTest
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;
            int result;
            result = FormHelper.CallFelmeres();
            Console.WriteLine(result);
            //result = FormHelper.CallOpen();
            Console.WriteLine(result);
            

            FormHelper.FillDevicesList();
            FormHelper.Devices.ForEach(x => Console.WriteLine(x));

            Console.ReadKey();
            //TODO: DLL-be logolás függvény, havonta logolni, hibákat, kivételeket kimenteni, bekérni, melyik függvény adta
        }
    }
}
