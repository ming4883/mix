premake.ndkbuild = {}
premake.ndkbuild.appabi = {"armeabi", "armeabi-v7a", "x86", "mips"}
premake.ndkbuild.appstl = "gnustl_shared"
premake.ndkbuild.appplatform = "android-12"

function ndk_generate_application_mk(sln)
	_p (string.format ("APP_ABI := %s", table.concat (premake.ndkbuild.appabi, " ")))
	_p (string.format ("APP_PLATFORM := %s", premake.ndkbuild.appplatform))
	_p (string.format ("APP_STL := %s", premake.ndkbuild.appstl))
	-- _p ("APP_CPPFLAGS += -std=c++11")
end

function ndk_generate_solution_android_mk(sln)
	_p ("include $(call all-subdir-makefiles)")
end

function ndk_generate_project_android_mk(prj)
	_p ("LOCAL_PATH := $(call my-dir)")
	_p ("include $(CLEAR_VARS)")
	_p ("")
	_p ("LOCAL_MODULE := " .. prj.name)
	-- _p ("$(warning LOCAL_PATH = $(LOCAL_PATH))")
	
	local mkpath = path.join (prj.solution.location, "jni", prj.name)
	
	function processpath(p)
		if (path.isabsolute (p)) then
			return p
		end
		local absofp = path.getabsolute (path.join (prj.location, p))
		local relofp = path.getrelative (mkpath, absofp)
		-- print (mkpath .. "; " .. absofp .. "; " .. relofp)
		return relofp
	end
	
	_p ("")
	--_p ("$(warning Building $(APP_OPTIM) configuration)")
	
	for _, cfgname in ipairs (prj.solution.configurations) do
		local cfg = premake.getconfig (prj, cfgname)
		
		_p (string.format ("ifeq ($(APP_OPTIM),%s)", string.lower (cfg.name)))
		_p (string.format ("  $(warning Building with %s configuration)", cfg.name))
		
		if #cfg.includedirs > 0 then
			_p ("  # includedirs")
			for _, incdir in ipairs (cfg.includedirs) do
				_p (string.format ("  LOCAL_C_INCLUDES += $(LOCAL_PATH)/%s", processpath (incdir)))
			end
		end
		
		if #cfg.defines > 0 then
			_p ("# defines")
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

function ndk_onsolution(sln)
	-- print ("android_onsolution() " .. sln.name)
	
	premake.generate (sln, path.join (sln.location, "jni", "Application.mk"), ndk_generate_application_mk)
	premake.generate (sln, path.join (sln.location, "jni", "Android.mk"), ndk_generate_solution_android_mk)
end

function ndk_onproject(prj)
	-- print ("android_onproject() " .. prj.name .. ":" .. prj.kind)
	
	local prj_location = path.join (prj.solution.location, "jni", prj.name)
	-- print (prj_location)
	os.mkdir (prj_location)
	
	premake.generate (prj, path.join (prj_location, "Android.mk"), ndk_generate_project_android_mk)
end

function ndk_execute()
	print ("android_execute()")
end

newaction ({
	trigger		= "ndkbuild",
	description	= "Generate the Android ndk-build files",
	execute 	= ndk_execute,
	onsolution 	= ndk_onsolution,
	onproject 	= ndk_onproject,
})
