premake.ndkbuild = {}

dofile "ndkbuild_common.lua"
dofile "ndkbuild_gradle.lua"
dofile "ndkbuild_project.lua"
dofile "ndkbuild_solution.lua"

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
