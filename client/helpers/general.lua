function DrawText(text, x, y, fontscale, fontsize, r, g, b, alpha, textcentred, shadow)
    local str = CreateVarString(10, "LITERAL_STRING", text)
    SetTextScale(fontscale, fontsize)
    SetTextColor(r, g, b, alpha)
    SetTextCentre(textcentred)
    if shadow then
        SetTextDropshadow(1, 0, 0, 255)
    end
    SetTextFontForCurrentCommand(6)
    DisplayText(str, x, y)
end