local MIX_COMMON_DIR = path.getabsolute ("../../common")
local PROJECT_DIR = path.getabsolute ("../")

solution "example_app"
	dofile (path.join (MIX_COMMON_DIR, "scripts/setup.lua"))
	
	
	if mix_is_android() then
		premake.gradle.appabi = {"armeabi", "armeabi-v7a", "x86"}
		
		premake.gradle.buildscript.repositories = {
			--"maven { url 'https://maven.fabric.io/public' }"
		}
		
		premake.gradle.buildscript.dependencies = {
			--"classpath 'io.fabric.tools:gradle:1.+'"
		}
		
		premake.gradle.ndk.ld_gold.enable = true
		premake.gradle.ndk.ld_gold.multithread = true
		
	end
	
	project ("example_app")
		mix_setup_common_app ()
		
		files {
			path.join (PROJECT_DIR, "src/*.cpp"),
		}
			
		if mix_is_ios() then
			files {
				path.join (PROJECT_DIR, "ios/info.plist"),
				path.join (PROJECT_DIR, "ios/LaunchScreen.xib"),
			}
		end
		
		if mix_is_android() then
			local grd = gradle()
			grd.appabi = {"armeabi", "armeabi-v7a", "x86"}
			
			grd.manifest = path.join (PROJECT_DIR, "android/AndroidManifest.xml")
			
			grd.java_srcdirs = {
				path.join (MIX_COMMON_DIR, "android/app/java"),
				path.join (PROJECT_DIR, "android/java")
			}
			
			grd.res_srcdirs = {
				path.join (PROJECT_DIR, "android/res")
			}
			
			grd.plugins = {
				-- "io.fabric"
			}
			
			grd.dependencies = {
				"compile 'com.google.android.gms:play-services-games:7.3.0'"
			}
			
			grd.externalprojects["dummy"] = path.join (PROJECT_DIR, "android/dummy")
			
			grd.buildTypes.release.minifyEnabled = true
			grd.buildTypes.release.proguardFiles = {
				"getDefaultProguardFile('proguard-android.txt')"
			}
			
			grd.multiDexEnabled = true
		end
	
	mix_common_tests_project()
	
	startproject ("example_app")
	
	--defines ({"TEST_COMMON=1", "TEST_APP=1"})