local MIX_COMMON_DIR = path.getabsolute ("../../common")
local PROJECT_DIR = path.getabsolute ("../src")

solution "example-app"
	dofile (path.join (MIX_COMMON_DIR, "scripts/setup.lua"))
	
	ndkbuild_appabi {"armeabi", "armeabi-v7a"}

	mix_project_app "example-app"
		files {
			path.join (PROJECT_DIR, "entry.cpp")
		}
		links {
			"bgfx-static",
		}
	ndkbuild_appabiextra ("example-app", "armeabi", "Release", {
		"LOCAL_ARM_MODE := arm",
	})
	ndkbuild_appabiextra ("example-app", "armeabi", "Debug", {
		"LOCAL_ARM_MODE := arm",
	})
	ndkbuild_appabiextra ("example-app", "armeabi-v7a", "Release", {
		"LOCAL_ARM_MODE := arm",
		"LOCAL_ARM_NEON := true",
	})
	ndkbuild_appabiextra ("example-app", "armeabi-v7a", "Debug", {
		"LOCAL_ARM_MODE := arm",
	})
	
	ndkbuild_appabiextra ("bgfx-static", "armeabi", "Release", {
		"LOCAL_ARM_MODE := arm",
	})
	ndkbuild_appabiextra ("bgfx-static", "armeabi", "Debug", {
		"LOCAL_ARM_MODE := arm",
	})
	ndkbuild_appabiextra ("bgfx-static", "armeabi-v7a", "Release", {
		"LOCAL_ARM_MODE := arm",
		"LOCAL_ARM_NEON := true",
	})
	ndkbuild_appabiextra ("bgfx-static", "armeabi-v7a", "Debug", {
		"LOCAL_ARM_MODE := arm",
	})
	--defines ({"TEST_COMMON=1", "TEST_APP=1"})