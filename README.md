# MiEnum

a simple enum module for luau. nothing crazy, just makes working with enums cleaner and type-safe.

---

## what it does

- create enums that are frozen (immutable after creation)
- strict luau types so you can't accidentally pass a random number or string
- runtime checks to validate enum values
- look up items by name or value, or grab all of them
- union types if you need to combine enums

---

## installation

drop the module here:

```
ReplicatedStorage/
└── Packages/
    └── MiEnum
```

then require it:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CustomEnum = require(ReplicatedStorage.Packages.MiEnum)
```

---

## creating an enum

```lua
local StatusEffectType = CustomEnum.CreateEnum("StatusEffectType", {
    Control  = 1,
    Torture  = 2,
    Positive = 3,
    Negative = 4,
})
```

few things to keep in mind:
- keys have to be unique strings
- values have to be unique positive integers
- you can't reuse an enum name
- enums are frozen after creation, no changing them later

---

## accessing items

```lua
print(StatusEffectType.Control)        -- CustomEnum.StatusEffectType.Control
print(StatusEffectType.Control.Name)   -- "Control"
print(StatusEffectType.Control.Value)  -- 1
```

every item has three fields: `Name`, `Value`, and `EnumType` (the enum it belongs to)

---

## strict types

```lua
export type StatusEffectType = typeof(StatusEffectType.Control)
```

now you can use it in function signatures:

```lua
local function ApplyStatus(effect: StatusEffectType)
    print("Applying:", effect.Name)
end

ApplyStatus(StatusEffectType.Control) -- ✅
ApplyStatus(1)         -- ❌ type error
ApplyStatus("Control") -- ❌ type error
```

---

## combining enums

```lua
export type AnyStatusEffect = ControlStatusEffect | TortureStatusEffect | PositiveStatusEffect

local function ApplyAny(effect: AnyStatusEffect)
    print(effect.Name)
end
```

---

## runtime checks

```lua
-- check if something is a valid enum item
if StatusEffectType:IsEnumItem(value) then
    print("valid!")
end

-- check by name or value
StatusEffectType:IsValid("Control") -- true
StatusEffectType:IsValid(1)         -- true
```

---

## lookup methods

```lua
local item  = StatusEffectType:FromName("Control")
local item  = StatusEffectType:FromValue(1)
local items = StatusEffectType:GetEnumItems()
```

---

## another example

```lua
local WeaponType = CustomEnum.CreateEnum("WeaponType", {
    Sword = 1,
    Bow   = 2,
    Staff = 3,
})

export type WeaponType = typeof(WeaponType.Sword)
```

---

that's pretty much it. if something's broken or confusing feel free to open an issue
