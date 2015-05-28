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
	mix_setup_project()
	kind ("StaticLib")
end
		
function mix_setup_sharedlib ()
	mix_setup_project()
	kind ("SharedLib")
end
		
function mix_setup_app ()
	mix_setup_project()
	kind ("WindowedApp")
	
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

-- output location
local outpath = path.join(path.getabsolute ("../../build"), solution().name, _ACTION)

if mix_is_ios() then
	outpath = outpath .. "_ios"
end

location (outpath)
targetdir (outpath)

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