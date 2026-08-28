local logger = CharacterLogging.Create('startup')

local function RunCharacterContract1()
    local foundation = CharacterFoundation.BeginStartup()
    if not foundation.ok then error(('[%s] %s'):format(foundation.code, foundation.message)) end

    local migrations = CharacterMigrationRunner.Run()
    if not migrations.ok then error(('[%s] %s'):format(migrations.code, migrations.message)) end
    CharacterFoundation.MarkMigrationsComplete(migrations.value)

    local activationTransport = CharacterActivationTransport.Install()
    if not activationTransport.ok then
        error(('[%s] %s'):format(activationTransport.code, activationTransport.message))
    end
    local transport = CharacterProfileTransport.Install()
    if not transport.ok then error(('[%s] %s'):format(transport.code, transport.message)) end
    local appearanceTransport = CharacterAppearanceTransport.Install()
    if not appearanceTransport.ok then
        error(('[%s] %s'):format(appearanceTransport.code, appearanceTransport.message))
    end

    local ready = CharacterFoundation.MarkReady()
    if not ready.ok then error(('[%s] %s'):format(ready.code, ready.message)) end
    logger.Info('contract_1.ready', { migrations = migrations.value.total, applied = migrations.value.applied })
end

local ok, failure = xpcall(RunCharacterContract1, debug.traceback)
if not ok then
    CharacterFoundation.MarkFailed('startup_failed', 'Feather Character Contract 1 failed during startup.', {
        reason = tostring(failure)
    })
    error(failure)
end

