local processpath = function (r, p)
	local absofp = p --path.getabsolute (path.join (r, p))
	local relofp = path.getrelative (r, absofp)
	-- print (r .. "; " .. absofp .. "; " .. relofp)
	return relofp
end

premake.gradle.generate_solution_settings_dot_gradle = function (sln)
	_p ("rootProject.name = 'solution_of_%s'", sln.name)
	
	for prj in premake.solution.eachproject (sln) do
		
		if premake.gradle.is_app_project (prj) then
			_p ("include '%s'", prj.name)
					
			for k, v in pairs (gradle:project (prj.name).externalprojects) do
				_p ("include '%s_%s'", prj.name, k)
				_p ("project (':%s_%s').projectDir = new File (rootDir, '%s')", prj.name, k, processpath (prj.solution.location, v))
			end
		end
	end
end

premake.gradle.generate_solution_support_dot_gradle = function (sln)

	local content = [[
def readLocalProp () {
	Properties properties = new Properties()
	properties.load(project.rootProject.file('local.properties').newDataInputStream())
	return properties
}
def buildFailed (reason) {
	logger.error (reason)
	throw new Exception (reason.toString())
}
def invokeNDKBuild (debuggable, cleaning) {
	def properties = readLocalProp()
	def ndkDir = properties.getProperty('ndk.dir')
	if (!ndkDir) {
		buildFailed ('\"ndk.dir\" is not set in local.properties')
		return false
	}
	def osName = System.getProperty('os.name').toLowerCase()
	def args = new ArrayList<String>()
	if (osName.contains ('windows')) {
		args.add('cmd')
		args.add('/c')
		args.add(ndkDir + '/ndk-build.cmd')
	}
	else {
		args.add(ndkDir + '/ndk-build')
	}

	args.add (debuggable ? 'NDK_DEBUG=1' : 'NDK_DEBUG=0')

	if (cleaning)
		args.add('clean')

	def jniPath = file(file('./jni').absolutePath + '/')
	
	
	def pb = new ProcessBuilder(args);
	pb.redirectErrorStream(true)
	pb.directory(jniPath)
	pb.environment().put ('NDK_MODULE_PATH', new File (rootDir, 'natives/jni/').absolutePath)
	def process = pb.start()

	def stdout = process.getInputStream()
	def reader = new BufferedReader(new InputStreamReader(stdout))

	def line
	while ((line = reader.readLine()) != null) {
		println line
	}

	if (0 != process.exitValue()) {
		buildFailed ('ndk-build failed')
		return false
	}

	return true
}

android.buildTypes.each { theBuildType ->
	def buildName = theBuildType.name.capitalize()
	task ("compile${buildName}Native") {
		doLast {
			invokeNDKBuild (theBuildType.debuggable, false)
		}
	}
	task ("clean${buildName}Native") {
		doLast {
			invokeNDKBuild (theBuildType.debuggable, true)
		}
	}
	clean.dependsOn ("clean${buildName}Native")
	tasks.whenTaskAdded{ theTask ->
		if(theTask.name == "compile${buildName}Ndk") {
			theTask.dependsOn("compile${buildName}Native")
		}
	}
}
]]
	_p (content)
end

premake.gradle.generate_solution_root_build_dot_gradle = function (sln)

	_p ("println (\"GRADLE VERSION : ${gradle.gradleVersion}\")")
	_p ("")
	
	_p ("buildscript {")
	_p ("    repositories {")
	_p ("        jcenter()")
	if #premake.gradle.buildscript._repositories > 0 then
		_p (table.implode (premake.gradle.buildscript._repositories, "        ", "", "\n"))
	end
	_p ("    }")
	_p ("    dependencies {")
	_p ("        classpath '%s'", premake.gradle.android_tools)
	if #premake.gradle.buildscript._dependencies > 0 then
		_p (table.implode (premake.gradle.buildscript._dependencies, "        ", "", "\n"))
	end
	_p ("    }")
	_p ("}")
	
	_p ("")
	_p ("allprojects")
	_p ("{")
	_p ("    buildDir = new File (rootProject.buildDir, name)")
	_p ("}")
end

