dofile ("gradle/_gradle.lua")

BGFX_DIR = path.getabsolute ("../../vendor/bgfx/")
BX_DIR =  path.getabsolute ("../../vendor/bx/")

language ("C++")
configurations ({"Debug", "Release"})

-- bx toolchain
dofile (path.join (BX_DIR, "scripts/toolchain.lua"))

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
local OUTPATH = path.join(path.getabsolute ("../../build"), solution().name, _ACTION)

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