dofile ("ndkbuild.lua")

BGFX_DIR = path.getabsolute ("../../vendor/bgfx/")
BX_DIR =  path.getabsolute ("../../vendor/bx/")

language ("C++")
configurations ({"Debug", "Release"})

-- bx toolchain
dofile (path.join (BX_DIR, "scripts/toolchain.lua"))

if not toolchain (path.join (path.getabsolute ("../../.build"), solution().name), path.join(BGFX_DIR, "3rdparty")) then
	print ("toolchain() failed")
	return -- no action specified
end

-- bgfx library
dofile (path.join (BGFX_DIR, "scripts/bgfx.lua"))

function copyLib()
end

bgfxProject ("-static", "StaticLib", {})

project ("bgfx-static")
if _ACTION == "ndkbuild" then
	links {
		"EGL",
		"GLESv2",
		"log",
		"android",
	}
	buildoptions {
		"-std=c++11"
	}
	defines {
		"BGFX_CONFIG_MULTITHREADED=0"
	}
end

-- mix functions
function mix_project (name)
	project (name)
	uuid (os.uuid (name))
	if _ACTION == "ndkbuild" then
		buildoptions {
			"-std=c++11"
		}
	end
end

function mix_project_staticlib (name)
	mix_project (name)
	kind ("StaticLib")
end
		
function mix_project_sharedlib (name)
	mix_project (name)
	kind ("SharedLib")
end
		
function mix_project_app (name)
	mix_project (name)
	kind ("ConsoleApp")
end