-- Variables for current XP and required XP for the next level
local currentXP, previousXP, nextLevelXP, xpAtLogin

-- Create a frame to display the information
local xpFrame = CreateFrame("Frame", "CurrentXPFrame", UIParent)
xpFrame:SetSize(200, 30)
xpFrame:SetPoint("TOP", UIParent, "TOP", 0, -50)  -- Position it at the top

-- Text element to display the XP info
local xpText = xpFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
xpText:SetPoint("CENTER", xpFrame, "CENTER")

-- Function to update the XP display
local function updateXPDisplay()
    currentXP = UnitXP("player")
    nextLevelXP = UnitXPMax("player")
    local progressPercentage = (currentXP / nextLevelXP) * 100
    xpText:SetText(string.format("XP: %d/%d (%.1f%%)", currentXP, nextLevelXP, progressPercentage))
end

-- Register for XP updates and leveling up
xpFrame:RegisterEvent("PLAYER_XP_UPDATE")
xpFrame:RegisterEvent("PLAYER_LEVEL_UP")
xpFrame:RegisterEvent("PLAYER_LOGIN")

-- Event handling
xpFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_XP_UPDATE" or event == "PLAYER_LEVEL_UP" or event == "PLAYER_LOGIN" then
        -- Capture the current XP as the previous XP before updating it
        previousXP = currentXP
        updateXPDisplay()
    end
end)






-- Rolling tracker
-- Variables and data structures
local xpHistory = {}  -- A table to store XP gains and their timestamps
local ROLLING_WINDOW = 60  -- 60 minutes * 60 seconds

-- Create a frame to display the rolling XP gain
local rollingXpFrame = CreateFrame("Frame", "RollingXPFrame", UIParent)
rollingXpFrame:SetSize(250, 30)
rollingXpFrame:SetPoint("TOP", UIParent, "TOP", 0, -80)  -- Position it below the other frame

local rollingXpText = rollingXpFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
rollingXpText:SetPoint("CENTER", rollingXpFrame, "CENTER")
rollingXpText:SetText("Rolling XP (last hour): 0")

-- Function to update the rolling XP display
local function updateRollingXPDisplay()
    local currentTime = time()
    local totalXpInLastHour = 0

    -- Remove outdated entries and sum XP from the valid ones
    for i = #xpHistory, 1, -1 do
        if currentTime - xpHistory[i].timestamp <= ROLLING_WINDOW then
            totalXpInLastHour = totalXpInLastHour + xpHistory[i].xp
        else
            table.remove(xpHistory, i)
        end
    end
    
    rollingXpText:SetText(string.format("Rolling XP (last hour): %d", totalXpInLastHour))
end

-- Register for XP updates
rollingXpFrame:RegisterEvent("PLAYER_XP_UPDATE")
rollingXpFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_XP_UPDATE" then
        currentXP = UnitXP("player")
        
        -- Calculate XP gain using the stored previousXP value
        local xpGain = currentXP - previousXP

        print("Previous XP: ", previousXP)
        print("Current XP: ", currentXP)
        print("XP Gained: ", xpGain)

        if xpGain > 0 then
            table.insert(xpHistory, {xp = xpGain, timestamp = time()})
            updateRollingXPDisplay()
        end
    end
end)

local function scheduleRollingXPUpdate()
    updateRollingXPDisplay()
    C_Timer.After(10, scheduleRollingXPUpdate)
end

scheduleRollingXPUpdate()




