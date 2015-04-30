local MIX_COMMON_DIR = path.getabsolute ("../../common")
local PROJECT_DIR = path.getabsolute ("../src")

solution "example-app"
	dofile (path.join (MIX_COMMON_DIR, "scripts/setup.lua"))

	mix_project_app "example-app"
		files {
			path.join (PROJECT_DIR, "entry.cpp")
		}
		links {
			"bgfx-static",
		}
	--defines ({"TEST_COMMON=1", "TEST_APP=1"})