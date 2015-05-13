
premake.ndkbuild.generate_application_dot_mk = function (sln)
	_p (string.format ("APP_PLATFORM := %s", premake.ndkbuild.appplatform))
	_p (string.format ("APP_STL := %s", premake.ndkbuild.appstl))
	
	_p (string.format ("APP_ABI := %s", table.concat (premake.ndkbuild.appabi, " ")))
end

premake.ndkbuild.generate_solution_android_dot_mk = function (sln)
	
	local content = [[
include $(call all-subdir-makefiles)
$(info Compiling for $(TARGET_ARCH_ABI) - $(APP_OPTIM))
]]
	_p (content)

end

premake.ndkbuild.onsolution = function (sln)
	-- print ("android_onsolution() " .. sln.name)
	
	premake.generate (sln, path.join (sln.location, "jni", "Application.mk"), premake.ndkbuild.generate_application_dot_mk)
	premake.generate (sln, path.join (sln.location, "jni", "Android.mk"), premake.ndkbuild.generate_solution_android_dot_mk)
	premake.generate (sln, path.join (sln.location, "build.gradle"), premake.ndkbuild.generate_solution_build_dot_gradle)
	premake.generate (sln, path.join (sln.location, "support.gradle"), premake.ndkbuild.generate_solution_support_dot_gradle)
	premake.generate (sln, path.join (sln.location, "settings.gradle"), function (sln) _p (string.format ("rootProject.name = '%s'", sln.name)) end)
	
end
