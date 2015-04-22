//css_args /ac
//css_ref %csscript_dir%\Lib\CSScriptLibrary.dll;
using System;
using System.Linq;
using System.IO;
using CSScriptLibrary;

void main()
{
    string cacheRootDir = Path.Combine(CSScript.GetScriptTempDir(), "cache");
    foreach (var cacheDir in Directory.GetDirectories(cacheRootDir))
    {
        string sourceDir = File.ReadAllLines(Path.Combine(cacheDir, "css_info.txt")).Last();
        string cachName = Path.GetFileName(cacheDir);
        
        Console.WriteLine(cachName + ":\t" + sourceDir);
    }
}