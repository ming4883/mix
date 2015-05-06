premake.ndkbuild = {}
premake.ndkbuild.appabi = {"armeabi", "armeabi-v7a", "x86", "mips"}
premake.ndkbuild.appabiextra = {}
premake.ndkbuild.appstl = "gnustl_shared"
premake.ndkbuild.appplatform = "android-12"
premake.ndkbuild.gradle = {}
premake.ndkbuild.gradle.manifest = "AndroidManifest.xml"
premake.ndkbuild.gradle.java_srcdirs = {}
premake.ndkbuild.gradle.aidl_srcdirs = {}
premake.ndkbuild.gradle.renderscript_srcdirs = {}
premake.ndkbuild.gradle.res_srcdirs = {}
premake.ndkbuild.gradle.assets_srcdirs = {}

-- Assign the APP_ABI in Application.mk
-- Example:
-- ndkbuild_appabi {"armeabi", "armeabi-v7a", "x86", "mips"}
--
function ndkbuild_appabi (abi)
	premake.ndkbuild.appabi = abi
end


function ndkbuild_keyof (prj, abi, cfg)
	return (prj .. abi) .. cfg 
end

function ndkbuild_gradle_manifest (path)
	premake.ndkbuild.gradle.manifest = path
end

function ndkbuild_gradle_java_srcdirs (dirs)
	premake.ndkbuild.gradle.java_srcdirs = dirs
end

function ndkbuild_gradle_aidl_srcdirs (dirs)
	premake.ndkbuild.gradle.aidl_srcdirs = dirs
end

function ndkbuild_gradle_renderscript_srcdirs (dirs)
	premake.ndkbuild.gradle.renderscript_srcdirs = dirs
end

function ndkbuild_gradle_res_srcdirs (dirs)
	premake.ndkbuild.gradle.res_srcdirs = dirs
end

function ndkbuild_gradle_assets_srcdirs (dirs)
	premake.ndkbuild.gradle.assets_srcdirs = dirs
end

-- Set the extra lines for an ABI of a project's Android.mk
-- Example:
-- ndkbuild_appabiextra ("mylib", "armeabi-v7a", "Debug", {
--	  "	LOCAL_ARM_NEON := true"
-- })
--
function ndkbuild_appabiextra (prj, abi, cfg, extra)
	if extra ~= nil then
		premake.ndkbuild.appabiextra[ndkbuild_keyof (prj, abi, cfg)] = extra
		return extra
	else
		return premake.ndkbuild.appabiextra[ndkbuild_keyof (prj, abi, cfg)] 
	end
end

--
-- Example: ndkbuild_appstl "gnustl_shared"
--
function ndkbuild_appstl (stl)
	premake.ndkbuild.appstl = stl
end

--
-- Example: ndkbuild_appplatform "android-12"
--
function ndkbuild_appplatform (stl)
	premake.ndkbuild.appplatform = stl
end

premake.ndkbuild.generate_application_mk = function (sln)
	_p (string.format ("APP_PLATFORM := %s", premake.ndkbuild.appplatform))
	_p (string.format ("APP_STL := %s", premake.ndkbuild.appstl))
	
	_p (string.format ("APP_ABI := %s", table.concat (premake.ndkbuild.appabi, " ")))
end

premake.ndkbuild.generate_solution_android_mk = function (sln)
	_p ("include $(call all-subdir-makefiles)")
end

