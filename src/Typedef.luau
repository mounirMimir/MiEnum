--!strict
-- Version 0.1.4-rc.1
export type EnumMt<T> = {
	read __tostring: (self: EnumInternal<T>) -> string,
	read __concat: (self: EnumInternal<T>, value: string) -> string,
	read __newindex: (self: EnumInternal<T>) -> nil,
}

export type Enum<T> = setmetatable<{
	read Count: number,
	read IsEnumItem: (self: Enum<T>, item: EnumItemMt<T>) -> boolean,
	read GetEnumItems: (self: Enum<T>) -> {EnumItem<T>},
	read FromName: (self: Enum<T>, _: string) -> EnumItem<T>?,
	read FromValue: (self: Enum<T>, _: number) -> EnumItem<T>?,
	read [keyof<T>]: EnumItem<T>
}, EnumMt<T> >

export type EnumInternal<T> = {
	read _Name: string,
	read _ValueToItem: {[number]: EnumItem<T>},
	read _NameToItem: {[string]: EnumItem<T>}
} & Enum<T>

export type EnumItemMt<T> = {
	read __tostring: (self: EnumItem<T>) -> string,
	read __concat: (self: EnumItem<T>, value: string) -> string,
}

export type EnumItem<T> = setmetatable<{
	read Name: string,
	read Value: number,
	read EnumType: Enum<T>,
},EnumItemMt<T>>

return {}