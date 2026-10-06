--!strict
--==============================================================
-- MiEnum Module
-- Author: Mimir
-- Created: 2026
-- Version: 0.1.4-rc.1
-- MIT License
--==============================================================
const Typedef = require("@self/Typedef")
export type Enum<T> = Typedef.Enum<T>
export type EnumItem<T> = Typedef.EnumItem<T>
type EnumInternal<T> = Typedef.EnumInternal<T>

const keyWords = {
	"Count",
	"GetEnumItems",
	"FromName",
	"FromValue",
	"IsEnumItem",
	"_Name",
}
---- Metatables ----
const itemMt: Typedef.EnumItemMt<{ any }> = {
	__tostring = function(self)
		return `{self.EnumType}.{self.Name}`
	end,
	__concat = function(self, value)
		return `{self}{value}`
	end,
}

const enumMt: Typedef.EnumMt<{ any }> = {
	__tostring = function(self)
		return self._Name
	end,
	__concat = function(self, value)
		return `{self}{value}`
	end,
	__newindex = function(self)
		error("Cannot modify enum", 0)
	end,
}

---- Functions ----

const function AssertDefinitionTable(definitionTable: { [string]: number }, level: number)
	if typeof(definitionTable) ~= "table" then
		error(`Invalid argument #2 (table expected, got {typeof(definitionTable)})`, level)
	end
	const values = {}
	for key, value in definitionTable do
		if typeof(key) ~= "string" then
			error(`Invalid argument #2 (string key expected, got {typeof(key)})`, level)
		end
		if table.find(keyWords, key) then
			error(`Invalid argument #2 (reserved word {key})`, level)
		end
		if typeof(value) ~= "number" then
			error(`Invalid argument #2 (number value expected, got {typeof(value)})`, level)
		end
		if table.find(values, value) then
			error(`Invalid argument #2 (duplicate value {value})`, level)
		end
		table.insert(values, value)
	end
end

const function CreateEnumItem<T>(name: string, value: number, enum: Enum<T>): EnumItem<T>
	return table.freeze(setmetatable({
		Name = name,
		Value = value,
		EnumType = enum,
	}, itemMt))
end

const function IsEnumItem<T>(self: EnumInternal<T>, item: EnumItem<T>)
	if typeof(item) == "table" then
		const EnumType = item.EnumType
		return EnumType and EnumType == self
	end
	return false
end

const function FromName<T>(self: EnumInternal<T>, name: string)
	return self._NameToItem[name]
end

const function FromValue<T>(self: EnumInternal<T>, value: number)
	return self._ValueToItem[value]
end

const function GetEnumItems<T>(self: EnumInternal<T>)
	return self._ValueToItem
end

const function CreateEnum<T>(name: string, definitions: T & { [string]: number }, callerLevel: number?): Enum<T>
	const lvl = callerLevel or 2

	if typeof(name) ~= "string" then
		error(`Invalid argument #1 (string expected, got {typeof(name)})`, lvl)
	end

	AssertDefinitionTable(definitions, lvl + 1)

	local count = 0

	for key, value in pairs(definitions) do
		count += 1
	end

	const Enum: EnumInternal<T> = setmetatable({
		_Name = name,
		_ValueToItem = {},
		_NameToItem = {},

		Count = count,
		IsEnumItem = IsEnumItem,
		FromName = FromName,
		FromValue = FromValue,
		GetEnumItems = GetEnumItems,
	}, enumMt) :: any

	for key, value in pairs(definitions) do
		const enumItem = CreateEnumItem(key, value, Enum)
		Enum._ValueToItem[value] = enumItem
		Enum._NameToItem[key] = enumItem
		Enum[key] = enumItem
	end

	return Enum
end

---- MiEnum ----
const MiEnum = {}
const ScopeNames: { string } = {}

function MiEnum.NewScope(scopeName: string)
	if typeof(scopeName) ~= "string" then
		error(`Invalid argument #1 (string expected, got {typeof(scopeName)})`, 2)
	end

	if table.find(ScopeNames, scopeName) then
		error(`Scope {scopeName} already exists`, 2)
	end

	table.insert(ScopeNames, scopeName)

	const scope = {}
	const CreatedEnums: { [string]: Enum<{ any }> } = {}

	function scope.CreateEnum<T>(name: string)
		if CreatedEnums[name] then
			error(`Enum {name} already exists in scope {scopeName}`, 2)
		end

		return function<T>(definitions: T): Enum<T>
			const enum = CreateEnum(name, definitions, 3)
			CreatedEnums[name] = enum
			return enum
		end
	end

	return scope
end

MiEnum.NewEnum = function(name: string)
	return function(definition)
		return CreateEnum(name, definition, 3)
	end
end

return MiEnum
