RegisterServerEvent('feather-character:InitiateCharacter', function(id)
    local _source = source
    FeatherCore.Character.InitiateCharacter(_source, id)
end)

RegisterServerEvent('feather-character:GetCharactersData', function(id)
    local _source = source
    local charApperanceData = CharControllers.GetCharApperanceData(id)
    TriggerClientEvent('feather-character:SendCharactersData', _source, id, charApperanceData.clothing, charApperanceData.attributes, charApperanceData.overlays)
end)

RegisterServerEvent('feather-character:UpdateAttributeDB', function(charId, attributes, clothing, overlays)
    CharControllers.UpdateCharApperanceData(charId, attributes, clothing, overlays)
end)

FeatherCore.RPC.Register("SaveCharacterData", function(params, res, player)
    local src = player
    local activeuser = FeatherCore.User.GetUserBySrc(src)
    FeatherCore.Character.CreateCharacter(activeuser.id, 1, params[1].firstname, params[1].lastname, params[1].model, params[1].dob, json.encode(params[1].img), Config.defaults.money, Config.defaults.gold, Config.defaults.tokens, Config.defaults.xp, Config.SpawnCoords.towns[1].startcoords.x, Config.SpawnCoords.towns[1].startcoords.y, Config.SpawnCoords.towns[1].startcoords.z, Config.defaults.lang, params[1].desc)
    local charId = CharControllers.GetCharIdFromUserId(activeuser.id)

    return res(charId)
end)

RegisterServerEvent('feather-character:CheckForUsers', function()
    local _source = source
    local allChars = FeatherCore.Character.GetAvailableCharactersFromDB(_source)
    if #allChars > 0 then
        TriggerClientEvent('feather-character:SelectCharacterScreen', _source, allChars)
    else
        TriggerClientEvent('feather-character:CreateNewCharacter', _source)
    end
end)
