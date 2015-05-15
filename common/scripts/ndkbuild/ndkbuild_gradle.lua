
premake.ndkbuild.gradle = {}
premake.ndkbuild.gradle.buildscript = {}
premake.ndkbuild.gradle.buildscript.repositories = {}
premake.ndkbuild.gradle.buildscript.dependencies = {}

premake.ndkbuild.gradle.plugins = {}
premake.ndkbuild.gradle.repositories = {}
premake.ndkbuild.gradle.dependencies = {}

premake.ndkbuild.gradle.compileSdkVersion = 21
premake.ndkbuild.gradle.buildToolsVersion = '21.1.2'
premake.ndkbuild.gradle.versionName = "1.0.0"
premake.ndkbuild.gradle.versionCode = 1901001 -- please follow the xxyyzzz convention stated in http://developer.android.com/google/play/publishing/multiple-apks.html
premake.ndkbuild.gradle.minSdkVersion = 19 -- http://developer.android.com/google/play/publishing/multiple-apks.html
premake.ndkbuild.gradle.targetSdkVersion = 19 -- http://developer.android.com/google/play/publishing/multiple-apks.html
premake.ndkbuild.gradle.manifest = "AndroidManifest.xml"
premake.ndkbuild.gradle.java_srcdirs = {}
premake.ndkbuild.gradle.aidl_srcdirs = {}
premake.ndkbuild.gradle.renderscript_srcdirs = {}
premake.ndkbuild.gradle.res_srcdirs = {}
premake.ndkbuild.gradle.assets_srcdirs = {}
premake.ndkbuild.gradle.externalprojects = {}

-- http://tools.android.com/tech-docs/new-build-system/user-guide/apk-splits
premake.ndkbuild.gradle.splits = {}
premake.ndkbuild.gradle.splits.abi = {}
premake.ndkbuild.gradle.splits.abi.enabled = true
premake.ndkbuild.gradle.splits.versionCodeBase = 10000000 -- for abi splits

premake.ndkbuild.gradle.extra = ""

function ndkbuild_gradle ()
	return premake.ndkbuild.gradle
end

function processpath (r, p)
	local absofp = p --path.getabsolute (path.join (r, p))
	local relofp = path.getrelative (r, absofp)
	-- print (r .. "; " .. absofp .. "; " .. relofp)
	return relofp
end

premake.ndkbuild.generate_solution_settings_dot_gradle = function (sln)
	_p (string.format ("rootProject.name = '%s'", sln.name))
	
	for k, v in pairs (premake.ndkbuild.gradle.externalprojects) do
		_p (string.format ("include '%s'", k))
		_p (string.format ("project (':%s').projectDir = new File (settingsDir, '%s')", k, processpath (sln.location, v)))
	end
	
end

