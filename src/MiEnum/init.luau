--!strict
--==============================================================
-- MiEnum Module
-- Author: Mimir (Roblox: mounirgue)
-- Created: 2026
-- Version: 2.0.0
-- MIT License
--==============================================================
local Typedef = require(script.Typedef)
type Enum<T> = Typedef.Enum<T>
type EnumItem<T> = Typedef.EnumItem<T>

local keyWords = {
	"Count","GetEnumItems","FromName","FromValue","IsEnumItem","_Name"
}
---- Metatables ----
local itemMt: Typedef.EnumItemMt<{any}> = {
	__tostring = function(self)
		return `{self.EnumType}.{self.Name}`
	end,
	__concat = function(self,value)
		return `{self}{value}`
	end,
}

local enumMt: Typedef.EnumMt<{any}> = {
	__tostring = function(self)
		return self._Name
	end,
	__concat = function(self,value)
		return `{self}{value}`
	end,
	__newindex = function(self)
		error("Cannot modify enum",0)
	end,
}

---- Functions ----
local function AssertDefinitionTable(definitionTable: {[string]: number}, level: number)
	if typeof(definitionTable) ~= "table" then
		error(`Invalid argument #2 (table expected, got {typeof(definitionTable)})`, level)
	end
	local values = {}
	for key, value in definitionTable do
		if typeof(key) ~= "string" then error(`Invalid argument #2 (string key expected, got {typeof(key)})`, level) end
		if table.find(keyWords, key) then error(`Invalid argument #2 (reserved word {key})`, level) end
		if typeof(value) ~= "number" then error(`Invalid argument #2 (number value expected, got {typeof(value)})`, level) end
		if table.find(values, value) then error(`Invalid argument #2 (duplicate value {value})`, level) end
		table.insert(values, value)
	end
end

local function CreateEnumItem<T>(name: string, value: number, enum: Enum<T>): EnumItem<T>
	return table.freeze(setmetatable({
		Name = name,
		Value = value,
		EnumType = enum,
	}, itemMt))
end

local function CreateEnum<T>(name: string, definitions: T, callerLevel: number?): Enum<T>
	local lvl = callerLevel or 2
	if typeof(name) ~= "string" then
		error(`Invalid argument #1 (string expected, got {typeof(name)})`, lvl)
	end
	AssertDefinitionTable(definitions :: any, lvl + 1)
	local valueToItem: {[number]: EnumItem<T>} = {}
	local nameToItem: {[string]: EnumItem<T>} = {}
	local Enum = {} :: Typedef.EnumInternal<T>

	Enum._Name = name
	Enum.Count = 0
	for key, value in definitions :: any do
		local enumItem = CreateEnumItem(key, value, Enum)
		valueToItem[value] = enumItem
		nameToItem[key] = enumItem
		Enum[key] = enumItem
		Enum.Count += 1
	end
	table.freeze(valueToItem)
	table.freeze(nameToItem)
	function Enum:IsEnumItem(item)
		if typeof(item) == "table" then
			local EnumType = item.EnumType
			return EnumType and EnumType == Enum
		end
		return false
	end
	function Enum:GetEnumItems() return valueToItem end
	function Enum:FromName(n: string) return nameToItem[n] end
	function Enum:FromValue(v: number) return valueToItem[v] end
	return setmetatable(Enum, enumMt)
end

---- MiEnum ----
local MiEnum = {}
local ScopeNames: {string} = {}

function MiEnum.NewScope(scopeName: string)
	if typeof(scopeName) ~= "string" then
		error(`Invalid argument #1 (string expected, got {typeof(scopeName)})`, 2)
	end
	if table.find(ScopeNames, scopeName) then
		error(`Scope {scopeName} already exists`, 2)
	end
	table.insert(ScopeNames, scopeName)

	local scope = {}
	local CreatedEnums: {[string]: Enum<{any}>} = {}

	function scope.CreateEnum<T>(name: string, definitions: T): Enum<T>
		if CreatedEnums[name] then
			error(`Enum {name} already exists in scope {scopeName}`, 2)
		end

		local enum = CreateEnum(name, definitions, 3)
		CreatedEnums[name] = enum
		return enum
	end

	return scope
end

MiEnum.CreatePrivateEnum = CreateEnum
return MiEnum