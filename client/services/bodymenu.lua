MainBodyMenu = MyMenu:RegisterPage('mainbody:page')

local BodySlidersMade = nil


MainBodyMenu:RegisterElement('header', {
    value = 'My First Menu',
    slot = "header",
    style = {}
})
MainBodyMenu:RegisterElement('subheader', {
    value = "",
    slot = "header",
    style = {}
})

MainBodyMenu:RegisterElement('button', {
    label = "Go Back",
    slot = 'footer',

    style = {
    },
}, function()
    CategoriesPage:RouteTo()
    SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
    Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
end)

function MakeBodySliders()
    if BodySlidersMade == nil then
        BodySlidersMade = true
        MainBodyMenu:RegisterElement('pagearrows', {
            slot = 'footer',
            total = ' Zoom Cam In',
            current = 'Zoom Cam Out ',
            style = {},
        }, function(data)
            if data.value == 'forward' then
                Fov = Fov - 1.0
                SetCamFov(CharacterCamera, Fov)
            else
                Fov = Fov + 1.0
                SetCamFov(CharacterCamera, Fov)
            end
        end)
        MainBodyMenu:RegisterElement('pagearrows', {
            slot = 'footer',
            total = ' Move Cam Up',
            current = 'Move Cam Down ',
            style = {},
        }, function(data)
            if data.value == 'forward' then
                CamZ = CamZ + 0.1
                SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
            else
                CamZ = CamZ - 0.1
                SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
            end
        end)
        MainBodyMenu:RegisterElement('pagearrows', {
            slot = 'footer',
            total = ' Rotate Right ',
            current = 'Rotate Left ',
            style = {},
        }, function(data)
            if data.value == 'forward' then
                local heading = GetEntityHeading(PlayerPedId())
                SetEntityHeading(PlayerPedId(), heading + 10.0)
            else
                local heading = GetEntityHeading(PlayerPedId())
                SetEntityHeading(PlayerPedId(), heading - 10.0)
            end
        end)
        HeightSlider = MainBodyMenu:RegisterElement('arrows', {
            label = "Height",
            start = 5,
            options = Config.Heights
        }, function(data)
            if data.value == 1 then
                data.value = 1.0
            end

            SetPedScale(PlayerPedId(), data.value)
            SelectedAttributeElements['Height'] = { value = data.value }
            -- This gets triggered whenever the arrow selected value changes
        end)

        BodySlider   = MainBodyMenu:RegisterElement('slider', {
            label = "Body Type",
            start = 0,
            min = 1,
            max = #BODYTYPES,
            steps = 1,
        }, function(data)
            -- This gets triggered whenever the sliders selected value changes
            local Size = data.value
            SelectedAttributeElements['BodyType'] = { hash = BODYTYPES[Size] }

            EquipMetaPedOutfit(PlayerPedId(), BODYTYPES[Size])
        end)

        ChestSlider  = MainBodyMenu:RegisterElement('slider', {
            label = "Chest Size",
            start = 0,
            min = 1,
            max = #CHESTTYPE,
            steps = 1,
        }, function(data)
            -- This gets triggered whenever the sliders selected value changes
            local Size = data.value
            SelectedAttributeElements['ChestSize'] = { hash = CHESTTYPE[Size] }
            EquipMetaPedOutfit(PlayerPedId(), CHESTTYPE[Size])
        end)

        WaistSlider  = MainBodyMenu:RegisterElement('slider', {
            label = "Waist Size",
            start = 0,
            min = 1,
            max = #WAISTTYPES,
            steps = 1,
        }, function(data)
            -- This gets triggered whenever the sliders selected value changes
            local Size = data.value
            SelectedAttributeElements['WaistSize'] = { hash = WAISTTYPES[Size] }
            EquipMetaPedOutfit(PlayerPedId(), WAISTTYPES[Size])
        end)

        ForearmGrid1 = MainBodyMenu:RegisterElement('gridslider', {
            leftlabel = 'Forearm Size -',
            rightlabel = 'Forearm Size +',
            toplabel = 'Upper Arm Size +',
            bottomlabel = 'Upper Arm Size -',
            maxx = 1,
            maxy = 1,
            arrowsteps = 10,
            precision = 1
        }, function(data)

            SetCharExpression(PlayerPedId(), 8420, tonumber(data.value.x))
            SetCharExpression(PlayerPedId(), 46032, tonumber(data.value.y))
            SelectedAttributeElements['ForearmSize'] = { value = tonumber(data.value.x), hash = 8420 }
            SelectedAttributeElements['UpArmSize'] = { value = tonumber(data.value.y), hash = 46032 }

            UpdatePedVariation(PlayerPedId())
        end)

        LegGrid      = MainBodyMenu:RegisterElement('gridslider', {
            leftlabel = 'Calves Size -',
            rightlabel = 'Calves Size +',
            toplabel = 'Thighs Size +',
            bottomlabel = 'Thighs Size -',
            maxx = 1,
            maxy = 1,
            arrowsteps = 10,
            precision = 1
        }, function(data)
            SetCharExpression(PlayerPedId(), 42067, tonumber(data.value.x))
            SetCharExpression(PlayerPedId(), 64834, tonumber(data.value.y))
            SelectedAttributeElements['CalvesSize'] = { value = tonumber(data.value.x), hash = 42067 }
            SelectedAttributeElements['ThighsSize'] = { value = tonumber(data.value.y), hash = 64834 }
            UpdatePedVariation(PlayerPedId())
        end)


        WaistGrid = MainBodyMenu:RegisterElement('gridslider', {
            leftlabel = 'Waist Width -',
            rightlabel = 'Waist Width +',
            toplabel = 'Hip Width +',
            bottomlabel = 'Hip Width -',
            maxx = 1,
            maxy = 1,
            arrowsteps = 10,
            precision = 1
        }, function(data)
            SetCharExpression(PlayerPedId(), 50460, tonumber(data.value.x))
            SetCharExpression(PlayerPedId(), 49787, tonumber(data.value.y))
            SelectedAttributeElements['WaistWidth'] = { value = tonumber(data.value.x), hash = 50460 }
            SelectedAttributeElements['HipWidth'] = { value = tonumber(data.value.y), hash = 49787 }
            UpdatePedVariation(PlayerPedId())
        end)
    end
end
