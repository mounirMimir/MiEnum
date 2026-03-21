-- Version 1.0.0
export type TypeMt<T> = {
	__tostring : () -> string,
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

export type ItemMt<T> = {
	__tostring : () -> string,
}

export type MiEnumItem<T> = setmetatable<{
	Name: string,
	Value: number,
	EnumType : EnumType<T>,
},ItemMt<T>>

return {}
