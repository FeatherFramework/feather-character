local feather = {}

TriggerEvent("getCore", function(core)
    feather = core
end)


RegisterServerEvent('feather-character:GetCharactersData',function ()
    local src = source
    local Characters = feather.getUserCharacter(src)
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