-- Look into how to make this more optimized later not a huge deal but this is just weird
-- Namespace tables populated by the other shared/data/*.lua files (general.lua,
-- clothing.lua, attributes.lua, hair.lua, features.lua) -- this file just
-- declares them upfront so load order between those files doesn't matter.
CharacterConfig = {}
CharacterConfig.General = {}
CharacterConfig.Clothing = {}
CharacterConfig.Attributes = {}