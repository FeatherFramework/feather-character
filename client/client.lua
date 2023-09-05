feather =  exports['feather-core'].initiate()

local Obj1,Obj2,Obj3,Obj4,ped1,ped2,ped3,ped4
local camera,show

local  PromptGroup = feather.Prompt:SetupPromptGroup() --Setup Prompt Group
local firstprompt

if not IsDoorRegisteredWithSystem(3804893186) then
    Citizen.InvokeNative(0xD99229FE93B46286, 3804893186, 1, 1, 0, 0, 0, 0)
end
DoorSystemSetDoorState(3804893186, 0)


RegisterNetEvent('feather-character:SelectCharacterScreen',function ()
    SpawnProps()
    SpawnCharacters()
    --StartCam(Config.CameraCoords.camera1.x,Config.CameraCoords.camera1.y,Config.CameraCoords.camera1.z,Config.CameraCoords.camera1.h,Config.CameraCoords.camera1.zoom)
end)

RegisterNetEvent('feather-character:CreateNewCharacter',function ()
    show = true
    firstprompt = PromptGroup:RegisterPrompt("Press Me", 0x4CC0E2FE, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"}) --Register your first prompt
    while  show  do
        Wait(5)
		PromptGroup:ShowGroup("My first prompt group") --Show your prompt group        
    

    if firstprompt:HasCompleted() then
        print("First Prompt Completed!")
        firstprompt:DeletePrompt()
        LoadModel('mp_male')
        SetPlayerModel(PlayerId(), joaat('mp_male'), false)
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 4, 0) -- outfits
        DefaultPedSetup(PlayerPedId(), true)
    end
    --StartCam(Config.CameraCoords.camera1.x,Config.CameraCoords.camera1.y,Config.CameraCoords.camera1.z,Config.CameraCoords.camera1.h,Config.CameraCoords.camera1.zoom)
end

end)

RegisterCommand('SpawnProps', function ()
    TriggerEvent('feather-character:SelectCharacterScreen')
   -- SpawnProps()
end)

RegisterCommand('rc',function ()
    LoadModel('mp_male')
    SetPlayerModel(PlayerId(), joaat('mp_male'), false)
    Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 4, 0) -- outfits

    DefaultPedSetup(PlayerPedId(), true)

end)

RegisterCommand('test', function ()

    FreezeEntityPosition(PlayerPedId(),true)
    local heading  = GetEntityHeading(PlayerPedId())
    SetPedDesiredHeading(PlayerPedId() ,heading + 50)
    FreezeEntityPosition(PlayerPedId(),false)

    --AnimpostfxPlay("cutscene_mar6_train")
    -- SpawnProps()
end)

RegisterCommand('new', function ()
    TriggerEvent('feather-character:CreateNewCharacter')
end)

RegisterCommand('endcam', function ()
    EndCam()
end)

function SpawnProps()
    Obj1 = feather.Object:Create(Config.SpawnProps.obj1.name, Config.SpawnProps.obj1.x, Config.SpawnProps.obj1.y, Config.SpawnProps.obj1.z, Config.SpawnProps.obj1.h, false, 'standard')
    Obj2 = feather.Object:Create(Config.SpawnProps.obj2.name, Config.SpawnProps.obj2.x, Config.SpawnProps.obj2.y, Config.SpawnProps.obj2.z, Config.SpawnProps.obj2.h, false, 'standard')
    Obj3 = feather.Object:Create(Config.SpawnProps.obj3.name, Config.SpawnProps.obj3.x, Config.SpawnProps.obj3.y, Config.SpawnProps.obj3.z, Config.SpawnProps.obj3.h, false, 'standard')
    Obj4 = feather.Object:Create(Config.SpawnProps.obj4.name, Config.SpawnProps.obj4.x, Config.SpawnProps.obj4.y, Config.SpawnProps.obj4.z, Config.SpawnProps.obj4.h, false, 'standard')
     
end

function StartCam(x,y,z, heading, zoom)
    Citizen.InvokeNative(0x17E0198B3882C2CB, PlayerPedId())
    DestroyAllCams(true)
    camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x,y,z, -10.0, 00.00, heading, zoom, true, 0)
    SetCamActive(camera,true)
    RenderScriptCams(true, true, 500, true, true)
end

function SwitchCam(x,y,z, heading, zoom)
    SetCamParams(camera, x,y,z, -10.0, 0.0, heading, zoom, 1500, 1, 3, 1)
end

function EndCam()
    
    RenderScriptCams(false, true, 1000, true, false)
    DestroyCam(camera, false)
    camera = nil
    DestroyAllCams(true)

    Obj1:Remove()
    Obj2:Remove()
    Obj3:Remove()
    Obj4:Remove()
    ped1:Remove()
    ped2:Remove()
    ped3:Remove()
    ped4:Remove()

    Citizen.InvokeNative(0xD0AFAFF5A51D72F7, PlayerPedId())
    feather.Instance.create(0)

end

function LoadModel(sex)
    RequestModel(sex)
    while not HasModelLoaded(sex) do
        Wait(10)
    end
end