RegisterCommand('CharacterPersistenceSmokeTest', function(source)
    if source ~= 0 then return end
    local accountId = MySQL.scalar.await('SELECT UUID()')
    local createdId
    local tests = {
        {
            name = 'migration ledger',
            run = function()
                return tonumber(MySQL.scalar.await([[
                    SELECT COUNT(*) FROM information_schema.TABLES
                    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'character_schema_migrations'
                ]])) == 1
            end
        },
        {
            name = 'idempotent migrations',
            run = function()
                local result = CharacterMigrationRunner.Run()
                return result.ok and result.value.applied == 0
            end
        },
        {
            name = 'atomic profile bundle',
            run = function()
                local result = CharacterProfiles.Create(accountId, {
                    firstName = 'Contract', lastName = 'Smoke', dateOfBirth = '1860-01-01',
                    model = 'mp_male', spawnPointId = 'smoke',
                    appearance = { attributes = {}, clothing = {}, overlays = {}, tints = {} }
                }, 'persistence-smoke')
                createdId = result.ok and result.value.characterId or nil
                if not createdId then return false end
                local rows = MySQL.query.await([[
                    SELECT
                      (SELECT COUNT(*) FROM `character_profiles` WHERE `character_id` = ?) AS profiles,
                      (SELECT COUNT(*) FROM `character_appearance_documents` WHERE `character_id` = ?) AS appearances,
                      (SELECT COUNT(*) FROM `character_spawn_state` WHERE `character_id` = ?) AS spawns
                ]], { createdId, createdId, createdId })
                local row = rows and rows[1]
                return row and tonumber(row.profiles) == 1 and tonumber(row.appearances) == 1 and tonumber(row.spawns) == 1
            end
        },
        {
            name = 'ownership scoped',
            run = function()
                local owned = CharacterProfiles.Owns(accountId, createdId)
                local other = CharacterProfiles.Owns('00000000-0000-0000-0000-000000000000', createdId)
                return owned.ok and owned.value.owned == true and other.ok and other.value.owned == false
            end
        },
        {
            name = 'public snapshot',
            run = function()
                local profile = CharacterProfiles.Get(createdId)
                return profile.ok and profile.value.characterId == createdId
                    and profile.value.accountId == nil and profile.value.firstName == 'Contract'
            end
        }
    }

    local passed = 0
    for _, test in ipairs(tests) do
        local executed, result = pcall(test.run)
        local success = executed and result == true
        if success then passed = passed + 1 end
        print(('[CharacterPersistenceSmokeTest] %-24s %s'):format(test.name, success and 'PASS' or 'FAIL'))
        if not executed then logger.Error('smoke_test.errored', { test = test.name, reason = tostring(result) }) end
    end
    if accountId then CharacterProfiles.DeleteForTest(accountId) end
    print(('[CharacterPersistenceSmokeTest] done %d/%d passed'):format(passed, #tests))
end, true)

RegisterCommand('CharacterProfileContractSmokeTest', function(source)
    if source ~= 0 then return end
    local accountId = MySQL.scalar.await('SELECT UUID()')
    local input = {
        firstName = 'Contract', lastName = 'Profile', dateOfBirth = '1860-01-01',
        model = 'mp_female', spawnPointId = 'smoke',
        appearance = { attributes = {}, clothing = {}, overlays = {}, tints = {} }
    }
    local first = CharacterProfiles.Create(accountId, input, 'profile-contract-smoke')
    local second = CharacterProfiles.Create(accountId, input, 'profile-contract-smoke')
    local initialAppearance = first.ok and CharacterAppearance.Get(first.value.characterId)
        or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local routes = exports['feather-core']:GetRpcRoutes()
    local providerResult = exports['feather-core']:GetProvider('character-profile', nil, 1)

    local routeNames = {}
    if routes and routes.ok then
        for _, route in ipairs(routes.value) do routeNames[route.route] = true end
    end
    local tests = {
        {
            name = 'profile routes',
            passed = routeNames['character.list.v1'] and routeNames['character.get.v1']
                and routeNames['character.create.v1']
        },
        {
            name = 'profile provider',
            passed = providerResult and providerResult.ok == true
                and providerResult.value.provider.owner == 'feather-character'
        },
        {
            name = 'idempotent creation',
            passed = first.ok and second.ok and first.value.characterId == second.value.characterId
                and first.value.idempotent == false and second.value.idempotent == true
        },
        {
            name = 'provider ownership',
            passed = first.ok and providerResult.ok
                and providerResult.value.implementation.OwnsCharacter(accountId, first.value.characterId).value.owned == true
        },
        {
            name = 'provider snapshot',
            passed = first.ok and providerResult.ok
                and providerResult.value.implementation.GetProfile(first.value.characterId).value.accountId == nil
        },
        {
            name = 'default hair persisted',
            passed = initialAppearance.ok
                and type(initialAppearance.value.document.attributes.hairVariant) == 'table'
                and initialAppearance.value.document.attributes.hairVariant.hash ~= nil
        }
    }
    local passed = 0
    for _, test in ipairs(tests) do
        if test.passed then passed = passed + 1 end
        print(('[CharacterProfileContractSmokeTest] %-24s %s'):format(test.name, test.passed and 'PASS' or 'FAIL'))
    end
    if accountId then CharacterProfiles.DeleteForTest(accountId) end
    print(('[CharacterProfileContractSmokeTest] done %d/%d passed'):format(passed, #tests))
end, true)

RegisterCommand('CharacterAppearanceSmokeTest', function(source)
    if source ~= 0 then return end
    local accountId = MySQL.scalar.await('SELECT UUID()')
    local created = CharacterProfiles.Create(accountId, {
        firstName = 'Appearance', lastName = 'Smoke', dateOfBirth = '1860-01-01',
        model = 'mp_male', spawnPointId = 'smoke',
        appearance = { attributes = {}, clothing = {}, overlays = {}, tints = {} }
    }, 'appearance-smoke')
    local characterId = created.ok and created.value.characterId or nil
    local initial = characterId and CharacterAppearance.Get(characterId)
        or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local updated = initial.ok and CharacterAppearance.Update(characterId, initial.value.revision, {
        attributes = { height = 1.0 }, clothing = {}, overlays = {}, tints = {}
    }) or initial
    local stale = updated.ok and CharacterAppearance.Update(characterId, initial.value.revision, {
        attributes = { height = 0.9 }, clothing = {}, overlays = {}, tints = {}
    }) or updated
    local persisted = characterId and CharacterAppearance.Get(characterId)
        or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local routes = exports['feather-core']:GetRpcRoutes()
    local routeNames = {}
    if routes and routes.ok then
        for _, route in ipairs(routes.value) do routeNames[route.route] = true end
    end
    local tests = {
        { name = 'appearance routes', passed = routeNames['character.appearance.get.v1']
            and routeNames['character.appearance.update.v1'] },
        { name = 'initial revision', passed = initial.ok and initial.value.revision == 1 },
        { name = 'revision update', passed = updated.ok and updated.value.revision == 2 },
        { name = 'stale write rejected', passed = stale.ok == false and stale.code == 'conflict' },
        { name = 'document persisted', passed = persisted.ok and persisted.value.revision == 2
            and persisted.value.document.attributes.height == 1.0 },
        { name = 'unknown section rejected', passed = CharacterAppearance.Validate({ exploit = {} }).ok == false }
    }
    local passed = 0
    for _, test in ipairs(tests) do
        if test.passed then passed = passed + 1 end
        print(('[CharacterAppearanceSmokeTest] %-24s %s'):format(test.name, test.passed and 'PASS' or 'FAIL'))
    end
    if accountId then CharacterProfiles.DeleteForTest(accountId) end
    print(('[CharacterAppearanceSmokeTest] done %d/%d passed'):format(passed, #tests))
end, true)

RegisterCommand('CharacterDeletionContractSmokeTest', function(source)
    if source ~= 0 then return end
    local accountId = MySQL.scalar.await('SELECT UUID()')
    local created = CharacterProfiles.Create(accountId, {
        firstName = 'Delete', lastName = 'Contract', dateOfBirth = '1860-01-01',
        model = 'mp_male', spawnPointId = 'valentine',
        appearance = { attributes = {}, clothing = {}, overlays = {}, tints = {} }
    }, 'deletion-contract-smoke')
    local characterId = created.ok and created.value.characterId or nil
    local unconfirmed = characterId and CharacterProfiles.SoftDelete(accountId, characterId, false, nil)
        or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local active = characterId and CharacterProfiles.SoftDelete(accountId, characterId,
        true, characterId) or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local deleted = characterId and CharacterProfiles.SoftDelete(accountId, characterId,
        true, nil) or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local listed = CharacterProfiles.List(accountId)
    local stored = characterId and CharacterProfiles.Get(characterId)
        or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local dependents = characterId and MySQL.single.await([[
        SELECT
          (SELECT COUNT(*) FROM `character_appearance_documents` WHERE `character_id` = ?) AS appearances,
          (SELECT COUNT(*) FROM `character_spawn_state` WHERE `character_id` = ?) AS spawns
    ]], { characterId, characterId }) or {}
    local routes = exports['feather-core']:GetRpcRoutes()
    local routeNames = {}
    if routes and routes.ok then
        for _, route in ipairs(routes.value) do routeNames[route.route] = true end
    end
    local tests = {
        { name = 'deletion route', passed = routeNames['character.delete.v1'] == true },
        { name = 'unconfirmed rejected', passed = unconfirmed.ok == false
            and unconfirmed.code == 'confirmation_invalid' },
        { name = 'active character rejected', passed = active.ok == false
            and active.code == 'character_active' },
        { name = 'profile soft deleted', passed = deleted.ok == true and stored.ok == true
            and stored.value.status == 'deleted' },
        { name = 'selection excludes deleted', passed = listed.ok == true and #(listed.value or {}) == 0 },
        { name = 'dependent state retained', passed = tonumber(dependents.appearances) == 1
            and tonumber(dependents.spawns) == 1 }
    }
    local passed = 0
    for _, test in ipairs(tests) do
        if test.passed then passed = passed + 1 end
        print(('[CharacterDeletionContractSmokeTest] %-26s %s'):format(
            test.name, test.passed and 'PASS' or 'FAIL'))
    end
    if accountId then CharacterProfiles.DeleteForTest(accountId) end
    print(('[CharacterDeletionContractSmokeTest] done %d/%d passed'):format(passed, #tests))
end, true)

RegisterCommand('CharacterActivationContractSmokeTest', function(source)
    if source ~= 0 then return end
    local accountId = MySQL.scalar.await('SELECT UUID()')
    local created = CharacterProfiles.Create(accountId, {
        firstName = 'Activation', lastName = 'Smoke', dateOfBirth = '1860-01-01',
        model = 'mp_male', spawnPointId = 'valentine',
        appearance = { attributes = {}, clothing = {}, overlays = {}, tints = {} }
    }, 'activation-smoke')
    local characterId = created.ok and created.value.characterId or nil
    local plan = characterId and CharacterSpawn.BuildPlan(characterId, 'smoke-session')
        or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local position = characterId and CharacterSpawn.UpdatePosition(characterId, {
        x = -273.5, y = 794.5, z = 118.6, heading = 180.0
    }) or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local restoredPlan = characterId and CharacterSpawn.BuildPlan(characterId, 'restored-session')
        or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local invalidPosition = characterId and CharacterSpawn.UpdatePosition(characterId, {
        x = 999999, y = 0, z = 0, heading = 0
    }) or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local foreign = characterId and CharacterActivation.Activate(
        1, '00000000-0000-0000-0000-000000000000', characterId
    ) or CharacterResults.Err('not_found', 'Smoke character was not created.')
    local invalidCoreActivation = exports['feather-core']:ActivateSession(0, characterId or 'missing')
    local routes = exports['feather-core']:GetRpcRoutes()
    local events = exports['feather-core']:GetEvents()
    local routeNames, eventNames = {}, {}
    if routes and routes.ok then
        for _, route in ipairs(routes.value) do routeNames[route.route] = true end
    end
    if events and events.ok then
        for _, event in ipairs(events.value) do eventNames[event.event] = true end
    end
    local tests = {
        { name = 'activation routes', passed = routeNames['character.activate.v1']
            and routeNames['character.spawn.complete.v1'] and routeNames['character.position.update.v1']
            and routeNames['character.logout.v1'] },
        { name = 'lifecycle events', passed = eventNames['character.ready.v1']
            and eventNames['character.spawned.v1'] and eventNames['character.leaving.v1']
            and eventNames['character.left.v1'] },
        { name = 'configured spawn plan', passed = plan.ok and plan.value.spawnPointId == 'valentine'
            and plan.value.position.x == Config.Contract1.spawnPoints.valentine.x },
        { name = 'plan bound to session', passed = plan.ok and plan.value.sessionId == 'smoke-session' },
        { name = 'last position persisted', passed = position.ok and restoredPlan.ok
            and restoredPlan.value.mode == 'last_position'
            and restoredPlan.value.position.x == -273.5
            and restoredPlan.value.sessionId == 'restored-session' },
        { name = 'invalid position rejected', passed = invalidPosition.ok == false
            and invalidPosition.code == 'position_invalid' },
        { name = 'foreign activation denied', passed = foreign.ok == false and foreign.code == 'not_found' },
        { name = 'core activation validates', passed = type(invalidCoreActivation) == 'table'
            and invalidCoreActivation.ok == false and invalidCoreActivation.code == 'invalid_input' }
    }
    local passed = 0
    for _, test in ipairs(tests) do
        if test.passed then passed = passed + 1 end
        print(('[CharacterActivationContractSmokeTest] %-25s %s'):format(test.name, test.passed and 'PASS' or 'FAIL'))
    end
    if accountId then CharacterProfiles.DeleteForTest(accountId) end
    print(('[CharacterActivationContractSmokeTest] done %d/%d passed'):format(passed, #tests))
end, true)

RegisterCommand('CharacterLiveCutoverSmokeTest', function(source, args)
    if source ~= 0 then return end
    local target = tonumber(args and args[1])
    if not target then
        local players = GetPlayers()
        target = players[1] and tonumber(players[1]) or nil
    end
    local account = target and exports['feather-core']:GetAccountContext(target)
        or CharacterResults.Err('not_found', 'No connected player is available.')
    local session = target and exports['feather-core']:GetSessionContext(target)
        or CharacterResults.Err('not_found', 'No connected player is available.')
    local characterId = session.ok and session.value.characterId or nil
    local isUuid = type(characterId) == 'string' and characterId:match(
        '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$'
    ) ~= nil
    local profile = isUuid and CharacterProfiles.Get(characterId)
        or CharacterResults.Err('not_found', 'The active character is not a Contract 1 profile.')
    local appearance = isUuid and CharacterAppearance.Get(characterId)
        or CharacterResults.Err('not_found', 'The active character is not a Contract 1 profile.')
    local ownership = account.ok and isUuid and CharacterProfiles.Owns(account.value.accountId, characterId)
        or CharacterResults.Err('not_found', 'Ownership could not be evaluated.')
    local current = session.ok and exports['feather-core']:IsSessionCurrent(
        target, session.value.sessionId, characterId) or false
    local tests = {
        { name = 'connected account', passed = account.ok == true },
        { name = 'uuid character session', passed = isUuid == true },
        { name = 'session is current', passed = current == true },
        { name = 'profile ownership', passed = ownership.ok == true and ownership.value.owned == true },
        { name = 'profile persisted', passed = profile.ok == true },
        { name = 'appearance persisted', passed = appearance.ok == true }
    }
    local passed = 0
    for _, test in ipairs(tests) do
        if test.passed then passed = passed + 1 end
        print(('[CharacterLiveCutoverSmokeTest] %-24s %s'):format(
            test.name, test.passed and 'PASS' or 'FAIL'))
    end
    print(('[CharacterLiveCutoverSmokeTest] done %d/%d passed source=%s character=%s'):format(
        passed, #tests, tostring(target), tostring(characterId)))
end, true)

RegisterCommand('CharacterSelectionPreviewSmokeTest', function(source, args)
    if source ~= 0 then return end
    local target = tonumber(args and args[1])
    if not target then
        local players = GetPlayers()
        target = players[1] and tonumber(players[1]) or nil
    end
    local account = target and exports['feather-core']:GetAccountContext(target)
        or CharacterResults.Err('not_found', 'No connected player is available.')
    local profiles = account.ok and CharacterProfiles.List(account.value.accountId)
        or CharacterResults.Err('not_found', 'Account profiles could not be listed.')
    local uuidOnly, appearanceReady = profiles.ok == true, profiles.ok == true
    local count = profiles.ok and #(profiles.value or {}) or 0
    for _, profile in ipairs(profiles.ok and profiles.value or {}) do
        local characterId = profile.characterId
        local uuid = type(characterId) == 'string' and characterId:match(
            '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$'
        ) ~= nil
        uuidOnly = uuidOnly and uuid
        local appearance = uuid and CharacterAppearance.Get(characterId)
            or CharacterResults.Err('not_found', 'Character identity is invalid.')
        appearanceReady = appearanceReady and appearance.ok == true
            and type(appearance.value.document) == 'table'
    end
    local routes = exports['feather-core']:GetRpcRoutes()
    local routeNames = {}
    if routes and routes.ok then
        for _, route in ipairs(routes.value) do routeNames[route.route] = true end
    end
    local tests = {
        { name = 'connected account', passed = account.ok == true },
        { name = 'profile list route', passed = routeNames['character.list.v1'] == true },
        { name = 'appearance route', passed = routeNames['character.appearance.get.v1'] == true },
        { name = 'uuid-only profiles', passed = uuidOnly == true },
        { name = 'preview documents', passed = appearanceReady == true }
    }
    local passed = 0
    for _, test in ipairs(tests) do
        if test.passed then passed = passed + 1 end
        print(('[CharacterSelectionPreviewSmokeTest] %-22s %s'):format(
            test.name, test.passed and 'PASS' or 'FAIL'))
    end
    print(('[CharacterSelectionPreviewSmokeTest] done %d/%d passed source=%s profiles=%d'):format(
        passed, #tests, tostring(target), count))
end, true)

RegisterCommand('CharacterCoreCutoverSmokeTest', function(source)
    if source ~= 0 then return end
    local capabilities = exports['feather-core']:GetCapabilities()
    local routes = exports['feather-core']:GetRpcRoutes()
    local provider = exports['feather-core']:GetProvider('character-profile', nil, 1)
    local locale = exports['feather-core']:TranslateLocale(0, 'charMenu')
    local routeNames = {}
    if routes and routes.ok then
        for _, route in ipairs(routes.value or {}) do routeNames[route.route] = true end
    end
    local requiredRoutes = {
        'core.instance.enter.v1', 'core.instance.leave.v1',
        'character.list.v1', 'character.get.v1', 'character.create.v1', 'character.delete.v1',
        'character.appearance.get.v1', 'character.appearance.update.v1',
        'character.activate.v1', 'character.spawn.complete.v1',
        'character.position.update.v1', 'character.logout.v1'
    }
    local routesReady = true
    for _, route in ipairs(requiredRoutes) do routesReady = routesReady and routeNames[route] == true end
    local tests = {
        { name = 'core contract ready', passed = capabilities and capabilities.ok == true
            and tonumber(capabilities.value.contract) >= 1 },
        { name = 'named character routes', passed = routesReady == true },
        { name = 'profile provider ready', passed = provider and provider.ok == true
            and provider.value.provider.owner == 'feather-character' },
        { name = 'named locale ready', passed = locale and locale.ok == true
            and type(locale.value) == 'string' },
        { name = 'legacy routes absent', passed = routeNames['SaveCharacterData'] ~= true
            and routeNames['GetCharactersData'] ~= true }
    }
    local passed = 0
    for _, test in ipairs(tests) do
        if test.passed then passed = passed + 1 end
        print(('[CharacterCoreCutoverSmokeTest] %-24s %s'):format(
            test.name, test.passed and 'PASS' or 'FAIL'))
    end
    print(('[CharacterCoreCutoverSmokeTest] done %d/%d passed'):format(passed, #tests))
end, true)
