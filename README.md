# MiEnum
a simple enum module for luau. nothing crazy, just makes working with enums cleaner and type-safe.

**v2.0.0** — adds scoped enums and fixes error reporting to always point at your code.

---

## what it does
- create enums that are frozen (immutable after creation)
- strict luau types so you can't accidentally pass a random number or string
- runtime checks to validate enum values
- look up items by name or value, or grab all of them
- union types if you need to combine enums
- **scopes** to group related enums and prevent name collisions

---

## installation
drop the module here:
ReplicatedStorage/
└── Packages/
└── MiEnum
then require it:
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MiEnum = require(ReplicatedStorage.Packages.MiEnum)
```

---

## two ways to create enums

### 1. scoped enums (recommended)
scopes let you group related enums under a namespace and prevent name collisions across your project.

```lua
local GameEnums = MiEnum.NewScope("GameEnums")

local StatusEffectType = GameEnums.CreateEnum("StatusEffectType", {
    Control  = 1,
    Torture  = 2,
    Positive = 3,
    Negative = 4,
})
```

trying to create two scopes with the same name, or two enums with the same name in the same scope, will throw an error.

### 2. private enums (unscoped)
if you just need a quick local enum that isn't part of any shared scope:

```lua
local WeaponType = MiEnum.CreatePrivateEnum("WeaponType", {
    Sword = 1,
    Bow   = 2,
    Staff = 3,
})
```

use this for module-internal enums you don't want exposed globally.

---

## definition rules
- keys must be unique strings
- values must be unique numbers
- reserved keys (`Count`, `GetEnumItems`, `FromName`, `FromValue`, `IsEnumItem`, `_Name`) are not allowed
- enums are frozen after creation — no changes after the fact

---

## accessing items
```lua
print(StatusEffectType.Control)        -- StatusEffectType.Control
print(StatusEffectType.Control.Name)   -- "Control"
print(StatusEffectType.Control.Value)  -- 1
print(StatusEffectType.Count)          -- 4
```

every item has three fields: `Name`, `Value`, and `EnumType` (a reference back to the enum it belongs to).

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
ApplyStatus(1)                        -- ❌ type error
ApplyStatus("Control")                -- ❌ type error
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

## lookup methods
```lua
-- by name (returns nil if not found)
local item = StatusEffectType:FromName("Control")

-- by value (returns nil if not found)
local item = StatusEffectType:FromValue(1)

-- all items, keyed by value
local items = StatusEffectType:GetEnumItems()
for value, item in items do
    print(item.Name, value)
end
```

---

## runtime checks
```lua
if StatusEffectType:IsEnumItem(value) then
    print("valid item from this enum")
end
```

`IsEnumItem` checks that the value is an enum item **and** that it belongs to this specific enum — passing an item from a different enum returns false.

---

## full example
```lua
local MiEnum = require(ReplicatedStorage.Packages.MiEnum)

local GameEnums = MiEnum.NewScope("GameEnums")

local WeaponType = GameEnums.CreateEnum("WeaponType", {
    Sword = 1,
    Bow   = 2,
    Staff = 3,
})

export type WeaponType = typeof(WeaponType.Sword)

local function Attack(weapon: WeaponType)
    if WeaponType:IsEnumItem(weapon) then
        print("Attacking with:", weapon.Name)
    end
end

Attack(WeaponType.Bow) -- Attacking with: Bow
```

---

that's pretty much it. if something's broken or confusing feel free to open an issue.