function UpdatePedVariation(ped)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, true)                           -- UNKNOWN "Fixes outfit"- always paired with _UPDATE_PED_VARIATION
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false) -- _UPDATE_PED_VARIATION
end

function AddComponent(comp,category)
    if category ~= nil then
    RemoveTagFromMetaPed(category)
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), comp, false, true, true)
    Citizen.InvokeNative(0x66b957aac2eaaeab, PlayerPedId(), comp, 0, 0, 1, 1) -- _UPDATE_SHOP_ITEM_WEARABLE_STATE
    Citizen.InvokeNative(0xAAB86462966168CE, PlayerPedId(), 1)
    UpdatePedVariation(PlayerPedId())
end

function RemoveTagFromMetaPed(category)
    if category == "Coat" then
        Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories.CoatClosed, 0)
    end
    if category == "CoatClosed" then
        Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories.Coat, 0)
    end
    if category == "Pant" then
        if not IsPedMale(PlayerPedId()) then
            Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories.Skirt, 0)
        end
        Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories.Boots, 0)
    end
    if category == "Skirt" and not IsPedMale(PlayerPedId()) then
        Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories.Pant, 0)
    end

    Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories[category], 0)
    UpdatePedVariation(PlayerPedId())
end

function CreateNewCharacter()

    local playerPed = PlayerPedId()

    Wait(500)
    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.spawn.x,Config.SpawnCoords.spawn.y,Config.SpawnCoords.spawn.z)
   
    local obj = feather.Object:Create('p_package09', Config.SpawnCoords.gotocoords.x,Config.SpawnCoords.gotocoords.y,Config.SpawnCoords.gotocoords.z, 0, true, 'standard')
   -- local obj = CreateObject(GetHashKey('p_package09'), Config.SpawnCoords.gotocoords.x,Config.SpawnCoords.gotocoords.y,Config.SpawnCoords.gotocoords.z,false, false, false)
    Wait(1000)
    SetEntityAlpha(obj,0,true)
	TaskGoToEntity(playerPed, obj,10000, 0.2, 0.8, 1.0, 1)
    StartCam(Config.CameraCoords.charactercoords.x,Config.CameraCoords.charactercoords.y,Config.CameraCoords.charactercoords.z,Config.CameraCoords.charactercoords.h,Config.CameraCoords.charactercoords.zoom)

end

function DefaultPedSetup(ped, male)
	local compEyes
	local compBody
	local compHead
	local compLegs
    local pants,belt

	if male then
		--Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, 0, true)
		compEyes = 612262189
		compBody = tonumber("0x" .. Config.DefaultChar.Male[1].Body[1])
		compHead = tonumber("0x" .. Config.DefaultChar.Male[1].Heads[1])
		compLegs = tonumber("0x" .. Config.DefaultChar.Male[1].Legs[1])
	else
		Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, 7, true) -- female sync
		compEyes = 928002221
		compBody = tonumber("0x" .. Config.DefaultChar.Female[1].Body[1])
		compHead = tonumber("0x" .. Config.DefaultChar.Female[1].Heads[1])
		compLegs = tonumber("0x" .. Config.DefaultChar.Female[1].Legs[1])
	end
	--Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, 3, 0) -- outfits
    ReadyToRender()
    AddComponent(compBody)
	AddComponent( compLegs)
    AddComponent(pants)
	AddComponent( compHead)
	AddComponent( compEyes)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, belt, false, true)
    UpdatePedVariation(ped)
end

function ReadyToRender()
    Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, PlayerPedId())
    while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, PlayerPedId()) do
        Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, PlayerPedId())
        Wait(0)
    end
end


function SpawnCharacters()
    Citizen.InvokeNative(0x17E0198B3882C2CB, PlayerPedId())
    Wait(500)
    Citizen.InvokeNative(0x9E211A378F95C97C, 183712523)
    Citizen.InvokeNative(0x9E211A378F95C97C, -1699673416)
    Citizen.InvokeNative(0x9E211A378F95C97C, 1679934574)
    --Wait(1500)
    --SetEntityCoords(PlayerPedId(), -563.77, -3776.49, 238.56)
    --TriggerServerEvent('feather-character:GetCharactersData')
     ped1 = feather.Ped:Create('mp_male', Config.SpawnCoords.spawn[1].x, Config.SpawnCoords.spawn[1].y, Config.SpawnCoords.spawn[1].z, 0, 'world', false, false)
     ped2 = feather.Ped:Create('mp_male', Config.SpawnCoords.spawn[2].x, Config.SpawnCoords.spawn[2].y, Config.SpawnCoords.spawn[2].z, 0, 'world', false,  false)
     ped3 = feather.Ped:Create('mp_male', Config.SpawnCoords.spawn[3].x, Config.SpawnCoords.spawn[3].y, Config.SpawnCoords.spawn[3].z, 0, 'world', false,  false)
     ped4 = feather.Ped:Create('mp_male', Config.SpawnCoords.spawn[4].x, Config.SpawnCoords.spawn[4].y, Config.SpawnCoords.spawn[4].z, 0, 'world', false,  false)

end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then

EndCam()

    end
end)