premake.ndkbuild.generate_solution_support_dot_gradle = function (sln)

	local content = [[
def readLocalProp () {
	Properties properties = new Properties()
	properties.load(project.rootProject.file('local.properties').newDataInputStream())
	return properties
}
def invokeNDKBuild (debuggable, cleaning) {
	def properties = readLocalProp()
	def ndkDir = properties.getProperty('ndk.dir')
    if (!ndkDir) {
	    logger.error ('\"ndk.dir\" is not set in local.properties')
		return false
	}
	def osName = System.getProperty('os.name').toLowerCase()
	def args = new ArrayList<List>()
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

	def jniPath = file(file('jni/').absolutePath + '/')

	def pb = new ProcessBuilder(args);
	pb.redirectErrorStream(true)
	pb.directory(jniPath)
	def process = pb.start()

	def stdout = process.getInputStream()
	def reader = new BufferedReader(new InputStreamReader(stdout))

	def line
	while ((line = reader.readLine()) != null) {
		println line
	}

	if (0 != process.exitValue())
		return false

	return true
}

android.buildTypes.each { theBuildType ->
	def buildName = theBuildType.name.capitalize()
	task ("compile${buildName}Native") {
		doLast {
			if (!invokeNDKBuild (theBuildType.debuggable, false))
				throw new StopExecutionException()
		}
	}
	task ("clean${buildName}Native") {
		doLast {
			if (!invokeNDKBuild (theBuildType.debuggable, true))
				throw new StopExecutionException()
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

premake.ndkbuild.generate_solution_build_dot_gradle = function (sln)

	local refpath = sln.location
	
	function fmt_srcdirs (dirs)
		local ret = ""
		for _, p in ipairs (dirs) do
			ret = ret .. string.format ("'%s', ", processpath (refpath, p))
		end
		return ret
	end
	
	_p ("buildscript {")
	_p ("  repositories {")
	_p ("    jcenter()")
	if #premake.ndkbuild.gradle.buildscript.repositories > 0 then
		_p (table.implode (premake.ndkbuild.gradle.buildscript.repositories, "    ", "", "\n"))
	end
	_p ("  }")
	_p ("  dependencies {")
	_p ("    classpath 'com.android.tools.build:gradle:1.1.0'")
	if #premake.ndkbuild.gradle.buildscript.dependencies > 0 then
		_p (table.implode (premake.ndkbuild.gradle.buildscript.dependencies, "    ", "", "\n"))
	end
	_p ("  }")
	_p ("}")
	
	_p ("")
	_p ("apply plugin: 'com.android.application'")
	if #premake.ndkbuild.gradle.plugins > 0 then
		_p (table.implode (premake.ndkbuild.gradle.plugins, "apply plugin: '", "'", "\n"))
	end
	
	_p ("allprojects")
	_p ("{")
	_p ("  buildDir = new File (rootProject.buildDir, name)")
	_p ("}")
	
	_p ("")
	_p ("repositories {")
	_p ("  jcenter()")
	if #premake.ndkbuild.gradle.repositories > 0 then
		_p (table.implode (premake.ndkbuild.gradle.repositories, "  ", "", "\n"))
	end
	_p ("}")
	
	if #premake.ndkbuild.gradle.dependencies > 0 then
		_p ("")
		_p ("dependencies {")
		_p (table.implode (premake.ndkbuild.gradle.dependencies, "  ", "", "\n"))
		_p ("}")
	end
	
	--if #premake.ndkbuild.gradle.externalprojects > 0 then
		_p ("")
		_p ("dependencies {")
		for k, v in pairs (premake.ndkbuild.gradle.externalprojects) do
			_p (string.format ("  compile project(':%s')", k))
		end
		_p ("}")
	--end
	
	_p ("")
	_p ("android {")
	_p (string.format ("  compileSdkVersion %d", premake.ndkbuild.gradle.compileSdkVersion))
	_p (string.format ("  buildToolsVersion '%s'", premake.ndkbuild.gradle.buildToolsVersion))
	_p ("  defaultConfig {")
	_p (string.format ("    versionCode %d", premake.ndkbuild.gradle.versionCode))
	_p (string.format ("    versionName '%s'", premake.ndkbuild.gradle.versionName))
	_p (string.format ("    minSdkVersion %d", premake.ndkbuild.gradle.minSdkVersion))
	_p (string.format ("    targetSdkVersion %d", premake.ndkbuild.gradle.targetSdkVersion))
	_p ("  }") -- defaultConfig
	_p ("  sourceSets {")
	_p ("    main {")
	_p ("      jniLibs.srcDir './libs'")
	_p ("      jni.srcDirs = []")
	_p (string.format ("      manifest.srcFile '%s'", processpath (refpath, premake.ndkbuild.gradle.manifest)))
	
	if #premake.ndkbuild.gradle.java_srcdirs > 0 then
		_p (string.format ("      java.srcDirs = [%s]", fmt_srcdirs (premake.ndkbuild.gradle.java_srcdirs)))
	end
	--_p (string.format ("      resources.srcDirs = [%s]", ""))
	
	if #premake.ndkbuild.gradle.aidl_srcdirs > 0 then
		_p (string.format ("      aidl.srcDirs = [%s]", fmt_srcdirs (premake.ndkbuild.gradle.aidl_srcdirs)))
	end
	
	if #premake.ndkbuild.gradle.renderscript_srcdirs > 0 then
		_p (string.format ("      renderscript.srcDirs = [%s]", fmt_srcdirs (premake.ndkbuild.gradle.renderscript_srcdirs)))
	end
	
	if #premake.ndkbuild.gradle.res_srcdirs > 0 then
		_p (string.format ("      res.srcDirs = [%s]", fmt_srcdirs (premake.ndkbuild.gradle.res_srcdirs)))
	end
	
	if #premake.ndkbuild.gradle.assets_srcdirs > 0 then
		_p (string.format ("      assets.srcDirs = [%s]", fmt_srcdirs (premake.ndkbuild.gradle.assets_srcdirs)))
	end
	
	_p ("    }") -- main
	_p ("  }") -- sourceSets
	_p ("}") -- android
	
	if premake.ndkbuild.gradle.splits.abi.enabled then
		_p ("android.splits {")
		_p ("  abi {")
		_p ("    enable true")
		_p ("    reset()")
		_p ("    universalApk false")
		_p ("    include " .. table.implode (premake.ndkbuild.appabi, "'", "'", ","))
		_p ("  }")
		_p ("}")
		
		_p ("import com.android.build.OutputFile")

		_p ("android.applicationVariants.all { variant ->")
       _p ("  variant.outputs.each { output ->")
		local codes = "    def codes = ["
		for k, v in ipairs (premake.ndkbuild.appabi) do
			codes = codes .. string.format ("'%s':%d, ", v, k)
		end
		codes = codes .. "]"
		_p (codes)
		_p ("    output.versionCodeOverride = android.defaultConfig.versionCode + codes.get (output.getFilter (OutputFile.ABI)) * " .. premake.ndkbuild.gradle.splits.versionCodeBase)
		_p ("  }")
		_p ("}")		
	end
	
	_p ("apply from : 'support.gradle'")
	
	if premake.ndkbuild.gradle.extra and premake.ndkbuild.gradle.extra ~= '' then
		_p (premake.ndkbuild.gradle.extra)
	end
end
