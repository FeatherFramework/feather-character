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
    for k, v in ipairs(GetPlayerIdentifiers(_source)) do
        if string.match(v, "license:") then
            local license = MySQL.query.await("SELECT * FROM users WHERE license = license") --Migrate this to check the user cache (saves a db call)
            if license[1] then
                local userid = license[1].id
                exports.ghmattimysql:execute("SELECT * FROM `characters` WHERE user_id = @userid",
                    { ['userid'] = userid },
                    function(result)
                        if result[1] then
                            allchars = FeatherCore.Character.GetAvailableCharactersFromDB(_source)
                            TriggerClientEvent('feather-character:SelectCharacterScreen', _source, allchars)
                        else
                            TriggerClientEvent('feather-character:CreateNewCharacter', _source)
                        end
                    end)
            end
        end
    end
end)
