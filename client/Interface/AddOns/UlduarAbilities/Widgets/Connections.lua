local UA = UlduarAbilitiesUI

function UA.Connection(parent, x, y, width, height)
    local texture = parent:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    texture:SetVertexColor(0.65, 0.5, 0.25, 0.45)
    texture:SetPoint("TOPLEFT", x, y)
    texture:SetSize(width, height)
    return texture
end
