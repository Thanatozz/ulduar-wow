local UA = UlduarAbilitiesUI

function UA.CreateScrollList(parent, name, rows, rowHeight, update)
    local scroll = CreateFrame("ScrollFrame", name, parent, "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 8, -38)
    scroll:SetPoint("BOTTOMRIGHT", -26, 35)
    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, update)
    end)
    scroll.visibleRows = rows
    scroll.rowHeight = rowHeight
    return scroll
end
