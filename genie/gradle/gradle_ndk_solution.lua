
premake.gradle.generate_solution_android_dot_mk = function (sln)
	
	local content = [[
include $(call all-subdir-makefiles)
$(info Compiling for $(TARGET_ARCH_ABI) - $(APP_OPTIM))
]]
	_p (content)

end
