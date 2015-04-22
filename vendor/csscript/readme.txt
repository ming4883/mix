C# Script execution engine;
-----------------------------------------------------------------------------------------
The MIT License (MIT)
Copyright (c) 2014 Oleg Shilo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

-----------------------------------------------------------------------------------------
Contact: 
 csscript.support@gmail.com
-----------------------------------------------------------------------------------------
Installation:

 Precondition: .NET runtime must be installed. You can download it from here or from other well known locations:
	http://www.microsoft.com/download/en/details.aspx?id=17851
	Despite the fact that you can select earlier versions of .NET as a target .NET Framework version 4.5 is 
        required for CS-Script to function properly.

 To install:
   1. extract content of the cs-script.zip on your HD
   2. run css_config.exe or install.cmd (it will bring the configuration console)
   3. adjust the CS-Script settings in the configuration console according your needs (e.g. enabled debuggers, shell extensions...)
   
 To uininstall:
   1. run css_config.exe
   2. press 'Deactivate' button on the 'General' tab in the configuration console
   OR
   1. run unistall.cmd
 
 To upgrade:
   No special steps are required. Just do as for normal installation according instructions above.
   
NOTE: 
   - After running css_config.exe from some third-party file navigation utilities (e.g. Total Commander)
   it might be required to restart this utility in order for changes to take effect.
   
-----------------------------------------------------------------------------------------
Installing on "Windows 7 family" OS

If during the installation you have "System.IO.FileNotFoundException: Could not load file or assembly 
'CSScriptLibrary" error this can be due to the new Win& security measures. You may want to "Unblock" all CS-Script 
files you downloaded. This can be done either manually or with Sysinternals Streams.exe utility:  
http://www.rogoff.uk.com/blog/post/How-to-bulk-unblock-files-in-Windows-7-or-Server-2008.aspx

-----------------------------------------------------------------------------------------
Running:
 Script engine can be run in two different modes:
 as a console application (cscs.exe) and as a WinExe application (csws.exe).
 
C# Script execution engine. Version 3.8.13.0.
Copyright (C) 2004-2014 Oleg Shilo.

