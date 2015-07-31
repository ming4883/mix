if nil == PROJECT_DIR then
	error ("global variable 'PROJECT_DIR' is not defined prior setup.lua")
end

if nil == MIX_DIR then
	error ("global variable 'MIX_DIR' is not defined prior setup.lua")
end

dofile ("gradle/_gradle.lua")

BGFX_DIR = path.getabsolute ("../vendor/bgfx/")
BX_DIR =  path.getabsolute ("../vendor/bx/")

language ("C++")
configurations ({"Debug", "Release"})

-- bx toolchain
dofile ("toolchain.lua")

if not toolchain ("", path.join(BGFX_DIR, "3rdparty")) then
	print ("toolchain() failed")
	return -- no action specified
end

-- mix functions
function mix_is_android()
	return _ACTION == "gradle"
end

function mix_is_windows_desktop()
	return _ACTION == "vs2013"
end

function mix_is_ios()
	return string.find (_ACTION, "xcode") ~= nil and "ios" == _OPTIONS["xcode"]
end


-- output location
--print (path.getabsolute ("./"))
local OUTPATH = path.join(PROJECT_DIR, "build", _ACTION)

if mix_is_ios() then
	OUTPATH = OUTPATH .. "_ios"
end

location (OUTPATH)
targetdir (path.join (path.getrelative (path.getabsolute ("."), OUTPATH), "out"))

function mix_setup_project ()
	local prj = project()
	
	uuid (os.uuid (prj.name))
	
	if mix_is_android() then
		buildoptions {
			"-std=c++11"
		}
		
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
	end
	
	if mix_is_ios() then
		buildoptions {
			"-std=c++11"
		}
	end
	
end

function mix_setup_staticlib ()
	kind ("StaticLib")
	mix_setup_project()
end
		
function mix_setup_sharedlib ()
	kind ("SharedLib")
	mix_setup_project()
end
		
function mix_setup_app ()
	kind ("WindowedApp")
	mix_setup_project()
	
	includedirs {
		path.join (BX_DIR, "include"),
		path.join (BGFX_DIR, "include"),
	}
	
	if mix_is_ios() then
		linkoptions {
			"-framework CoreFoundation",
			"-framework Foundation",
			"-framework OpenGLES",
			"-framework UIKit",
			"-framework QuartzCore",
		}
	end
	
	if mix_is_windows_desktop() then
		links {
			"gdi32",
			"psapi",
		}
	end
end


local GTEST_DIR = path.getabsolute (path.join (MIX_DIR, "vendor", "gtest"))

function mix_setup_common_app()

	mix_setup_app()
	
	
	files {
		path.join (MIX_DIR, "include/mix/*.h"),
		path.join (MIX_DIR, "src/mix/*.cpp"),
	}
	
	excludes {
		path.join (MIX_DIR, "src/mix/mix_tests*"),
	}
	
	includedirs {
		path.join (MIX_DIR, "include/")
	}
	
	links {
		"bgfx-static",
	}
	
	if mix_is_android() then
		defines { "MIX_ANDROID" }
	end
	
	if mix_is_windows_desktop() then
		defines { "MIX_WINDOWS_DESKTOP" }
	end
	
	if mix_is_ios() then
		files { path.join (MIX_DIR, "src/mix/*ios.mm") }
		defines { "MIX_IOS" }
	end
	
end

function mix_common_tests_project ()
	project ("mix_common_tests")
	kind ("WindowedApp")
	mix_setup_project()
	
	includedirs {
		path.join (BX_DIR, "include"),
		path.join (GTEST_DIR, "fused-src"),
		path.join (MIX_DIR, "include/")
	}
	
	files {
		path.join (MIX_DIR, "include/mix/*.h"),
		path.join (MIX_DIR, "src/mix/*.cpp"),
		path.join (GTEST_DIR, "fused-src/gtest/gtest.h"),
		path.join (GTEST_DIR, "fused-src/gtest/gtest-all.cc"),
	}
	
	defines { "MIX_TESTS" }
	
	if mix_is_android() then
		defines { "MIX_ANDROID" }
		links {
			"log",
			"android",
		}
		
		local grd = gradle()
		
		grd.manifest = path.join (MIX_DIR, "src/mix/android/tests/AndroidManifest.xml")
		
		grd.java_srcdirs = {
			path.join (MIX_DIR, "src/mix/android/app/java"),
			path.join (MIX_DIR, "src/mix/android/tests/java"),
		}
	end
	
	if mix_is_windows_desktop() then
		defines { "MIX_WINDOWS_DESKTOP" }
	end
	
	if mix_is_ios() then
		defines { "MIX_IOS" }	
		files {
			path.join (MIX_DIR, "src/mix/*ios.mm"),
			path.join (MIX_DIR, "src/mix/ios/tests/info.plist"),
		}
	end
	
	excludes {
		path.join (MIX_DIR, "src/mix/mix_entry*"),
	}
	
end

-- bgfx library
dofile (path.join (BGFX_DIR, "scripts/bgfx.lua"))

function copyLib()
end

bgfxProject ("-static", "StaticLib", {})

project ("bgfx-static")
	if mix_is_android() then
		links {
			"EGL",
			"GLESv2",
			"log",
			"android",
		}
		defines {
			"BGFX_CONFIG_MULTITHREADED=0"
		}
	end
	
	if mix_is_ios() then
		defines {
			"BGFX_CONFIG_MULTITHREADED=0"
		}
	end
	
	if mix_is_windows_desktop() then
		defines {
			"BGFX_CONFIG_RENDERER_DIRECT3D11=1"
		}
	end
	
	mix_setup_project()