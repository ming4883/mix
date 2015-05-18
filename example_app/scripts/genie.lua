local MIX_COMMON_DIR = path.getabsolute ("../../common")
local PROJECT_DIR = path.getabsolute ("../")

solution "example_app"
	dofile (path.join (MIX_COMMON_DIR, "scripts/setup.lua"))
	
	mix_project_app "example_app"
		files {
			path.join (PROJECT_DIR, "src/entry.cpp")
		}
		links {
			"bgfx-static",
		}
	
	if _ACTION == "gradle" then

		premake.gradle.appabi = {"armeabi", "armeabi-v7a", "x86"}
		
		premake.gradle.ndk.appabiextra.add ("armeabi", "Release", {
			"LOCAL_ARM_MODE := arm",
		})
		premake.gradle.ndk.appabiextra.add ("armeabi-v7a", "Release", {
			"LOCAL_ARM_MODE := arm",
			"LOCAL_ARM_NEON := true",
		})
		premake.gradle.ndk.appabiextra.add ("armeabi*", "Debug", {
			"LOCAL_ARM_MODE := arm",
		})
		
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
	end
	
	--defines ({"TEST_COMMON=1", "TEST_APP=1"})