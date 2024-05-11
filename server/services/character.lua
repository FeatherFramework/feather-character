RegisterServerEvent('feather-character:InitiateCharacter', function(id)
    local _source = source
    FeatherCore.Character.InitiateCharacter(_source, id)
end)

RegisterServerEvent('feather-character:GetCharactersData', function(id)
    local _source = source
    print(id)
    result = MySQL.query.await("SELECT * FROM character_appearance WHERE id = @id", { ['id'] = id })
    TriggerClientEvent('feather-character:SendCharactersData', _source,id,result[1].clothing, result[1].attributes,result[1].overlays)
end)

RegisterServerEvent('feather-character:UpdateAttributeDB', function(Charid, Attributes, Clothing, Overlays)
    local params = {
        ['id'] = Charid,
        ['attributes'] = Attributes,
        ['clothing'] = Clothing,
        ['overlays'] = Overlays
    }
    MySQL.query.await(
        "INSERT INTO character_appearance (`id`, `attributes`, `clothing`,`overlays`) VALUES (@id,@attributes,@clothing,@overlays)",
        params)
end)

FeatherCore.RPC.Register("SaveCharacterData", function(params, res, player)
    local src = player
    local activeuser = FeatherCore.User.GetUserBySrc(src)
    for k, v in pairs(params) do
        FirstName = v.firstname
        LastName = v.lastname
        Model = v.model
        DOB = v.dob
        Img = json.encode(v.img)
        Clothing = v.clothing
        Attributes = v.attributes
        Desc = v.desc
    end
    FeatherCore.Character.CreateCharacter(activeuser.id, 1, FirstName, LastName, Model, DOB, Img, Config.defaults.money,
        Config.defaults.gold, Config.defaults.tokens, Config.defaults.xp, Config.SpawnCoords.towns[1].startcoords.x,
        Config.SpawnCoords.towns[1].startcoords.y, Config.SpawnCoords.towns[1].startcoords.z, "en_us", Desc)
    local result = MySQL.query.await("SELECT id FROM characters WHERE user_id = @user_id ORDER BY user_id DESC",
        { ['user_id'] = activeuser.id })
    Charid = result[#result].id

    return res(Charid)
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