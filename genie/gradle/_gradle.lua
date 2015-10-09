premake.gradle = {}
gradle = premake.gradle

dofile "gradle_main.lua"
dofile "gradle_generator.lua"
dofile "gradle_ndk_generator.lua"

premake.gradle.onexecute = function ()
	-- print ("gradle_execute()")
end

premake.gradle.onsolution = function (sln)
	-- print ("android_onsolution() " .. sln.name)
	
	premake.generate (sln, path.join (sln.location, "build.gradle"), premake.gradle.generate_solution_root_build_dot_gradle)
	premake.generate (sln, path.join (sln.location, "support.gradle"), premake.gradle.generate_solution_support_dot_gradle)
	premake.generate (sln, path.join (sln.location, "settings.gradle"), premake.gradle.generate_solution_settings_dot_gradle)
	
end

premake.gradle.onproject = function (prj)
	-- print ("android_onproject() " .. prj.name .. ":" .. prj.kind)
	
	local prj_location = ''
	
	if premake.gradle.is_app_project (prj) then
		local base_location = path.join (prj.solution.location, prj.name)
		prj_location = path.join (base_location, "jni")
		
		premake.generate (prj, path.join (base_location, "build.gradle"), premake.gradle.generate_project_app_build_dot_gradle)
		premake.generate (prj, path.join (prj_location, "Application.mk"), premake.gradle.generate_application_dot_mk)
		
	else
		prj_location = path.join (prj.solution.location, "natives", "jni", prj.name)
	end
	
	-- print (prj_location)
	premake.generate (prj, path.join (prj_location, "Android.mk"), premake.gradle.generate_project_android_mk)
end

newaction ({
	trigger		= "gradle",
	description	= "Generate the Android Studio gradle files",
	execute 	= premake.gradle.onexecute,
	onsolution 	= premake.gradle.onsolution,
	onproject 	= premake.gradle.onproject,
})
