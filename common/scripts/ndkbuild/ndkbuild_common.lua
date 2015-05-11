
premake.ndkbuild.appabi = {"armeabi", "armeabi-v7a", "x86", "mips"}
premake.ndkbuild.appabiextra = {}
premake.ndkbuild.appstl = "gnustl_shared"
premake.ndkbuild.appplatform = "android-12"


-- Assign the APP_ABI in Application.mk
-- Example:
-- ndkbuild_appabi {"armeabi", "armeabi-v7a", "x86", "mips"}
--
function ndkbuild_appabi (abi)
	premake.ndkbuild.appabi = abi
end


function ndkbuild_keyof (prj, abi, cfg)
	--return (prj .. abi) .. cfg 
	return string.format ("%s,%s,%s", prj, abi, cfg)
end

-- Set extra lines for specific ABIs of the current project's Android.mk
-- Example:
-- project ("mylib")
-- ndkbuild_appabiextra ("armeabi-v7a", "Debug", {
--	  "	LOCAL_ARM_NEON := true"
-- })
--
function ndkbuild_appabiextra (abi, cfg, extra)
	local prj = project().name
	premake.ndkbuild.appabiextra[ndkbuild_keyof (prj, abi, cfg)] = extra
end

function ndkbuild_retrieve_appabiextra (prj, abi, cfg)
	
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
	
	for k, v in pairs (premake.ndkbuild.appabiextra) do
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
	
	return extras
end

--
-- Example: ndkbuild_appstl "gnustl_shared"
--
function ndkbuild_appstl (stl)
	premake.ndkbuild.appstl = stl
end

--
-- Example: ndkbuild_appplatform "android-12"
--
function ndkbuild_appplatform (stl)
	premake.ndkbuild.appplatform = stl
end

