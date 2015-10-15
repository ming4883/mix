
premake.gradle.generate_application_dot_mk = function (prj)

	local grd_prj = gradle:project (prj.name)
	
	_p ("APP_PLATFORM := %s", grd_prj.ndk_app_platform)
	_p ("APP_STL := %s", grd_prj.ndk_app_stl)
	
	if #grd_prj._appabis > 0 then
		_p ("APP_ABI := %s", table.concat (grd_prj._appabis, " "))
	end
	
	if #grd_prj._ndk_app_cflags > 0 then
		_p ("APP_CFLAGS := %s", table.concat (grd_prj._ndk_app_cflags, " "))
	end
	
	if #grd_prj._ndk_app_cppflags > 0 then
		_p ("APP_CPPFLAGS := %s", table.concat (grd_prj._ndk_app_cppflags, " "))
	end
	
	if #grd_prj._ndk_app_ldflags > 0 then
		_p ("APP_LDFLAGS := %s", table.concat (grd_prj._ndk_app_ldflags, " "))
	end
end

premake.gradle.generate_solution_android_dot_mk = function (sln)
	
	local content = [[
include $(call all-subdir-makefiles)
$(info Compiling for $(TARGET_ARCH_ABI) - $(APP_OPTIM))
]]
	_p (content)

end

premake.gradle.generate_project_android_mk = function (prj)

	local grd_prj = gradle:project (prj.name)
	
	_p ("LOCAL_PATH := $(call my-dir)")
	_p ("include $(CLEAR_VARS)")
	_p ("")
	_p ([[
PROJECT_C_INCLUDES := 
PROJECT_CFLAGS := 
PROJECT_STATIC_LIBRARIES := 
PROJECT_SHARED_LIBRARIES :=
	]])
	_p ("LOCAL_MODULE := " .. prj.name)
	-- _p ("$(info LOCAL_PATH = $(LOCAL_PATH))")
	
	local refpath
	
	if premake.gradle.is_app_project (prj) then
		refpath = path.join (prj.solution.location, prj.name, "jni")
	else
		refpath = path.join (prj.solution.location, "natives", "jni", prj.name)
	end
	
	function processpath(p)
		local absofp = path.getabsolute (path.join (prj.location, p))
		local relofp = path.getrelative (refpath, absofp)
		-- print (refpath .. "; " .. absofp .. "; " .. relofp)
		return relofp
	end
	
	_p ("")
	
	for _, cfgname in ipairs (prj.solution.configurations) do
		local cfg = premake.getconfig (prj, cfgname)
		
		-- NOTE: $(findstring pattern, in) return "" if pattern is not found
		_p ("ifneq (, $(findstring %s, $(APP_OPTIM)))", string.lower (cfg.name))
		--_p ("  $(info Building with %s configuration)", cfg.name)
		
		if #cfg.includedirs > 0 then
			_p ("  # includedirs")
			for _, incdir in ipairs (cfg.includedirs) do
				_p (string.format ("  PROJECT_C_INCLUDES += $(LOCAL_PATH)/%s", processpath (incdir)))
			end
		end
		
		if #cfg.defines > 0 then
			_p ("  # defines")
			for _, def in ipairs (cfg.defines) do
				_p ("  PROJECT_CFLAGS += -D%s", def)
			end
		end
		
		if #cfg.buildoptions > 0 then
			_p ("  # buildoptions")
			for _, opt in ipairs (cfg.buildoptions) do
				_p ("  PROJECT_CFLAGS += %s", opt)
			end
		end
		
		if #cfg.linkoptions > 0 then
			_p ("  # linkoptions")
			for _, opt in ipairs (cfg.linkoptions) do
				_p ("  PROJECT_LDFLAGS += %s", opt)
			end
		end
		
		local ldlibs = premake.getlinks (cfg, "system", "name")
		
		if #ldlibs > 0  then
			_p ("  # dynamic libraries")
			for _, lnk in ipairs (ldlibs) do
				_p ("  PROJECT_LDLIBS += -l%s", lnk)
			end
		end
		
		local deps = premake.getlinks (cfg, "dependencies", "object")
		
		if #deps > 0 then
			_p ("  # dependencies")
			for _, lnk in ipairs (deps) do
				local dep = premake.findproject (lnk.project.name)
				
				-- _p (string.format ("kind = %s", dep.kind))
				if dep.kind == "StaticLib" then
					_p ("  PROJECT_STATIC_LIBRARIES += %s", dep.name)
				else
					_p ("  PROJECT_SHARED_LIBRARIES += %s", dep.name)
				end
			end
		end
		
		for i, abiname in ipairs (grd_prj._appabis) do
			local extras = grd_prj:buildType(cfgname):get_ndk_extras (abiname)
			if #extras > 0 then
				_p ("")
				_p ("  ifeq ($(TARGET_ARCH_ABI), %s)", abiname)
				_p ("    %s", table.concat (extras, "\n    "))
				_p ("  endif")
			end
		end
		
		_p ("endif")
		_p ("")
	end
	
	for _, file in ipairs (prj.files) do
		if (path.iscfile (file) or path.iscppfile (file)) then
			if not table.icontains (prj.excludes, file) then
				_p ("LOCAL_SRC_FILES += $(LOCAL_PATH)/%s", processpath (file))
			end
		end
	end
	
	_p ("")
	
	_p ("LOCAL_C_INCLUDES := $(PROJECT_C_INCLUDES)")
	_p ("LOCAL_CFLAGS := $(PROJECT_CFLAGS)")
	_p ("LOCAL_STATIC_LIBRARIES := $(PROJECT_STATIC_LIBRARIES)")
	_p ("LOCAL_SHARED_LIBRARIES := $(PROJECT_SHARED_LIBRARIES)")
	
	if prj.kind ~= "StaticLib" then
		_p ("LOCAL_LDFLAGS := $(PROJECT_LDFLAGS)")
		_p ("LOCAL_LDLIBS := $(PROJECT_LDLIBS)")
	end
	
	if prj.kind == "StaticLib" or prj.kind == "SharedLib" then
		_p ("LOCAL_EXPORT_C_INCLUDES := $(PROJECT_C_INCLUDES)")
		_p ("LOCAL_EXPORT_CFLAGS := $(PROJECT_CFLAGS)")
		_p ("LOCAL_EXPORT_LDFLAGS := $(PROJECT_LDFLAGS)")
		_p ("LOCAL_EXPORT_LDLIBS := $(PROJECT_LDLIBS)")
		_p ("")
	end
	
	if prj.kind == "StaticLib" then
		_p ("include $(BUILD_STATIC_LIBRARY)")
	else
		_p ("include $(BUILD_SHARED_LIBRARY)")
	end
	
	if #grd_prj._ndk_extras > 0 then
		_p ("%s", table.concat (grd_prj._ndk_extras, "\n"))
	end
	
	local deps = premake.getlinks (premake.getconfig (prj), "dependencies", "object")
	
	if premake.gradle.is_app_project (prj) then
		for _, lnk in ipairs (deps) do
			local dep = premake.findproject (lnk.project.name)
			_p ("$(call import-module, %s)", dep.name)
		end
	end
	
end
