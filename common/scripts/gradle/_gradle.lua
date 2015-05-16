premake.gradle = {}

dofile "gradle_main.lua"
dofile "gradle_ndk_common.lua"
dofile "gradle_ndk_project.lua"
dofile "gradle_ndk_solution.lua"

premake.gradle.onexecute = function ()
	-- print ("gradle_execute()")
end


premake.gradle.onsolution = function (sln)
	-- print ("android_onsolution() " .. sln.name)
	
	premake.generate (sln, path.join (sln.location, "jni", "Application.mk"), premake.gradle.generate_application_dot_mk)
	premake.generate (sln, path.join (sln.location, "jni", "Android.mk"), premake.gradle.generate_solution_android_dot_mk)
	premake.generate (sln, path.join (sln.location, "build.gradle"), premake.gradle.generate_solution_build_dot_gradle)
	premake.generate (sln, path.join (sln.location, "support.gradle"), premake.gradle.generate_solution_support_dot_gradle)
	premake.generate (sln, path.join (sln.location, "settings.gradle"), premake.gradle.generate_solution_settings_dot_gradle)
	
end


premake.gradle.onproject = function (prj)
	-- print ("android_onproject() " .. prj.name .. ":" .. prj.kind)
	
	local prj_location = path.join (prj.solution.location, "jni", prj.name)
	-- print (prj_location)
	os.mkdir (prj_location)
	
	premake.generate (prj, path.join (prj_location, "Android.mk"), premake.gradle.generate_project_android_mk)
end

newaction ({
	trigger		= "gradle",
	description	= "Generate the Android Studio gradle files",
	execute 	= premake.gradle.onexecute,
	onsolution 	= premake.gradle.onsolution,
	onproject 	= premake.gradle.onproject,
})
