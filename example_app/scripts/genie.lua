local MIX_COMMON_DIR = path.getabsolute ("../../common")
local PROJECT_DIR = path.getabsolute ("../")

solution "example_app"
	dofile (path.join (MIX_COMMON_DIR, "scripts/setup.lua"))
	
	ndkbuild_appabi {"armeabi", "armeabi-v7a", "x86"}

	mix_project_app "example_app"
		files {
			path.join (PROJECT_DIR, "src/entry.cpp")
		}
		links {
			"bgfx-static",
		}
		
	ndkbuild_appabiextra ("armeabi", "Release", {
		"LOCAL_ARM_MODE := arm",
	})
	ndkbuild_appabiextra ("armeabi-v7a", "Release", {
		"LOCAL_ARM_MODE := arm",
		"LOCAL_ARM_NEON := true",
	})
	ndkbuild_appabiextra ("armeabi*", "Debug", {
		"LOCAL_ARM_MODE := arm",
	})
	
	ndkbuild_gradle().manifest = path.join (PROJECT_DIR, "android/AndroidManifest.xml")
	
	ndkbuild_gradle().java_srcdirs = {
		path.join (MIX_COMMON_DIR, "android/java"),
		path.join (PROJECT_DIR, "android/java")
	}
	
	ndkbuild_gradle().res_srcdirs = {
		path.join (PROJECT_DIR, "android/res")
	}
	
	ndkbuild_gradle().buildscript.repositories = {
		--"maven { url 'https://maven.fabric.io/public' }"
	}
	
	ndkbuild_gradle().buildscript.dependencies = {
		--"classpath 'io.fabric.tools:gradle:1.+'"
	}
	
	ndkbuild_gradle().plugins = {
		-- "io.fabric"
	}
	
	ndkbuild_gradle().dependencies = {
		"compile 'com.google.android.gms:play-services-games:7.3.0'"
	}
	
	ndkbuild_gradle().externalprojects["dummy"] = path.join (PROJECT_DIR, "vendor/dummy/android")
	--defines ({"TEST_COMMON=1", "TEST_APP=1"})