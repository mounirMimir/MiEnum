-- Version 1.0.1
export type TypeMt<T> = {
	__tostring : (self : EnumTypeInternal<T>) -> string,
	__concat : (self : EnumTypeInternal<T>,value : string) -> string,
	__newindex : () -> nil,
}

export type EnumType<T> = setmetatable<{
	Count: number,
	IsEnumItem : (self : EnumType<T>,item : any) -> boolean,
	IsValid: (self : EnumType<T> ,key: string | number) -> boolean,
	GetEnumItems : (self : EnumType<T>) -> {MiEnumItem<T>},
	FromName : (self : EnumType<T>,_ : string) -> MiEnumItem<T>?,
	FromValue : (self : EnumType<T>,_ : number) -> MiEnumItem<T>?,
} & {
	[keyof<T>] : MiEnumItem<T>
},TypeMt<T>>

export type EnumTypeInternal<T> = EnumType<T> & {
	_Name : string
}

export type ItemMt<T> = {
	__tostring : (self : MiEnumItemInternal<T>) -> string,
	__concat : (self : MiEnumItemInternal<T>,value : string) -> string,
	__newindex : () -> nil,
}

export type MiEnumItem<T> = setmetatable<{
	Name: string,
	Value: number,
	EnumType : EnumType<T>,
},ItemMt<T>>

export type MiEnumItemInternal<T> = MiEnumItem<T> & {
	_EnumName : string
}

return {}
