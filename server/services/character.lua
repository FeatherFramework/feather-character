RegisterServerEvent('feather-character:GetCharactersData', function()
    local src = source
    local Characters = FeatherCore.getUserCharacter(src)
    local charid = Characters.charIdentifier


    --TODO: Lets swap this to use the core character API and cache. I (bytesizd) can help with this.
    exports.ghmattimysql:execute("SELECT skinPlayer AND compPlayer FROM `characters` WHERE ? = ?",
        { charid },
        function(result)
            if result[1] then
                TriggerClientEvent('feather-character:SendCharactersData')
            end
        end)
end)


RegisterServerEvent('feather-character:SendDetailsToDB', function(args)
    local src = source
    local activeuser = FeatherCore.User.GetUserBySrc(src)
    FeatherCore.Character.CreateCharacter(activeuser.id, 1, args.firstname, args.lastname, args.dob, Config.defaults.money,
        Config.defaults.gold, Config.defaults.tokens, Config.defaults.xp, Config.SpawnCoords.spawns[1].coords.x,
        Config.SpawnCoords.spawns[1].coords.y, Config.SpawnCoords.spawns[1].coords.z, "en_us")
end)



RegisterServerEvent('feather-character:CheckForUsers', function()
    local _source = source
    local license
    for k, v in ipairs(GetPlayerIdentifiers(_source)) do
        if string.match(v, "license:") then
            license = v
            print(license)
            local license = MySQL.query.await("SELECT * FROM users WHERE license = license")
            if license[1] then
                local userid = license[1].id
                print(userid)
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