Usage: cscs.exe <switch 1> <switch 2> <file> [params] [//x]

<switch 1>
 /?    - Display help info.
 /e    - Compile script into console application executable.
 /ew   - Compile script into Windows application executable.
 /c    - Use compiled file (cache file .compiled) if found (to improve performance).
 /ca   - Compile script file into assembly (cache file .compiled) without execution.
 /cd   - Compile script file into assembly (.dll) without execution.

 /co:<options>
       - Pass compiler options directly to the language compiler
       (e.g.  /co:/d:TRACE pass /d:TRACE option to C# compiler
        or  /co:/platform:x86 to produce Win32 executable)

 /s    - Print content of sample script file (e.g. cscs.exe /s > sample.cs).
 /ac | /autoclass
       - Automatically generates wrapper class if the script does not define any class of its own:

         using System;
                      
         void Main()
         {
             Console.WriteLine("Hello World!");
         }


<switch 2>
 /nl   - No logo mode: No banner will be shown/printed at execution time.
 /dbg | /d
         - Force compiler to include debug information.
 /l    - 'local'(makes the script directory a 'current directory')
 /v    - Prints CS-Script version information
 /verbose 
       - prints runtime information during the script execution (applicable for console clients only)
 /noconfig[:<file>]
       - Do not use default CS-Script config file or use alternative one.
         Value "out" of the <file> is reserved for creating the config file (css_config.xml) with the default settings.
         (e.g. cscs.exe /noconfig sample.cs
         cscs.exe /noconfig:c:\cs-script\css_VB.dat sample.vb)
 /sconfig[:<file>]
       - Use script config file or custom config file as a .NET application configuration file.
  This option might be useful for running scripts, which usually cannot be executed without configuration file (e.g. WCF, Remoting).

          (e.g. if /sconfig is used the expected config file name is <script_name>.cs.config or <script_name>.exe.config
           if /sconfig:myApp.config is used the expected config file name is myApp.config)
 /r:<assembly 1>:<assembly N>
       - Use explicitly referenced assembly. It is required only for
         rare cases when namespace cannot be resolved into assembly.
         (e.g. cscs.exe /r:myLib.dll myScript.cs).
 /dir:<directory 1>,<directory N>
       - Add path(s) to the assembly probing directory list.
         (e.g. cscs.exe /dir:C:\MyLibraries myScript.cs).
 /co:<options>
       -  Passes compiler options directy to the language compiler.
         (e.g. /co:/d:TRACE pass /d:TRACE option to C# compiler).
 /precompiler[:<file 1>,<file N>]
       - specifies custom precompiler file(s). This can be either script or assembly file.
         If no file(s) specified prints the code template for the custom precompiler.
         There is a special reserved word 'nodefault' to be used as a file name.
         It instructs script engine to prevent loading any built-in precompilers 
         like the one for removing shebang
         before the execution.
         (see Precompilers chapter in the documentation)

file   - Specifies name of a script file to be run.
params - Specifies optional parameters for a script file to be run.
 //x   - Launch debugger just before starting the script.


**************************************
Script specific syntax
**************************************

Engine directives:
------------------------------------
//css_import <file>[, preserve_main][, rename_namespace(<oldName>, <newName>)];

Alias - //css_imp
There are also another two aliases //css_include and //css_inc. They are equivalents of //css_import <file>, preserve_main
If $this (or $this.name) is specified as part of <file> it will be replaced at execution time with the main script full name (or file name only).

file            - name of a script file to be imported at compile-time.
<preserve_main> - do not rename 'static Main'
oldName         - name of a namespace to be renamed during importing
newName         - new name of a namespace to be renamed during importing

This directive is used to inject one script into another at compile time. Thus code from one script can be exercised in another one.
'Rename' clause can appear in the directive multiple times.
------------------------------------
//css_nuget [-noref] package0[,package1]..[,packageN];

Downloads/Installs the NuGet package. It also automatically references the downloaded package assemblies.
If automatic referencing isn't desired use '-noref' switch.
Note : package is not downloaded again if it was already downloaded.
 Example: //css_nuget cs-script;
 This directive will install CS-Script NuGet package.
------------------------------------
//css_args arg0[,arg1]..[,argN];

Embedded script arguments. The both script and engine arguments are allowed except "/noconfig" engine command switch.
 Example: //css_args /dbg;
 This directive will always force script engine to execute the script in debug mode.
------------------------------------
//css_reference <file>;

Alias - //css_ref

file	- name of the assembly file to be loaded at run-time.

This directive is used to reference assemblies required at run time.
The assembly must be in GAC, the same folder with the script file or in the 'Script Library' folders (see 'CS-Script settings').
------------------------------------
//css_precompiler <file 1>,<file 2>;

Alias - //css_pc

file	- name of the script or assembly file implementing precompiler.

This directive is used to specify the CS-Script precompilers to be loaded and exercised against script at run time.
------------------------------------
//css_searchdir <directory>;

Alias - //css_dir

directory - name of the directory to be used for script and assembly probing at run-time.

This directive is used to extend set of search directories (script and assembly probing).
The directory name can be a wild card based expression.In such a case all directories matching the pattern will be this 
case all directories will be probed.
The special case when the path ends with '**' is reserved to indicate 'sub directories' case. Examples:
    //css_dir packages\ServiceStack*.1.0.21\lib\net40
    //css_dir packages\**
------------------------------------
//css_resource <file>;

Alias - //css_res

file	- name of the resource file (.resources) to be used with the script.

This directive is used to reference resource file for script.
 Example: //css_res Scripting.Form1.resources;
------------------------------------
//css_co <options>;

options - options string.

This directive is used to pass compiler options string directly to the language specific CLR compiler.
 Example: //css_co /d:TRACE pass /d:TRACE option to C# compiler
          //css_co /platform:x86 to produce Win32 executable

------------------------------------
//css_ignore_namespace <namespace>;

Alias - //css_ignore_ns

namespace	- name of the namespace.

This directive is used to prevent CS-Script from resolving the referenced namespace into assembly.
------------------------------------
//css_prescript file([arg0][,arg1]..[,argN])[ignore];
//css_postscript file([arg0][,arg1]..[,argN])[ignore];

Aliases - //css_pre and //css_post

file    - script file (extension is optional)
arg0..N - script string arguments
ignore  - continue execution of the main script in case of error

These directives are used to execute secondary pre- and post-action scripts.
If $this (or $this.name) is specified as arg0..N it will be replaced at execution time with the main script full name (or file name only).
------------------------------------
//css_host [/version:<CLR_Version>] [/platform:<CPU>]

CLR_Version - version of CLR the script should be execute on (e.g. //css_host /version:v3.5)
CPU - indicates which platforms the script should be run on: x86, Itanium, x64, or anycpu.
Sample: //css_host /version:v2.0 /platform:x86;
These directive is used to execute script from a surrogate host process. The script engine application (cscs.exe or csws.exe) launches the script
execution as a separate process of the specified CLR version and CPU architecture.
------------------------------------

Any directive has to be written as a single line in order to have no impact on compiling by CLI compliant compiler.
It also must be placed before any namespace or class declaration.

------------------------------------
Example:

 using System;
 //css_prescript com(WScript.Shell, swshell.dll);
 //css_import tick, rename_namespace(CSScript, TickScript);
 //css_reference teechart.lite.dll;
 
 namespace CSScript
 {
   class TickImporter
   {
      static public void Main(string[] args)
      {
         TickScript.Ticker.i_Main(args);
      }
   }
 }


