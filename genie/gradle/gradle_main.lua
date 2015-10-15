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
-- android_tools (e.g. "com.android.tools.build:gradle:1.3.0")
--
premake.gradle.android_tools = "com.android.tools.build:gradle:1.3.0"

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
		
		grd_prj._ndk_extras = {}
		function grd_prj:ndk_extras (values)
			return premake.gradle.table_merge  (self._ndk_extras, values)
		end
		
		grd_prj._appabis = {}
		function grd_prj:appabis (values)
			return premake.gradle.table_merge  (self._appabis, values)
		end
		
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
			local btype_key = string.lower (name)
			local btype = self._buildTypes[btype_key]
			if nil == btype then
				btype = {
					name = name,
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
				-- ndk_extras
				btype._ndk_extras = {}
				
				function btype:ndk_extras (abi, values)
					local abi_key = string.lower (abi)
					local extras = self._ndk_extras[abi_key]
					if extras == nil then
						extras = {}
						self._ndk_extras[abi_key] = extras
					end
					return premake.gradle.table_merge (extras, values)
				end
				
				function btype:get_ndk_extras (abi)
					--print ("btype " .. self.name .. " get_ndk_extras(" .. abi .. ")")
					local extras = {}
					for k, v in pairs (self._ndk_extras) do
						if premake.gradle.match_wildcard (abi, k) then
							premake.gradle.table_merge (extras, v)
						end
					end
					return extras
				end
				
				self._buildTypes[btype_key] = btype
			end
			return btype
		end

		local b_debug = grd_prj:buildType ("debug")
		b_debug.debuggable = true
		b_debug.jniDebuggable = true
		b_debug.renderscriptDebuggable = true

		local b_release = grd_prj:buildType ("release")
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

		grd_prj._extras = {}
		function grd_prj:extras (values)
			return premake.gradle.table_merge  (self._extras, values)
		end
		
		self.projects[prjname] = grd_prj
	end
	
	return grd_prj
end