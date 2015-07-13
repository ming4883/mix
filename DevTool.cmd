@echo off
cls
set LASTDIR=%CD%
set css_nuget=.\
cd common/src/devtool/
"../../../vendor/gwencs/CSSCript/cscs.exe" App
cd %LASTDIR%
