
premake.gradle.ndk = {}
premake.gradle.ndk.appabiextra = {}
premake.gradle.ndk.appstl = "gnustl_shared"
premake.gradle.ndk.appplatform = "android-12"
premake.gradle.ndk.ld_gold = {}
premake.gradle.ndk.ld_gold.enable = false
premake.gradle.ndk.ld_gold.multithread = false

-- Set extra lines for specific ABIs of the current project's Android.mk
-- Example:
-- project ("mylib")
-- premake.gradle.ndk.appabiextra ("armeabi-v7a", "Debug", {
--	  "	LOCAL_ARM_NEON := true"
-- })
--
premake.gradle.ndk.appabiextra.add = function (abi, cfg, extra)
	local prj = project().name
	premake.gradle.ndk.appabiextra[string.format ("%s,%s,%s", prj, abi, cfg)] = extra
end

premake.gradle.ndk.appabiextra.get = function (prj, abi, cfg)
	
	local extras = {}
	
	function matching (s, w)
		local p = path.wildcards (w)
		
		if p == w then
			-- not using wildcards
			return s == p
		else
			-- using wildcards
			return string.find (s, p) ~= nil
		end
		
	end
	
	for k, v in pairs (premake.gradle.ndk.appabiextra) do
	
		if type(v) ~= "function" then
			local info = string.explode (k, ",")
			
			local k_prj = info[1]
			local k_abi = info[2]
			local k_cfg = info[3]
			
			if (k_prj == prj) then
				if matching (abi, k_abi) and matching (cfg, k_cfg) then
					for _, ext in ipairs (v) do
						table.insert (extras, ext)
					end
				end
			end
		end
	end
	
	return extras
end

