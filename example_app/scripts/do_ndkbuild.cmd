@echo off
cls
set PATH=C:\AndroidSDK\android-ndk-r10d;%PATH%
ndk-build.cmd %1 -C "../../.build/example_app/projects/ndkbuild/jni"