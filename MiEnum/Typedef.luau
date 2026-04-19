--!strict
-- Version 2.0.0
export type EnumMt<T> = {
	__tostring : (self : EnumInternal<T>) -> string,
	__concat : (self : EnumInternal<T>,value : string) -> string,
	__newindex : (self : EnumInternal<T>) -> nil,
}

export type Enum<T> = setmetatable<{
	Count: number,
	IsEnumItem : (self : Enum<T>,item : any) -> boolean,
	GetEnumItems : (self : Enum<T>) -> {EnumItem<T>},
	FromName : (self : Enum<T>,_ : string) -> EnumItem<T>?,
	FromValue : (self : Enum<T>,_ : number) -> EnumItem<T>?,
} &  {[keyof<T>]: EnumItem<T>},EnumMt<T>>

export type EnumInternal<T> = Enum<T> & {
	_Name : string
}

export type EnumItemMt<T> = {
	__tostring : (self : EnumItemInternal<T>) -> string,
	__concat : (self : EnumItemInternal<T>,value : string) -> string,
}

export type EnumItem<T> = setmetatable<{
	read Name: string,
	read Value: number,
	read EnumType : Enum<T>,
},EnumItemMt<T>>

export type EnumItemInternal<T> = EnumItem<T> & {
	_EnumName : string
}

return {}