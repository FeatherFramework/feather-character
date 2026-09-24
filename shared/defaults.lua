-- Canonical Feather Character v2 starter appearances.
-- Captured from the live Default Male and Default Female appearance documents
-- on 2026-09-15. Keep category names aligned with the persisted schema.

local function clone(value)
    if type(value) ~= 'table' then return value end
    local copy = {}
    for key, entry in pairs(value) do copy[key] = clone(entry) end
    return copy
end

local neutralAttributes = {
    WaistSize = { value = -2045421226 },
    ChinHeight = { hash = 15375, value = 0.0 },
    ChinDepth = { hash = 58147, value = 0.0 },
    EarWidth = { hash = 49231, value = 0.0 },
    EarHeight = { hash = 10308, value = 0.0 },
    UpLipHeight = { hash = 6656, value = 0.0 },
    EyelidWidth = { hash = 7019, value = 0.0 },
    JawDepth = { hash = 7670, value = 0.0 },
    JawHeight = { hash = 36106, value = 0.0 },
    NoseWidth = { hash = 28287, value = 0.0 },
    MouthDepth = { hash = 43625, value = 0.0 },
    CheekboneWidth = { hash = 43983, value = 0.0 },
    EyeHeight = { hash = 56827, value = 0.0 },
    UpLipWidth = { hash = 37313, value = 0.0 },
    LowLipWidth = { hash = 45232, value = 0.0 },
    ThighsSize = { hash = 64834, value = 0.0 },
    UpLipDepth = { hash = 50037, value = 0.0 },
    CheekboneHeight = { hash = 27147, value = 0.0 },
    BrowOpacity = { value = 1.0 },
    ChinWidth = { hash = 50098, value = 0.0 },
    MouthWidth = { hash = 61541, value = 0.0 },
    NoseAngle = { hash = 13489, value = 0.0 },
    EyebrowHeight = { hash = 13059, value = 0.0 },
    NoseHeight = { hash = 1013, value = 0.0 },
    EyeColor = { hash = 612262189 },
    EyebrowVariant = { value = 1 },
    CheekboneDepth = { hash = 13709, value = 0.0 },
    Body = { hash = 543187419 },
    LowLipDepth = { hash = 23830, value = 0.0 },
    NoseCurve = { hash = 61782, value = 0.0 },
    BodyType = { hash = -1241887289 },
    CalvesSize = { hash = 42067, value = 0.0 },
    HipWidth = { hash = 49787, value = 0.0 },
    EyelidHeight = { hash = 35627, value = 0.0 },
    ChestSize = { hash = 1676751061 },
    LowLipHeight = { hash = 47949, value = 0.0 },
    EarSize = { hash = 60720, value = 0.0 },
    MouthXPos = { hash = 31427, value = 0.0 },
    MouthYPos = { hash = 16653, value = 0.0 },
    Albedo = { hash = 317354806 },
    EyebrowWidth = { hash = 12281, value = 0.0 },
    WaistWidth = { hash = 50460, value = 0.0 },
    EyeDistance = { hash = 42318, value = 0.0 },
    ForearmSize = { hash = 8420, value = 0.0 },
    JawWidth = { hash = 60334, value = 0.0 },
    EyeDepth = { hash = 60996, value = 0.0 },
    Legs = { hash = 2226823945 },
    UpArmSize = { hash = 46032, value = 0.0 },
    EarAngle = { hash = 46798, value = 0.0 },
    Head = { hash = 2696825467 }
}

local maleAttributes = clone(neutralAttributes)
maleAttributes.hairCategory = { hash = 2112480140 }
maleAttributes.hairVariant = { hash = 2112480140 }

local femaleAttributes = clone(neutralAttributes)
-- V1's first female European entries. The original probe accidentally cloned
-- the male head/body/legs/eyes/albedo, which can remove the female torso.
femaleAttributes.Head = { hash = 1991026974 }       -- 0x76ACA91E
femaleAttributes.Body = { hash = 1218117202 }       -- 0x489AFE52
femaleAttributes.Legs = { hash = 295847116 }        -- 0x11A244CC
femaleAttributes.EyeColor = { hash = 928002221 }
femaleAttributes.Albedo = { hash = 2762087752 }      -- mp_head_fr1_sc08_c0_000_ab
femaleAttributes.hairCategory = { hash = 3887861344 }
femaleAttributes.hairVariant = { hash = 3887861344 }

CharacterV2Defaults = {
    Male = {
        schemaVersion = 3,
        attributes = maleAttributes,
        -- Verified v1 starter clothing layered over the clean base preset.
        clothing = {
            Boots = -218859683,
            Gunbelt = 795591403,
            Pant = 1840115670,
            Shirt = -756756912,
            Suspender = -73797284
        },
        overlays = {},
        tints = {
            Shirt = { 41, 48, 55 },
            Suspender = { 0, 0, 0 },
            Pant = { 21, 19, 39 }
        }
    },
    Female = {
        schemaVersion = 3,
        attributes = femaleAttributes,
        -- Preset 3 supplies a clean base; these verified v1 components supply
        -- the intended starter clothes without preset 2's mask/red jacket.
        clothing = {
            Boots = -571902733,
            Pant = -457359897,
            Shirt = -568119413,
            Suspender = 1467239777
        },
        overlays = {},
        tints = {
            Shirt = { 41, 48, 55 },
            Suspender = { 20, 9, 11 },
            Pant = { 21, 19, 39 }
        }
    }
}
