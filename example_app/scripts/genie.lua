local MIX_COMMON_DIR = path.getabsolute ("../../common")
local PROJECT_DIR = path.getabsolute ("../")

solution "example_app"
	dofile (path.join (MIX_COMMON_DIR, "scripts/setup.lua"))
	
	if _ACTION == "gradle" then

		premake.gradle.appabi = {"armeabi", "armeabi-v7a", "x86"}
		
		premake.gradle.ndk.ld_gold.enable = true
		
		premake.gradle.ndk.ld_gold.multithread = true
		
		premake.gradle.manifest = path.join (PROJECT_DIR, "android/AndroidManifest.xml")
		
		premake.gradle.java_srcdirs = {
			path.join (MIX_COMMON_DIR, "android/java"),
			path.join (PROJECT_DIR, "android/java")
		}
		
		premake.gradle.res_srcdirs = {
			path.join (PROJECT_DIR, "android/res")
		}
		
		premake.gradle.buildscript.repositories = {
			--"maven { url 'https://maven.fabric.io/public' }"
		}
		
		premake.gradle.buildscript.dependencies = {
			--"classpath 'io.fabric.tools:gradle:1.+'"
		}
		
		premake.gradle.plugins = {
			-- "io.fabric"
		}
		
		premake.gradle.dependencies = {
			"compile 'com.google.android.gms:play-services-games:7.3.0'"
		}
		
		premake.gradle.externalprojects["dummy"] = path.join (PROJECT_DIR, "android/dummy")
		
		premake.gradle.buildTypes.release.minifyEnabled = true
		premake.gradle.buildTypes.release.proguardFiles = {
			"getDefaultProguardFile('proguard-android.txt')"
		}
		
		premake.gradle.multiDexEnabled = true
	end
	
	project ("example_app")
		mix_setup_app ()
	
		files {
			path.join (PROJECT_DIR, "src/app.cpp"),
			path.join (MIX_COMMON_DIR, "src/mix_entry/mix_entry.cpp")
		}
		
		if mix_is_android() then
			files {
				path.join (MIX_COMMON_DIR, "src/mix_entry/mix_entry_android.cpp")
			}
		end
		
		if mix_is_ios() then
			files {
				path.join (MIX_COMMON_DIR, "src/mix_entry/mix_entry_ios.mm"),
				path.join (PROJECT_DIR, "ios/info.plist"),
				path.join (PROJECT_DIR, "ios/LaunchScreen.xib"),
			}
		end
		
		includedirs {
			path.join (MIX_COMMON_DIR, "include/")
		}
		
		links {
			"bgfx-static",
		}
		
	startproject ("example_app")
		
	--defines ({"TEST_COMMON=1", "TEST_APP=1"})