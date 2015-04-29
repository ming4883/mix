dofile ("_ndkbuild.lua")

BGFX_DIR = path.getabsolute ("../vendor/bgfx/")
BX_DIR =  path.getabsolute ("../vendor/bx/")

local dirs = {
	path.join (BX_DIR, "include/"),
	path.join (BGFX_DIR, "include/"),
}

solution ("mix")
	language ("C++")
	configurations ({"Debug", "Release"})
	premake.ndkbuild.appabi = {"armeabi"}

	dofile (path.join(BX_DIR, "scripts/toolchain.lua"))
	if not toolchain(path.getabsolute ("../.build"), path.join(BGFX_DIR, "3rdparty")) then
		print ("toolchain() failed")
		return -- no action specified
	end

	dofile (path.join (BGFX_DIR, "scripts/bgfx.lua"))
	
	function copyLib()
	end
	
	bgfxProject ("", "StaticLib", {})
	project ("bgfx")
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
	end
	
	dofile "example-app.lua"
	