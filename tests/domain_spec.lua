-- Run from the resource root with Lua 5.4: lua tests/domain_spec.lua
dofile('config.lua')
dofile('shared/result.lua')
dofile('shared/defaults.lua')
dofile('shared/catalog.lua')
dofile('shared/hair_catalog.lua')
dofile('shared/overlay_catalog.lua')
dofile('shared/draft.lua')
dofile('client/flow.lua')
dofile('server/schema.lua')
dofile('server/migrate.lua')
dofile('server/profiles.lua')

local function Appearance()
    return { schemaVersion = 3, attributes = {}, clothing = {}, tints = {}, overlays = {} }
end

local function Draft()
    return {
        firstName = ' Ada ', lastName = ' Morgan ', dateOfBirth = '1874-01-01',
        model = 'mp_female', spawnPointId = 'valentine', description = '',
        appearance = Appearance()
    }
end

local valid = CharacterV2Draft.Validate(Draft())
assert(valid.ok and valid.value.firstName == 'Ada' and valid.value.lastName == 'Morgan')
assert(CharacterV2Defaults.Male.schemaVersion == 3)
assert(CharacterV2Defaults.Female.schemaVersion == 3)
assert(CharacterV2Defaults.Male.attributes.Head.hash ~= nil)
assert(CharacterV2Defaults.Female.attributes.Head.hash == 1991026974)
assert(CharacterV2Defaults.Female.attributes.Body.hash == 1218117202)
assert(CharacterV2Defaults.Female.attributes.Legs.hash == 295847116)
assert(#CharacterV2Catalog.Heritages('mp_male') == 6)
assert(#CharacterV2Catalog.Heritages('mp_female') == 6)
assert(CharacterV2Catalog.Albedo('mp_male', 1) == CharacterV2Defaults.Male.attributes.Albedo.hash)
assert(CharacterV2Catalog.Albedo('mp_female', 1) == CharacterV2Defaults.Female.attributes.Albedo.hash)
assert(#CharacterV2HairCatalog.Groups('mp_female', 'hair') == 29)
assert(#CharacterV2HairCatalog.Groups('mp_male', 'hair') == 27)
assert(#CharacterV2HairCatalog.Groups('mp_male', 'beard') == 24)
assert(CharacterV2HairCatalog.Contains('mp_male', 'hair',
    CharacterV2Defaults.Male.attributes.hairVariant.hash))
assert(CharacterV2HairCatalog.Contains('mp_female', 'hair',
    CharacterV2Defaults.Female.attributes.hairVariant.hash))
assert(CharacterV2Defaults.Male.clothing.Shirt == -756756912)
assert(CharacterV2Defaults.Male.clothing.Gunbelt == 795591403)
assert(CharacterV2Defaults.Male.clothing.GunbeltAccs == nil)
assert(CharacterV2Defaults.Female.clothing.Shirt == -568119413)
assert(CharacterV2Config.playerBasePreset.mp_male == 4)
assert(CharacterV2Config.playerBasePreset.mp_female == 3)
local customized = CharacterV2Draft.SanitizeAppearance('mp_male', {
    attributes = {
        EyeHeight = { hash = CharacterV2Defaults.Male.attributes.EyeHeight.hash, value = 0.35 },
        Head = { hash = 12345 },
        Unknown = { hash = 12345, value = 1.0 }
    }
})
assert(customized.ok and customized.value.attributes.EyeHeight.value == 0.35)
assert(customized.value.attributes.Head.hash == CharacterV2Defaults.Male.attributes.Head.hash)
assert(customized.value.attributes.Unknown == nil)
local alternateBody = CharacterV2Catalog.Values('mp_male', 'Body')[2]
local alternateLegs = CharacterV2Catalog.Values('mp_male', 'Legs')[2]
local alternateBodyType = CharacterV2Catalog.Values('mp_male', 'BodyType')[2]
local alternateChest = CharacterV2Catalog.Values('mp_male', 'ChestSize')[2]
local alternateWaist = CharacterV2Catalog.Values('mp_male', 'WaistSize')[2]
local alternateHeritageHead = CharacterV2Catalog.Values('mp_male', 'Head', 2)[1]
local alternateAlbedo = CharacterV2Catalog.Albedo('mp_male', 2)
local catalogAppearance = CharacterV2Draft.SanitizeAppearance('mp_male', { attributes = {
    Head = { hash = alternateHeritageHead }, Body = { hash = alternateBody }, Legs = { hash = alternateLegs },
    Albedo = { hash = alternateAlbedo },
    BodyType = { hash = alternateBodyType }, ChestSize = { hash = alternateChest },
    WaistSize = { value = alternateWaist }
} })
assert(catalogAppearance.ok and catalogAppearance.value.attributes.Head.hash == alternateHeritageHead)
assert(catalogAppearance.value.attributes.Albedo.hash == alternateAlbedo)
assert(catalogAppearance.value.attributes.Body.hash == alternateBody)
assert(catalogAppearance.value.attributes.Legs.hash == alternateLegs)
assert(catalogAppearance.value.attributes.BodyType.hash == alternateBodyType)
assert(catalogAppearance.value.attributes.ChestSize.hash == alternateChest)
assert(catalogAppearance.value.attributes.WaistSize.value == alternateWaist)
local hairHash = CharacterV2HairCatalog.Groups('mp_male', 'hair')[2][3]
local beardHash = CharacterV2HairCatalog.Groups('mp_male', 'beard')[2][3]
local hairAppearance = CharacterV2Draft.SanitizeAppearance('mp_male', { attributes = {
    hairCategory = { hash = CharacterV2HairCatalog.Groups('mp_male', 'hair')[2][1] },
    hairVariant = { hash = hairHash },
    beardCategory = { hash = CharacterV2HairCatalog.Groups('mp_male', 'beard')[2][1] },
    beardVariant = { hash = beardHash }
} })
assert(hairAppearance.ok and hairAppearance.value.attributes.hairVariant.hash == hairHash)
assert(hairAppearance.value.attributes.beardVariant.hash == beardHash)
local noHair = CharacterV2Draft.SanitizeAppearance('mp_male', { attributes = {
    hairCategory = { hash = 0 }, hairVariant = { hash = 0 },
    beardCategory = { hash = 0 }, beardVariant = { hash = 0 }
} })
assert(noHair.ok and noHair.value.attributes.hairVariant.hash == 0)
assert(noHair.value.attributes.beardVariant.hash == 0)
local rejectedFemaleBeard = CharacterV2Draft.SanitizeAppearance('mp_female', { attributes = {
    beardCategory = { hash = CharacterV2HairCatalog.Groups('mp_male', 'beard')[1][1] },
    beardVariant = { hash = CharacterV2HairCatalog.Groups('mp_male', 'beard')[1][1] }
} })
assert(rejectedFemaleBeard.ok and rejectedFemaleBeard.value.attributes.beardVariant == nil)
assert(#CharacterV2OverlayCatalog.shadows.ids == 1 and CharacterV2OverlayCatalog.shadows.variants == 5)
assert(#CharacterV2OverlayCatalog.eyebrows.ids == 24)
local overlayAppearance = CharacterV2Draft.SanitizeAppearance('mp_female', { attributes = {}, overlays = {
    shadows = { textureId = 1, variant = 3, opacity = 0.65, color1 = 12, color2 = 24, color3 = 36 },
    scars = { textureId = 2, variant = 1, opacity = 0.4, color1 = 1, color2 = 1, color3 = 1 },
    invented = { textureId = 1, variant = 1, opacity = 1.0, color1 = 1, color2 = 1, color3 = 1 }
} })
assert(overlayAppearance.ok and overlayAppearance.value.overlays.shadows.variant == 3)
assert(overlayAppearance.value.overlays.shadows.opacity == 0.65)
assert(overlayAppearance.value.overlays.scars.textureId == 2)
assert(overlayAppearance.value.overlays.invented == nil)
local rejectedOverlay = CharacterV2Draft.SanitizeAppearance('mp_female', { attributes = {}, overlays = {
    shadows = { textureId = 1, variant = 99, opacity = 2.0, color1 = 999, color2 = 1, color3 = 1 }
} })
assert(rejectedOverlay.ok and rejectedOverlay.value.overlays.shadows == nil)

local badModel = Draft()
badModel.model = 'a_c_horse_americanstandardbred_black'
assert(CharacterV2Draft.Validate(badModel).code == 'invalid_model')

local badSpawn = Draft()
badSpawn.spawnPointId = 'unconfigured'
assert(CharacterV2Draft.Validate(badSpawn).code == 'invalid_spawn')

local badDate = Draft()
badDate.dateOfBirth = '1873-02-29'
assert(CharacterV2Draft.Validate(badDate).code == 'invalid_birth_date')

local badAppearance = Draft()
badAppearance.appearance.attributes = nil
assert(CharacterV2Draft.Validate(badAppearance).code == 'invalid_appearance')

assert(CharacterV2Flow.State().phase == 'idle')
assert(CharacterV2Flow.Transition('selection').ok)
local ticket = CharacterV2Flow.State()
assert(CharacterV2Flow.Transition('creator').ok)
assert(not CharacterV2Flow.IsCurrent(ticket))
assert(CharacterV2Flow.Transition('selection').ok)
assert(CharacterV2Flow.Transition('world').code == 'invalid_transition')
assert(CharacterV2Flow.Reset().value.phase == 'idle')

assert(CharacterV2Schema.version == 1 and #CharacterV2Schema.statements == 5)
assert(type(CharacterV2Migration.Run) == 'function')
assert(type(CharacterV2Profiles.Create) == 'function')
assert(type(CharacterV2Profiles.List) == 'function')
assert(type(CharacterV2Profiles.Delete) == 'function')
assert(type(CharacterV2Profiles.Get) == 'function')
assert(type(CharacterV2Profiles.GetAppearance) == 'function')
assert(type(CharacterV2Profiles.GetSpawnState) == 'function')
assert(type(CharacterV2Profiles.UpdatePosition) == 'function')
assert(CharacterV2Profiles.Create('invalid', 'request-key', Draft()).code == 'invalid_input')
assert(CharacterV2Profiles.Get('invalid', 'invalid').code == 'invalid_input')
assert(CharacterV2Profiles.Delete('invalid', 'invalid').code == 'invalid_input')
for _, statement in ipairs(CharacterV2Schema.statements) do
    assert(statement:find('`fc2_', 1, true))
    assert(not statement:find('`character_profiles`', 1, true))
end

print('Character v2 domain tests passed')
