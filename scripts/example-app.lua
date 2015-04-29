local PRJ_DIR = path.getabsolute ("../src/example-app")
local PRJ_NAME = "sample-app"


project (PRJ_NAME)
	uuid (os.uuid(PRJ_NAME))
	kind ("ConsoleApp")
	files (path.join (PRJ_DIR, "entry.cpp"))
	links ({
		"bgfx",
	})
	--defines ({"TEST_COMMON=1", "TEST_APP=1"})
	
	