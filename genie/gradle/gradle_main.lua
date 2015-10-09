premake.gradle.is_app_project = function (prj)
	return string.match (prj.kind, "App")
end

premake.gradle.table_merge = function (dst, src)
	if nil ~= src then
		for i, v in pairs(src) do
			table.insert (dst, v)
		end
	end
	return dst
end

premake.gradle.is_wildcard = function (pattern)
	return pattern ~= path.wildcards (pattern)
end

premake.gradle.match_wildcard = function (s, wildcards)
	local p = path.wildcards (wildcards)
	
	if p == wildcards then
		-- not using wildcards
		return (s == p)
	else
		-- using wildcards
		return (string.find (s, p) ~= nil)
	end
end

--
-- buildscript
--

premake.gradle.buildscript = {}
premake.gradle.buildscript._repositories = {}
premake.gradle.buildscript._dependencies = {}

function premake.gradle.buildscript:repositories (values)
	return premake.gradle.table_merge  (self._repositories, values)
end

function premake.gradle.buildscript:dependencies (values)
	return premake.gradle.table_merge  (self._dependencies, values)
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

function premake.gradle:appabi (values)
	return premake.gradle.table_merge  (self._appabi, values)
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
		
		grd_prj = {}
		
		-- ndk
		grd_prj.ndk_app_stl = "gnustl_shared"
		grd_prj.ndk_app_platform = "android-12"
		
		grd_prj._ndk_app_cflags = {}
		function grd_prj:ndk_app_cflags (values)
			return premake.gradle.table_merge  (self._ndk_app_cflags, values)
		end
		
		grd_prj._ndk_app_cppflags = {}
		function grd_prj:ndk_app_cppflags (values)
			return premake.gradle.table_merge  (self._ndk_app_cppflags, values)
		end
		
		grd_prj._ndk_app_ldflags = {}
		function grd_prj:ndk_app_ldflags (values)
			return premake.gradle.table_merge  (self._ndk_app_ldflags, values)
		end
		-- appabis
		grd_prj._appabis = {}

		function grd_prj:appabi (name)
			local abi = self._appabis[name]
			if nil == abi then
				print ("adding new abi " .. name)
				abi = {}
				
				-- ndk_extras
				abi._ndk_extras = {}
				function abi:ndk_extras (cfg, values)
					if premake.gradle.is_wildcard (cfg) then
						
						for k, v in pairs(self._ndk_extras) do
							if premake.gradle.match_wildcard (k, cfg) then
								premake.gradle.table_merge  (v, values)
							end
						end
						
					else
						local cfg_key = string.lower (cfg)
						--local cfg_key = cfg
						local extras = self._ndk_extras[cfg_key]
						if extras == nil then
							extras = {}
							self._ndk_extras[cfg_key] = extras
						end
						return premake.gradle.table_merge  (extras, values)
					end
					
				end
				abi:ndk_extras("Debug")
				abi:ndk_extras("Release")
				
				self._appabis[name] = abi
			end
			return abi
		end
		
		function grd_prj:appabi_names()
			local ret = {}
			for k,v in pairs(self._appabis) do
				table.insert(ret, k)
			end
			return ret
		end
		
		grd_prj:appabi ("armeabi")

		-- plugins
		grd_prj._plugins = {}
		
		function grd_prj:plugins (values)
			return premake.gradle.table_merge  (self._plugins, values)
		end
		-- repositories
		grd_prj._repositories = {}
		function grd_prj:repositories (values)
			return premake.gradle.table_merge  (self._repositories, values)
		end
		-- dependencies
		grd_prj._dependencies = {}
		function grd_prj:dependencies (values)
			return premake.gradle.table_merge  (self._dependencies, values)
		end
		-- buildTypes
		grd_prj._buildTypes = {}
		function grd_prj:buildType (name)
			local btype = self._buildTypes[name]
			if nil == btype then
				btype = {
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
				self._buildTypes[name] = btype
			end
			return btype
		end

		local b_debug = grd_prj:buildType ("Debug")
		b_debug.debuggable = true
		b_debug.jniDebuggable = true
		b_debug.renderscriptDebuggable = true

		local b_release = grd_prj:buildType ("Release")
		b_release.zipAlignEnabled = true

		grd_prj.compileSdkVersion = 21
		grd_prj.buildToolsVersion = "21.1.2"
		grd_prj.versionName = "1.0.0"
		grd_prj.versionCode = 1901001 -- please follow the xxyyzzz convention stated in http://developer.android.com/google/play/publishing/multiple-apks.html
		grd_prj.minSdkVersion = 19 -- http://developer.android.com/google/play/publishing/multiple-apks.html
		grd_prj.targetSdkVersion = 19 -- http://developer.android.com/google/play/publishing/multiple-apks.html
		grd_prj.manifest = "AndroidManifest.xml"
		
		grd_prj._java_srcdirs = {}
		function grd_prj:java_srcdirs (values)
			return premake.gradle.table_merge  (self._java_srcdirs, values)
		end
		
		grd_prj._aidl_srcdirs = {}
		function grd_prj:aidl_srcdirs (values)
			return premake.gradle.table_merge  (self._aidl_srcdirs, values)
		end
		
		grd_prj._renderscript_srcdirs = {}
		function grd_prj:renderscript_srcdirs (values)
			return premake.gradle.table_merge  (self._renderscript_srcdirs, values)
		end
		
		grd_prj._res_srcdirs = {}
		function grd_prj:res_srcdirs (values)
			return premake.gradle.table_merge  (self._res_srcdirs, values)
		end
		
		grd_prj._assets_srcdirs = {}
		function grd_prj:assets_srcdirs (values)
			return premake.gradle.table_merge  (self._assets_srcdirs, values)
		end
		
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