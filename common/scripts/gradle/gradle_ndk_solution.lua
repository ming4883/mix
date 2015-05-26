
premake.gradle.generate_application_dot_mk = function (sln)
	_p ("APP_PLATFORM := %s", premake.gradle.ndk.appplatform)
	_p ("APP_STL := %s", premake.gradle.ndk.appstl)
	
	_p ("APP_ABI := %s", table.concat (premake.gradle.appabi, " "))
	
	if premake.gradle.ndk.ld_gold.enable then
		_p ("APP_LDFLAGS := -fuse-ld=gold")
		
		--if premake.gradle.ndk.ld_gold.multithread then
		--	_p ("APP_LDFLAGS += --threads")
		--else
		--	_p ("APP_LDFLAGS += --no-threads")
		--end
	end
end

premake.gradle.generate_solution_android_dot_mk = function (sln)
	
	local content = [[
include $(call all-subdir-makefiles)
$(info Compiling for $(TARGET_ARCH_ABI) - $(APP_OPTIM))
]]
	_p (content)

end
