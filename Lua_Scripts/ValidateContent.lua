--This script validates that all the JSON files in the Engine-Documentation directory follow the data structure defined in the specification.
--Specification Implemented: 2019-11-17-Specification.md

--Code author: Rami Sabbagh (RamiLego4Game)

--Extend the package path so it search for the modules in the special directory.
package.path = "./Lua_Scripts/Modules/?.lua;./Lua_Scripts/Modules/?/init.lua;"..package.path

local startClock = os.clock()

--Load ANSI module
if not pcall(require,"ANSI") then print("\27[0;1;31mCould not load the ANSI module, please make sure that the script is executed with the repository being the working directory!\27[0;1;37m") os.exit(1) return end
local ANSI = require("ANSI")

--== Shared functions ==--

local function fail(...)
	local reason = {...}
	for k,v in pairs(reason) do reason[k] = tostring(v) end
	reason = table.concat(reason, " ")
	ANSI.setGraphicsMode(0, 1, 31) --Red output
	print(reason)
	ANSI.setGraphicsMode(0, 1, 37) --White output
	os.exit(1)
end

--== Load external modules ==--

if not pcall(require,"lfs") then fail("Could not load luafilesystem, please make sure it's installed using luarocks first!") end
local lfs = require("lfs")
if not pcall(require, "JSON") then fail("Could not load JSON module, please make sure that the script is executed with the repository being the working directory!") end
local JSON = require("JSON")

--== Validate the files content ==--

ANSI.setGraphicsMode(0, 37) --Light grey output
print("")
print("Documentation files content validation script (ValidateContent.lua) by Rami Sabbagh (RamiLego4Game)")
print("Using specification 2019-11-17")
print("")

ANSI.setGraphicsMode(0, 1, 34) --Blue output
print("Validating the files content.")
print("")

--== Validate Engine_Documentation ==--

local simpleTypes = {"number", "string", "boolean", "nil", "table", "userdata", "function"}
for k,v in ipairs(simpleTypes) do simpleTypes[v] = k end

--Returns true if the type was valid, false otherwise, with reason followed
local function validateType(vtype)
	if type(vtype) == "string" then
		--Check if it's the any type
		if vtype == "any" then return true end

		--Check if it's a simple type
		if simpleTypes[vtype] then return true end

		--Otherwise it's an invalid type
		return false, "Invalid simple type: "..vtype.."!" end

	elseif type(vtype) == "table" then
		local l1 = #vtype
		if l1 == 0 then return false, "The type as a table of types must not be empty!" end
		for k1, v1 in pairs(vtype) do
			if type(k1) ~= "number" or k1 > l1 or k1 < 1 then return false, "The type as a table of types can be only an array of continuous values!" end

			if type(v1) == "string" then
				if v1 == "any" then return false, "The \"any\" type can't be used in a table of types!" end
				if not simpleTypes[v1] then return false, "Invalid simple type: "..vtype.."!" end

			elseif type(v1) == "table" then --Complex type
				--Make sure that it's a valid array
				local l2 = #v1
				if l2 == 0 then return false, "The complex type in the table of types at index #"..k1.." must not be an empty array!" end
				for k2, v2 in pairs(v1) do
					if type(k2) ~= "number" or k2 > l2 or k2 < 1 then return false, "The complex type in the table of types at index #"..k1..": can be only an array of continuous values!" end
					if type(v2) ~= "string" then return false, "The complex type in the table of types at index #"..k1..": has a non-string value!" end
				end

				--Make sure that it's a valid path
				local complexPath = table.concat(v1, "/") .. "/" .. v1[l2] .. ".json"
				if l2 < 2 or v1[l1-1] ~= "objects" or not isFile(complexPath) then return false, "Invalid object path for the complex type in the table of types at index #"..k1.."!" end
			else
				return false, "Invalid type of a type value in the types table at index #"..k1..": "..type(v1)..", it can be only a string or a table!"
			end
		end

		return true --Validated successfully
	else
		return false, "Invalid type of the type value: "..type(vtype)..", it can be only a string or a table!"
	end
end

--== The end of the script ==--

local endClock = os.clock()
local executionTime = endClock - startClock

ANSI.setGraphicsMode(0, 1, 32) --Green output
print("")
print("The documentation files content has been validated successfully in "..executionTime.."s.")
print("")

ANSI.setGraphicsMode(0, 1, 37) --White output