premake.ndkbuild.generate_solution_build_gradle = function (sln)

	local refpath = sln.location
	
	function processpath (p)
		local absofp = path.getabsolute (path.join (sln.location, p))
		local relofp = path.getrelative (refpath, absofp)
		-- print (refpath .. "; " .. absofp .. "; " .. relofp)
		return relofp
	end
	
	function fmt_srcdirs (dirs)
		local ret = ""
		for _, p in ipairs (dirs) do
			ret = ret .. string.format ("'%s', ", processpath (p))
		end
		return ret
	end
	
	_p ("buildscript {")
	_p ("  repositories {")
	_p ("    jcenter()")
	_p ("  }")
	_p ("  dependencies {")
	_p ("    classpath 'com.android.tools.build:gradle:1.1.0'")
	_p ("  }")
	_p ("}")
	_p ("")
	_p ("allprojects {")
	_p ("  repositories {")
	_p ("    jcenter()")
	_p ("  }")
	_p ("}")
	_p ("")
	_p ("apply plugin: 'com.android.application'")
	_p ("")
	_p ("android {")
	_p ("  compileSdkVersion 21")
	_p ("  buildToolsVersion '21.1.2'")
	_p ("  sourceSets {")
	_p ("    main {")
	_p ("      jniLibs.srcDir './libs'")
	_p ("      jni.srcDirs = []")
	_p (string.format ("      manifest.srcFile '%s'", processpath (premake.ndkbuild.gradle.manifest)))
	
	if #premake.ndkbuild.gradle.java_srcdirs > 0 then
		_p (string.format ("      java.srcDirs = [%s]", fmt_srcdirs (premake.ndkbuild.gradle.java_srcdirs)))
	end
	--_p (string.format ("      resources.srcDirs = [%s]", ""))
	
	if #premake.ndkbuild.gradle.aidl_srcdirs > 0 then
		_p (string.format ("      aidl.srcDirs = [%s]", fmt_srcdirs (premake.ndkbuild.gradle.aidl_srcdirs)))
	end
	
	if #premake.ndkbuild.gradle.renderscript_srcdirs > 0 then
		_p (string.format ("      renderscript.srcDirs = [%s]", fmt_srcdirs (premake.ndkbuild.gradle.renderscript_srcdirs)))
	end
	
	if #premake.ndkbuild.gradle.res_srcdirs > 0 then
		_p (string.format ("      res.srcDirs = [%s]", fmt_srcdirs (premake.ndkbuild.gradle.res_srcdirs)))
	end
	
	if #premake.ndkbuild.gradle.assets_srcdirs > 0 then
		_p (string.format ("      assets.srcDirs = [%s]", fmt_srcdirs (premake.ndkbuild.gradle.assets_srcdirs)))
	end
	
	_p ("    }")
	_p ("  }")
	_p ("}")
end

