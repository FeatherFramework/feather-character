RegisterServerEvent('feather-character:InitiateCharacter', function(id)
    local _source = source
    FeatherCore.Character.InitiateCharacter(_source, id)
end)

RegisterServerEvent('feather-character:GetCharactersData', function(id)
    local _source = source
    local activeuser
    if id == nil then
        activeuser = FeatherCore.Character.GetCharacterBySrc(_source)
        id = activeuser.id
    end
    local result = MySQL.query.await("SELECT * FROM characters WHERE id = @id", { ['id'] = id })
    TriggerClientEvent('feather-character:SendCharactersData', _source, result[1].clothing, result[1].attributes)
end)

RegisterServerEvent('feather-character:UpdateClothingDB', function(Clothing)
    local _source = source
    FeatherCore.Character.UpdateAttribute(_source, 'clothing', json.encode(Clothing))
end)

RegisterServerEvent('feather-character:UpdateAttributeDB', function(Attributes)
    local _source = source
    FeatherCore.Character.UpdateAttribute(_source, 'attributes', json.encode(Attributes))
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
        Clothing = json.encode(v.Clothing)
        Attributes = json.encode(v.Attributes)
        Desc = v.desc
    end
    FeatherCore.Character.CreateCharacter(activeuser.id, 1, FirstName, LastName, Model, DOB,
        Img, Config.defaults.money,
        Config.defaults.gold, Config.defaults.tokens, Config.defaults.xp, Config.SpawnCoords.towns[1].coords.x,
        Config.SpawnCoords.towns[1].coords.y, Config.SpawnCoords.towns[1].coords.z, "en_us",
        Clothing,
        Attributes, Desc)
    local result = MySQL.query.await("SELECT id FROM characters WHERE user_id = @user_id ORDER BY user_id DESC LIMIT 1",
        { ['user_id'] = activeuser.id })

    return res(result[1].id)
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
                            local allchars = FeatherCore.Character.GetAvailableCharactersFromDB(_source)
                            TriggerClientEvent('feather-character:SelectCharacterScreen', _source, allchars)
                        else
                            TriggerClientEvent('feather-character:CreateNewCharacter', _source)
                        end
                    end)
            end
        end
    end
end)
