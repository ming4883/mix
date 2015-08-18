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

function mix_is_osx()
	return string.find (_ACTION, "xcode") ~= nil and "osx" == _OPTIONS["xcode"]
end


-- output location
--print (path.getabsolute ("./"))
local OUTPATH = path.join(PROJECT_DIR, "build", _ACTION)

if mix_is_ios() then
	OUTPATH = OUTPATH .. "_ios"
	
	-- patch the premake.xcode.getbuildcategory method to support .dat and .zip files as Resources
	local old_getbuildcategory = premake.xcode.getbuildcategory
	premake.xcode.getbuildcategory = function(node)
		local cats = {
			[".dat"] = "Resources",
			[".zip"] = "Resources",
		}
		
		local ret = cats[path.getextension(node.name)]
		if (nil == ret) then
			return old_getbuildcategory(node)
		end
		return ret;
	end
end

if mix_is_osx() then
	OUTPATH = OUTPATH .. "_osx"
	
	-- patch the premake.xcode.getbuildcategory method to support .dat and .zip files as Resources
	local old_getbuildcategory = premake.xcode.getbuildcategory
	premake.xcode.getbuildcategory = function(node)
		local cats = {
			[".dat"] = "Resources",
			[".zip"] = "Resources",
		}
		
		local ret = cats[path.getextension(node.name)]
		if (nil == ret) then
			return old_getbuildcategory(node)
		end
		return ret;
	end
end

location (OUTPATH)
--targetdir (path.getrelative (path.getabsolute ("."), OUTPATH))
targetdir (OUTPATH.."/bin")

function mix_setup_project ()
	local prj = project()
	targetdir (path.join (OUTPATH, prj.name))
	
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
	
	if mix_is_osx() then
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

local MIX_ZLIB_DIR = path.join (MIX_DIR, "vendor", "zlib")
local MIX_MINIZIP_DIR = path.join (MIX_ZLIB_DIR, "contrib", "minizip")
	
function mix_add_zlib_project()

	project ("mix_zlib")
	kind ("StaticLib")
	
	-- zlib & minizip
	files {
		-- zlib
		path.join (MIX_ZLIB_DIR, "adler32.c"),
		path.join (MIX_ZLIB_DIR, "compress.c"),
		path.join (MIX_ZLIB_DIR, "crc32.c"),
		path.join (MIX_ZLIB_DIR, "deflate.c"),
		path.join (MIX_ZLIB_DIR, "infback.c"),
		path.join (MIX_ZLIB_DIR, "inffast.c"),
		path.join (MIX_ZLIB_DIR, "inflate.c"),
		path.join (MIX_ZLIB_DIR, "inftrees.c"),
		path.join (MIX_ZLIB_DIR, "trees.c"),
		path.join (MIX_ZLIB_DIR, "uncompr.c"),
		path.join (MIX_ZLIB_DIR, "zutil.c"),
		-- minizip
		path.join (MIX_MINIZIP_DIR, "unzip.c"),
		path.join (MIX_MINIZIP_DIR, "ioapi.c"),
	}
	excludes {
		path.join (MIX_ZLIB_DIR, "gz*"),
	}
	
	if not mix_is_windows_desktop() then
		defines { "IOAPI_NO_64" }
	else
		defines { "_CRT_NONSTDC_NO_WARNINGS" }
	end
	
	includedirs {
		MIX_ZLIB_DIR,
		MIX_MINIZIP_DIR,
	}
	
end

function mix_use_zlib()

	includedirs {
		MIX_ZLIB_DIR,
		MIX_MINIZIP_DIR,
	}
	
	links {
		"mix_zlib",
	}
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
	
	if mix_is_osx() then
		links {
			"Cocoa.framework"
		}
	end
	
	if mix_is_windows_desktop() then
		links {
			"gdi32",
			"psapi",
		}
		--postbuildcommands {"mklink /d $(OutDir)\\runtime C:\\"}
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
		path.join (MIX_DIR, "include/"),
	}
	
	links {
		"bgfx_static",
	}
	
	if mix_is_android() then
		defines { "MIX_ANDROID" }
		
		local asset_dir = path.join ("../runtime/", project().name, "android")
		if os.isdir (asset_dir) then
			local grd = gradle()
			grd.assets_srcdirs = {asset_dir}
		end
	end
	
	if mix_is_windows_desktop() then
		defines { "MIX_WINDOWS_DESKTOP" }
	end
	
	if mix_is_ios() then
		files { path.join (MIX_DIR, "src/mix/*ios.mm") }
		local runtime_file = path.join ("../runtime/", project().name, "ios/runtime.zip");
		if os.isfile (runtime_file) then
			files {runtime_file}
		end
		defines { "MIX_IOS" }
	end
	
	if mix_is_osx() then
		files { path.join (MIX_DIR, "src/mix/*osx.mm") }
		defines { "MIX_OSX" }
	end
	
	mix_use_zlib()
	
end

function mix_add_unit_tests_project ()
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
	
	if mix_is_osx() then
		defines { "MIX_OSX" }	
		files {
			path.join (MIX_DIR, "src/mix/*osx.mm"),
		}
	end
	
	excludes {
		path.join (MIX_DIR, "src/mix/mix_entry*"),
	}
	
	mix_use_zlib()
	
end

-- bgfx library
dofile (path.join (BGFX_DIR, "scripts/bgfx.lua"))

function copyLib()
end

bgfxProject ("_static", "StaticLib", {})

project ("bgfx_static")
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
	
-- bgfx shader compiler
if mix_is_windows_desktop() then
	dofile (path.join (BGFX_DIR, "scripts/shaderc.lua"))
end