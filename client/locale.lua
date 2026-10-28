-- Character-owned keys use Core's account-scoped locale and English fallback.
CharacterV2Locale = {}
local english = {}
function CharacterV2Locale.Register(locale, translations)
    if locale == 'en_us' then english = translations end
    return exports['feather-core']:RegisterLocale(locale, translations)
end
function CharacterV2Locale.Text(key)
    local called, result = pcall(function() return exports['feather-core']:TranslateLocale(0, key) end)
    local text = called and type(result) == 'table' and result.ok and result.value
    if type(text) == 'string' and text ~= ''
        and not text:match('^Translation %[') and not text:match('^Locale %[') then return text end
    return english[key] or english['character.hair.style'] or 'Style'
end
