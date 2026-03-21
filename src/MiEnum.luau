--!strict
--==============================================================
-- MiEnum Module
-- Author: Mimir (Roblox: mounirgue)
-- Created: 2026
-- Version: 1.0.0
-- MIT License
--==============================================================
local MiEnumType = require("@self/Typedef")

local keyWords = {
	"Count","IsValid","GetEnumItems","FromName","FromValue","IsEnumItem"
}

local alreadyTakenEnumNames = {}
---- Functions ----

local function CreateEnumItem<T>(name : string, value : number,enum : MiEnum<T>) : MiEnumItem<T>
	local itemMt : MiEnumType.ItemMt<T> = {
		__tostring = function()
			return tostring(enum).."."..name
		end,
	}
	
	local enumItem ={
		Name = name,
		Value = value,
		EnumType = enum,
	}
	
	setmetatable(enumItem,itemMt)
	
	return table.freeze(enumItem)
end


---- Types ----
export type MiEnum<T> = MiEnumType.EnumType<T>
export type MiEnumItem<T> = MiEnumType.MiEnumItem<T>

local MiEnum = {}
MiEnum.__Version = "1.0.0"

local ModMt = {
	__tostring = function()
		return "MiEnum | Version: "..MiEnum.__Version..", Author: Mimir (@mounirgue)"
	end,
}

setmetatable(MiEnum, ModMt)

function MiEnum.CreateEnum<T>(name : string, definitions : T): MiEnum<T>
	assert(typeof(name) == "string","Enum name must be a string")
	assert(not table.find(alreadyTakenEnumNames,name),"Enum name already taken, Name in question: ".."'"..name.."'")
	assert(typeof(definitions) == "table","Definitions must be a table with string or numbered indices errored for "..name)
	

	local Enum = {} :: MiEnum<T>
	local valueToEnumItem : {[number] : MiEnumItem<T>} = {}
	local keyToEnumItem : {[string] : MiEnumItem<T>} = {}
	
	local takenValues : {number} = {}
	local takenKeys : {string} = {}
	
	local count = 0
	local nextAutoValue = 0
	
	for keyName, value in pairs(definitions) do
		count += 1
		assert(typeof(keyName) == "string", "Enum key must be a string, got "..typeof(keyName).." in "..name)
		assert(typeof(value) == "number", "Enum value must be a number, got "..typeof(value).." for key "..keyName.." in "..name)
		assert(value % 1 == 0, "Enum values must be whole numbers for "..keyName.." in "..name)
		assert(value >= 0, "Enum values must be positive for "..keyName.." in "..name)

		assert(not table.find(keyWords,keyName), "Reserved words cannot be used as keys errored for "..name)
		assert(not table.find(takenKeys, keyName), "Enum key already taken for "..name.." key: "..keyName)
		assert(not table.find(takenValues, value), "Enum value already taken for "..name.." value: "..tostring(value))

		table.insert(takenKeys, keyName)
		table.insert(takenValues, value)
		
		local enumItem = CreateEnumItem(keyName,value,Enum)
		keyToEnumItem[keyName] = enumItem
		valueToEnumItem[value] = enumItem
	end

	
	table.clear(takenValues)
	table.clear(takenKeys)
	takenValues = nil :: never
	takenKeys = nil :: never
	
	assert(count > 0,"Enum must have at least one entry errored for "..name)
	
	table.insert(alreadyTakenEnumNames,name)
	
	for key,value in pairs(keyToEnumItem) do
		Enum[key :: keyof<T>] = value
	end

	Enum.Count = count
	
	function Enum.IsEnumItem(self : MiEnum<T>,item : MiEnumItem<T>) : boolean
		return getmetatable(item.EnumType) == getmetatable(self)
	end
	
	function Enum.IsValid(self,key : string | number) : boolean
		if typeof(key) == "string" then
			return keyToEnumItem[key] ~= nil
		elseif typeof(key) == "number" then
			return valueToEnumItem[key] ~= nil
		end
		error("Passed "..typeof(key).." expected ".."string or number")
	end
	
	function Enum.GetEnumItems(self)
		local temp = {}
		for _, enumItem in pairs(keyToEnumItem) do
			table.insert(temp,enumItem)
		end
		return temp
	end
	
	function Enum.FromName(self, value : string) 
		return keyToEnumItem[value]
	end
	
	function Enum.FromValue(self, value : number) 
		return valueToEnumItem[value]
	end
	
	local mt : MiEnumType.TypeMt<T> = {
		__tostring = function()
			return "MiEnum."..name
		end,
	}

	setmetatable(Enum,mt)
	
	return table.freeze(Enum)
end

return MiEnum
