FeatherCore = exports['feather-core'].initiate()
FeatherMenu = exports['feather-menu'].initiate()

MyMenu = FeatherMenu:RegisterMenu('feather:character:menu', {
    top = '1%',
    left = '1%',
    ['720width'] = '500px',
    ['1080width'] = '600px',
    ['2kwidth'] = '700px',
    ['4kwidth'] = '900px',
    style = {
    },
    contentslot = {
        style = { --This style is what is currently making the content slot scoped and scrollable. If you delete this, it will make the content height dynamic to its inner content.
            ['height'] = '700px',
            ['width'] = '500px',
            ['min-height'] = '500px'
        }
    },
    draggable = false,
    canclose = true
})