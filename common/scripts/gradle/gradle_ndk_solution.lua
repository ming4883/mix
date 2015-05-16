
premake.gradle.generate_application_dot_mk = function (sln)
	_p (string.format ("APP_PLATFORM := %s", premake.gradle.ndk.appplatform))
	_p (string.format ("APP_STL := %s", premake.gradle.ndk.appstl))
	
	_p (string.format ("APP_ABI := %s", table.concat (premake.gradle.appabi, " ")))
end

premake.gradle.generate_solution_android_dot_mk = function (sln)
	
	local content = [[
include $(call all-subdir-makefiles)
$(info Compiling for $(TARGET_ARCH_ABI) - $(APP_OPTIM))
]]
	_p (content)

end
