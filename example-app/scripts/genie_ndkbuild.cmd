@echo off
@set PATH=C:\AndroidSDK\android-ndk-r10d;%PATH%

cls

..\..\vendor\bx\tools\bin\windows\genie.exe ndkbuild

ndk-build.cmd -C "../../.build/example-app/projects/ndkbuild/jni/"
