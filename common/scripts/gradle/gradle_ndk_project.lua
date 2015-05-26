
premake.gradle.generate_project_android_mk = function (prj)
	_p ("LOCAL_PATH := $(call my-dir)")
	_p ("include $(CLEAR_VARS)")
	_p ("")
	_p ("LOCAL_MODULE := " .. prj.name)
	-- _p ("$(info LOCAL_PATH = $(LOCAL_PATH))")
	
	local refpath = path.join (prj.solution.location, "app/jni", prj.name)
	
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
		
		for _, abi in ipairs (premake.gradle.appabi) do
			local extras = premake.gradle.ndk.appabiextra.get (prj.name, abi, cfgname)
			if extras ~= nil and #extras > 0 then
				_p ("")
				_p ("  ifeq ($(TARGET_ARCH_ABI), %s)", abi)
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
	
end