premake.ndkbuild.generate_project_android_mk = function (prj)
	_p ("LOCAL_PATH := $(call my-dir)")
	_p ("include $(CLEAR_VARS)")
	_p ("")
	_p ("LOCAL_MODULE := " .. prj.name)
	-- _p ("$(info LOCAL_PATH = $(LOCAL_PATH))")
	
	local refpath = path.join (prj.solution.location, "jni", prj.name)
	
	function processpath(p)
		local absofp = path.getabsolute (path.join (prj.location, p))
		local relofp = path.getrelative (refpath, absofp)
		-- print (refpath .. "; " .. absofp .. "; " .. relofp)
		return relofp
	end
	
	_p ("")
	
	for _, cfgname in ipairs (prj.solution.configurations) do
		local cfg = premake.getconfig (prj, cfgname)
		
		-- $(findstring pattern, in) return "" if pattern is not found
		_p (string.format ("ifneq (, $(findstring %s, $(APP_OPTIM)))", string.lower (cfg.name)))
		_p (string.format ("  $(info Building with %s configuration)", cfg.name))
		
		if #cfg.includedirs > 0 then
			_p ("  # includedirs")
			for _, incdir in ipairs (cfg.includedirs) do
				_p (string.format ("  LOCAL_C_INCLUDES += $(LOCAL_PATH)/%s", processpath (incdir)))
			end
		end
		
		if #cfg.defines > 0 then
			_p ("  # defines")
			for _, def in ipairs (cfg.defines) do
				_p (string.format ("  LOCAL_CFLAGS += -D%s", def))
			end
		end
		
		if #cfg.buildoptions > 0 then
			_p ("  # buildoptions")
			for _, opt in ipairs (cfg.buildoptions) do
				_p (string.format ("  LOCAL_CFLAGS += %s", opt))
			end
		end
		
		local ldlibs = premake.getlinks (cfg, "system", "name")
		
		if #ldlibs > 0  then
			_p ("  # dynamic libraries")
			for _, lnk in ipairs (ldlibs) do
				_p (string.format ("  LOCAL_LDLIBS += -l%s", lnk))
			end
		end
		
		local deps = premake.getlinks (cfg, "dependencies", "object")
		
		if #deps > 0 then
			_p ("  # dependencies")
			for _, lnk in ipairs (deps) do
				local dep = premake.findproject (lnk.project.name)
				
				-- _p (string.format ("kind = %s", dep.kind))
				if dep.kind == "StaticLib" then
					_p (string.format ("  LOCAL_STATIC_LIBRARIES += %s", dep.name))
				else
					_p (string.format ("  LOCAL_SHARED_LIBRARIES += %s", dep.name))
				end
			end
		end
		
		if prj.kind ~= "StaticLib" and #cfg.linkoptions > 0 then
			_p ("  # linkoptions")
			for _, opt in ipairs (cfg.linkoptions) do
				_p (string.format ("  LOCAL_LDFLAGS += %s", opt))
			end
		end
		
		for _, abi in ipairs (premake.ndkbuild.appabi) do
			local extras = ndkbuild_appabiextra (prj.name, abi, cfgname)
			if extras ~= nil then
				_p ("")
				_p (string.format ("  ifeq ($(TARGET_ARCH_ABI), %s)", abi))
				_p (string.format ("    %s", table.concat (extras, "\n    ")))
				_p ("  endif")
			end
		end
		
		_p ("endif")
		_p ("")
	end
	
	for _, file in ipairs (prj.files) do
		if (path.iscfile (file) or path.iscppfile (file)) then
			if not table.icontains (prj.excludes, file) then
				_p (string.format ("LOCAL_SRC_FILES += $(LOCAL_PATH)/%s", processpath (file)))
			end
		end
	end
	
	_p ("")
	
	if prj.kind == "StaticLib" or prj.kind == "SharedLib" then
		_p ("LOCAL_EXPORT_C_INCLUDES := $(LOCAL_C_INCLUDES)")
		_p ("LOCAL_EXPORT_CFLAGS := $(LOCAL_CFLAGS)")
		_p ("LOCAL_EXPORT_LDFLAGS := $(LOCAL_LDFLAGS)")
		_p ("LOCAL_EXPORT_LDLIBS := $(LOCAL_LDLIBS)")
		_p ("")
	end
	
	if prj.kind == "StaticLib" then
		_p ("include $(BUILD_STATIC_LIBRARY)")
	else
		_p ("include $(BUILD_SHARED_LIBRARY)")
	end
	
end

premake.ndkbuild.onsolution = function (sln)
	-- print ("android_onsolution() " .. sln.name)
	
	premake.generate (sln, path.join (sln.location, "jni", "Application.mk"), premake.ndkbuild.generate_application_mk)
	premake.generate (sln, path.join (sln.location, "jni", "Android.mk"), premake.ndkbuild.generate_solution_android_mk)
	premake.generate (sln, path.join (sln.location, "build.gradle"), premake.ndkbuild.generate_solution_build_gradle)
	premake.generate (sln, path.join (sln.location, "settings.gradle"), function (sln) _p (string.format ("rootProject.name = '%s'", sln.name)) end)
	
end

premake.ndkbuild.onproject = function (prj)
	-- print ("android_onproject() " .. prj.name .. ":" .. prj.kind)
	
	local prj_location = path.join (prj.solution.location, "jni", prj.name)
	-- print (prj_location)
	os.mkdir (prj_location)
	
	premake.generate (prj, path.join (prj_location, "Android.mk"), premake.ndkbuild.generate_project_android_mk)
end

premake.ndkbuild.onexecute = function ()
	-- print ("android_execute()")
end

newaction ({
	trigger		= "ndkbuild",
	description	= "Generate the Android ndk-build files",
	execute 	= premake.ndkbuild.onexecute,
	onsolution 	= premake.ndkbuild.onsolution,
	onproject 	= premake.ndkbuild.onproject,
})