premake.gradle.generate_project_app_build_dot_gradle = function (prj)

	local grd_prj = gradle:project (prj.name)
	
	local refpath = path.join (prj.solution.location, prj.name)
	
	local fmt_srcdirs = function (dirs)
		local ret = ""
		for _, p in ipairs (dirs) do
			ret = ret .. string.format ("'%s', ", processpath (refpath, p))
		end
		return ret
	end
	
	local process_buildtype = function (btype)
	
		_p ("        %s {", btype.name)
		_p ("            debuggable = %s", btype.debuggable)
		_p ("            jniDebuggable = %s", btype.jniDebuggable)
		_p ("            renderscriptDebuggable = %s", btype.renderscriptDebuggable)
		_p ("            renderscriptOptimLevel = %s", btype.renderscriptOptimLevel)
		
		if (nil ~= btype.applicationIdSuffix) then
		_p ("            applicationIdSuffix = %s", btype.applicationIdSuffix)
		end
		
		if (nil ~= btype.versionNameSuffix) then
		_p ("            versionNameSuffix = %s", btype.versionNameSuffix)
		end
		
		_p ("            zipAlignEnabled = %s", btype.zipAlignEnabled)
		_p ("            minifyEnabled = %s", btype.minifyEnabled)
		_p ("            shrinkResources = %s", btype.shrinkResources)
		
		if #btype.proguardFiles > 0 then
	
			local pattern = path.wildcards ("getDefaultProguardFile")
			_p ("            proguardFiles = [")
			
			for _, v in ipairs (btype.proguardFiles) do
				if string.find (v, pattern) then
					_p ("                %s,", v)
				else
					_p ("                %s,", processpath (refpath, v))
				end
			end
			_p ("            ]")
		end
		
		_p ("        }")
		
	end
	
	_p ("")
	_p ("apply plugin: 'com.android.application'")
	if #grd_prj._plugins > 0 then
		_p (table.implode (grd_prj._plugins, "apply plugin: '", "'", "\n"))
	end
	
	_p ("")
	_p ("repositories {")
	_p ("    jcenter()")
	if #grd_prj._repositories > 0 then
		_p (table.implode (grd_prj._repositories, "  ", "", "\n"))
	end
	_p ("}")
	
	_p ("")
	_p ("dependencies {")
	
	if #grd_prj._dependencies > 0 then
		_p (table.implode (grd_prj._dependencies, "    ", "", "\n"))
	end

	for k, v in pairs (grd_prj.externalprojects) do
		_p ("    compile project(':%s_%s')", prj.name, k)
	end
	
	if grd_prj.multiDexEnabled then
		_p ("    compile 'com.android.support:multidex:1.0.0'")
	end
	
	_p ("}")
	--end
	
	_p ("")
	_p ("android {")
	_p ("    compileSdkVersion %d", grd_prj.compileSdkVersion)
	_p ("    buildToolsVersion '%s'", grd_prj.buildToolsVersion)
	_p ("    defaultConfig {")
	_p ("        versionCode %d", grd_prj.versionCode)
	_p ("        versionName '%s'", grd_prj.versionName)
	_p ("        minSdkVersion %d", grd_prj.minSdkVersion)
	_p ("        targetSdkVersion %d", grd_prj.targetSdkVersion)
	_p ("        multiDexEnabled %s", grd_prj.multiDexEnabled)
	_p ("    }") -- defaultConfig
	
	_p ("    buildTypes {")
	for k, v in pairs(grd_prj._buildTypes) do
		process_buildtype (v)
	end
	_p ("    }")
	
	_p ("    sourceSets {")
	_p ("        main {")
	_p ("            jniLibs.srcDir './libs'")
	_p ("            jni.srcDirs = []")
	_p ("            manifest.srcFile '%s'", processpath (refpath, grd_prj.manifest))
	
	if #grd_prj._java_srcdirs > 0 then
		_p ("            java.srcDirs = [%s]", fmt_srcdirs (grd_prj._java_srcdirs))
	end
	--_p ("      resources.srcDirs = [%s]", "")
	
	if #grd_prj._aidl_srcdirs > 0 then
		_p ("            aidl.srcDirs = [%s]", fmt_srcdirs (grd_prj._aidl_srcdirs))
	end
	
	if #grd_prj._renderscript_srcdirs > 0 then
		_p ("            renderscript.srcDirs = [%s]", fmt_srcdirs (grd_prj._renderscript_srcdirs))
	end
	
	if #grd_prj._res_srcdirs > 0 then
		_p ("            res.srcDirs = [%s]", fmt_srcdirs (grd_prj._res_srcdirs))
	end
	
	if #grd_prj._assets_srcdirs > 0 then
		_p ("            assets.srcDirs = [%s]", fmt_srcdirs (grd_prj._assets_srcdirs))
	end
	
	_p ("        }") -- main
	_p ("    }") -- sourceSets
	_p ("}") -- android
	
	if grd_prj.splits.abi.enabled then
		_p ("android.splits {")
		_p ("    abi {")
		_p ("        enable true")
		_p ("        reset()")
		_p ("        universalApk false")
		_p ("        include " .. table.implode (grd_prj._appabis, "'", "'", ","))
		_p ("    }")
		_p ("}")
		
		_p ("import com.android.build.OutputFile")

		_p ("android.applicationVariants.all { variant ->")
		_p ("    variant.outputs.each { output ->")
		local codes = "        def codes = ["
		for k, v in ipairs (grd_prj._appabis) do
			codes = codes .. string.format ("'%s':%d, ", v, k)
		end
		codes = codes .. "]"
		_p (codes)
		_p ("        output.versionCodeOverride = android.defaultConfig.versionCode + codes.get (output.getFilter (OutputFile.ABI)) * " .. grd_prj.splits.versionCodeBase)
		_p ("    }")
		_p ("}")
	end
	
	_p ("apply from : new File (rootDir, 'support.gradle')")
	
	if #grd_prj._extras ~= '' then
		_p (table.concat (grd_prj._extras, "\n"))
	end
end
