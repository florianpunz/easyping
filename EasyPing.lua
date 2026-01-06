-- EasyPing: Zeigt Ping-Latenz unter der Minimap an

-- Gespeicherte Variablen
EasyPingDB = EasyPingDB or {
    offsetX = 0,
    offsetY = -2,
    locked = false
}

-- Frame erstellen
local frame = CreateFrame("Frame", "EasyPingFrame", UIParent)
frame:SetSize(60, 20)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

-- Text erstellen
local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
text:SetPoint("CENTER")
text:SetTextColor(1, 1, 1)

-- Hintergrund (optional)
local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(true)
bg:SetColorTexture(0, 0, 0, 0.5)

-- Funktion zur Positionierung
local function UpdatePosition()
    frame:ClearAllPoints()
    frame:SetPoint("TOP", TimeManagerClockButton or Minimap, "BOTTOM", EasyPingDB.offsetX, EasyPingDB.offsetY)
end

-- Funktion zum Aktualisieren der Ping-Anzeige
local function UpdatePing()
    local _, _, latencyHome, latencyWorld = GetNetStats()
    local ping = latencyWorld or latencyHome or 0
    
    -- Farbe basierend auf Ping-Wert
    local r, g, b
    if ping < 100 then
        r, g, b = 0, 1, 0  -- Grün
    elseif ping < 200 then
        r, g, b = 1, 1, 0  -- Gelb
    else
        r, g, b = 1, 0, 0  -- Rot
    end
    
    text:SetText(ping .. " ms")
    text:SetTextColor(r, g, b)
end

-- Drag & Drop Funktionalität
frame:SetScript("OnDragStart", function(self)
    if not EasyPingDB.locked then
        self:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Relative Position speichern
    local anchor = TimeManagerClockButton or Minimap
    local scale = self:GetEffectiveScale() / anchor:GetEffectiveScale()
    local x = (self:GetLeft() + self:GetWidth()/2) * scale - (anchor:GetLeft() + anchor:GetWidth()/2)
    local y = (self:GetTop() - self:GetHeight()/2) * scale - (anchor:GetBottom())
    
    EasyPingDB.offsetX = math.floor(x + 0.5)
    EasyPingDB.offsetY = math.floor(y + 0.5)
    
    UpdatePosition()
    print("|cFF00FF00[EasyPing]|r Position saved: X=" .. EasyPingDB.offsetX .. ", Y=" .. EasyPingDB.offsetY)
end)

-- Update-Timer (alle 1 Sekunde)
frame:SetScript("OnUpdate", function(self, elapsed)
    self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
    if self.timeSinceLastUpdate >= 1 then
        UpdatePing()
        self.timeSinceLastUpdate = 0
    end
end)

-- Initiales Update
UpdatePosition()
UpdatePing()

-- Slash-Command registrieren
SLASH_EASYPING1 = "/easyping"
SlashCmdList["EASYPING"] = function(msg)
    msg = string.lower(msg or "")
    
    if msg == "reset" then
        print("|cFF00FF00[EasyPing]|r Reloading addon...")
        EasyPingDB.offsetX = 0
        EasyPingDB.offsetY = -2
        UpdatePing()
        UpdatePosition()
        print("|cFF00FF00[EasyPing]|r Reset complete!")
    elseif msg == "lock" then
        EasyPingDB.locked = true
        print("|cFF00FF00[EasyPing]|r Position locked!")
    elseif msg == "unlock" then
        EasyPingDB.locked = false
        print("|cFF00FF00[EasyPing]|r Position unlocked! Drag to reposition.")
    elseif msg:match("^move%s+") then
        local x, y = msg:match("^move%s+([-%d]+)%s+([-%d]+)$")
        if x and y then
            EasyPingDB.offsetX = tonumber(x)
            EasyPingDB.offsetY = tonumber(y)
            UpdatePosition()
            print("|cFF00FF00[EasyPing]|r Position updated: X=" .. EasyPingDB.offsetX .. ", Y=" .. EasyPingDB.offsetY)
        else
            print("|cFFFF0000[EasyPing]|r Invalid format! Use: /easyping move X Y")
        end
    else
        print("|cFF00FF00[EasyPing]|r Available commands:")
        print("  /easyping reset - Reset position to default")
        print("  /easyping lock - Lock position")
        print("  /easyping unlock - Unlock position (drag to move)")
        print("  /easyping move X Y - Move to specific position (e.g. /easyping move 0 -5)")
    end
end

-- Tooltip beim Hover
frame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    local _, _, latencyHome, latencyWorld = GetNetStats()
    GameTooltip:AddLine("Network Latency", 1, 1, 1)
    GameTooltip:AddDoubleLine("Login Server:", latencyHome .. " ms", 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Game Server:", latencyWorld .. " ms", 1, 1, 1, 1, 1, 1)
    GameTooltip:AddLine(" ")
    if EasyPingDB.locked then
        GameTooltip:AddLine("|cFFFF6B6BLocked|r - Use /easyping unlock to move", 0.7, 0.7, 0.7)
    else
        GameTooltip:AddLine("|cFF6BCB77Unlocked|r - Drag to reposition", 0.7, 0.7, 0.7)
    end
    GameTooltip:Show()
end)

frame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- Lade-Bestätigung
print("|cFF00FF00[EasyPing]|r Addon successfully loaded! Use /easyping for commands.")