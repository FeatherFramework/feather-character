local feather = {}

TriggerEvent("getCore", function(core)
    feather = core
end)


RegisterServerEvent('feather-character:GetCharactersData',function ()
    local _source = source
    local Characters = feather.getUserCharacter(source)
    local charid = Characters.charIdentifier

	exports.ghmattimysql:execute("SELECT skinPlayer AND compPlayer FROM `characters` WHERE ? = ?",
		{ charid },
		function(result)
			if result[1] then
                TriggerClientEvent('feather-character:SendCharactersData')
            end
		end)


end)