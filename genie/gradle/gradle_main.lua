
premake.gradle.table_merge = function (dst, src)
	--print (src)
	--print (dst)
	for i, v in pairs(src) do
		table.insert (dst, v)
	end
end

--
-- buildscript
--

premake.gradle.buildscript = {}
premake.gradle.buildscript._repositories = {}
premake.gradle.buildscript._dependencies = {}

function premake.gradle.buildscript:repositories (repos)
	premake.gradle.table_merge  (self._repositories, repos)
	return self._repositories
end

function premake.gradle.buildscript:dependencies (deps)
	premake.gradle.table_merge  (self._dependencies, deps)
	return self._dependencies
end

--
-- appabi
--
premake.gradle._appabi = {}

function premake.gradle:get_appabis()
	local abis = {}
	
	premake.gradle.table_merge (abis, self._appabi)
	
	if #abis == 0 then
		premake.gradle.table_merge(abis, {"armeabi", "armeabi-v7a", "x86", "mips"})
	end
	return abis
end

function premake.gradle:appabi (appabi)
	premake.gradle.table_merge  (self._appabi, appabi)
	return self._appabi
end

--
-- project
--
premake.gradle.projects = {}

function premake.gradle:project (prjname)
	
	if nil == prjname then
		prjname = project().name
	end
	
	local grd_prj = self.projects[prjname]
	if nil == grd_prj then
		print ("adding new gradle project " .. prjname)
		--grd_prj = self.newproject()
		grd_prj = {}
		grd_prj.plugins = {}
		grd_prj.repositories = {}
		grd_prj.dependencies = {}

		grd_prj.buildTypes = {}
		grd_prj.buildTypes.add = function (name)
			local btype = {
				debuggable = false,
				jniDebuggable = false,
				renderscriptDebuggable = false,
				renderscriptOptimLevel = 3,
				applicationIdSuffix = nil,
				versionNameSuffix = nil,
				zipAlignEnabled = false,
				minifyEnabled = false, 
				shrinkResources = false, 
				proguardFiles = {},
			}
			grd_prj.buildTypes[name] = btype
		end

		grd_prj.buildTypes.add ("debug")
		grd_prj.buildTypes.debug.debuggable = true
		grd_prj.buildTypes.debug.jniDebuggable = true
		grd_prj.buildTypes.debug.renderscriptDebuggable = true

		grd_prj.buildTypes.add ("release")
		grd_prj.buildTypes.release.zipAlignEnabled = true

		grd_prj.compileSdkVersion = 21
		grd_prj.buildToolsVersion = "21.1.2"
		grd_prj.versionName = "1.0.0"
		grd_prj.versionCode = 1901001 -- please follow the xxyyzzz convention stated in http://developer.android.com/google/play/publishing/multiple-apks.html
		grd_prj.minSdkVersion = 19 -- http://developer.android.com/google/play/publishing/multiple-apks.html
		grd_prj.targetSdkVersion = 19 -- http://developer.android.com/google/play/publishing/multiple-apks.html
		grd_prj.manifest = "AndroidManifest.xml"
		grd_prj.java_srcdirs = {}
		grd_prj.aidl_srcdirs = {}
		grd_prj.renderscript_srcdirs = {}
		grd_prj.res_srcdirs = {}
		grd_prj.assets_srcdirs = {}
		grd_prj.externalprojects = {}
		grd_prj.multiDexEnabled = false -- https://developer.android.com/tools/building/multidex.html

		-- http://tools.android.com/tech-docs/new-build-system/user-guide/apk-splits
		grd_prj.splits = {}
		grd_prj.splits.abi = {}
		grd_prj.splits.abi.enabled = true
		grd_prj.splits.versionCodeBase = 10000000 -- for abi splits

		grd_prj.extra = ""
		
		self.projects[prjname] = grd_prj
	end
	
	return grd_prj
end