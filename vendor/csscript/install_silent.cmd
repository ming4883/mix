echo off
echo **********************************************************************
echo   Ensure you are running the batch file from the CS-Script directory
echo **********************************************************************

rem This batch file allows non GUI installation from command prompt. 
rem The following two lines are example of how to ensure proper working directory (e.g. e:\cs-script)
rem   e:
rem   cd E:\cs-script\
rem 
rem Note: ConfigConsole.exe is the console application implementing in/unstallation routine.
rem       css_config.exe is a GUI launcher for the ConfigConsole.exe

start Lib\ConfigConsole\ConfigConsole.exe /quiet /nogui 