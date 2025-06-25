--[[
	The look of the buttons/numbers/arrow can be altered by adding this addon to the
	OptionalDeps of an external addon which then overrides the functions under the "Overridables" header.
]]

local _, addon = ...
BossesKilled = addon

function addon:PLAYER_LOGIN()
	-- Hook raid finder frame's onshow and onhide
	if RaidFinderQueueFrame and RaidFinderQueueFrame_SetRaid then
		local function myRaidFinderFrame_OnShow(frame)
			self:CreateButtons(frame, GetNumRFDungeons, GetRFDungeonInfo, RaidFinderQueueFrame_SetRaid)
			self:UpdateButtonsAndTooltips(frame)
			self:UpdateQueueStatuses()
			self.UpdateArrow()
			self:RegisterEvent("LFG_UPDATE")
			self.LFG_UPDATE = self.UpdateQueueStatuses -- Our event dispatcher calls functions like addon[eventName](...), so point it to the right update function
		end

		local function myRaidFinderFrame_OnHide(frame)
			self:UnregisterEvent("LFG_UPDATE")
		end

		RaidFinderQueueFrame:HookScript("OnShow", myRaidFinderFrame_OnShow)
		RaidFinderQueueFrame:HookScript("OnHide", myRaidFinderFrame_OnHide)
		hooksecurefunc("RaidFinderQueueFrame_SetRaid", self.UpdateArrow)
	end
end
addon:RegisterEvent("PLAYER_LOGIN")

-- Creates the buttons. LFR and Flex use different functions and dropdown menus so take them as arguments
function addon:CreateButtons(parentFrame, DungeonAmountFunc, DungeonInfoFunc, SetDropdownMenuFunc)
	local scale = self:GetButtonScale(DungeonAmountFunc())

	if not parentFrame.BossesKilledButtons then
		parentFrame.BossesKilledButtons = {}
	end
	local buttons = parentFrame.BossesKilledButtons

	local dungeonIDs = {}
	for i = 1, DungeonAmountFunc() do
		local id, name = DungeonInfoFunc(i)
		local isAvailable, isAvailableToPlayer = IsLFGDungeonJoinable(id)
		if isAvailable and isAvailableToPlayer and self.raidData[id] then
			table.insert(dungeonIDs, id)
		end
	end

	table.sort(dungeonIDs)

	for _, id in ipairs(dungeonIDs) do
		local name = select(2, DungeonInfoFunc(id))
		if not buttons[id] then
			local button = self:CreateButton(parentFrame, scale)
			buttons[id] = button

			button.dungeonID = id
			button.dungeonName = name

			parentFrame.lastButton = button

			button.number = self:CreateNumberFontstring(button)

			button:SetScript("OnEnter", function(this)
				if this.tooltip then
					self:ShowTooltip(this)
				end
			end)

			button:SetScript("OnClick", function(this)
				SetDropdownMenuFunc(this.dungeonID)
				self.UpdateArrow()
				this:SetChecked(this.checked)
			end)

			button.checked = false
		end
	end
end


---------------------------------------- Overridables ----------------------------------------

-- Must return a CheckButton, or implement :SetChecked() and support OnClick scripts. Not 100% right now if anything else
function addon:CreateButton(parent, scale)
	local button = CreateFrame("CheckButton", parent:GetName().."BossesKilledButton"..tostring(id), parent, "CommunitiesFrameTabTemplate") -- CommunitiesGuildPerksButtonTemplate SpellBookSkillLineTabTemplate
	button:Show()

	if parent.lastButton then
		button:SetPoint("TOPLEFT", parent.lastButton, "BOTTOMLEFT", 0, -13) -- -15
	else
		local x = 3
		-- SocialTabs compatibility
		if C_AddOns.IsAddOnLoaded("SocialTabs") then
			x = x + ceil(32 / scale)
		end

		button:SetPoint("TOPLEFT", parent, "TOPRIGHT", x, -20) -- -50
	end

	button:SetScale(scale)
	button:SetWidth(32) -- 66
	button:SetHeight(32) -- 37

	-- Need to find the button's texture in the regions so we can resize it. I don't like this part, but I can't think of a better way in case it's not the first region returned. (Is it ever not?)
	for _, region in ipairs({button:GetRegions()}) do
		
		if type(region) ~= "userdata" and region.GetTexture and region:GetTexture() == "Interface\\Icons\\UI_Chat" then
			region:SetWidth(32) -- Originally 64 (64 + 24)
			region:SetHeight(32) -- 70
			break
		end
		
		--[[ if type(region) ~= "userdata" then
			region:SetWidth(0.1) -- Originally 64 (64 + 24) 120          0.1
			region:SetHeight(30) -- 70           30
			break
		end ]]
	end

	return button
end

function addon:GetButtonScale(numDungeons)
	-- Ok, I still don't understand anything about the positioning and sizing of stuff in WoW, but the target frame is about 280'ish tall and buttons 32 and who gives a shit about margins and aaargh I'm going crazy /headexplode
	-- Magic numbers! There's really no method to the madness, these numbers just happen to look ok
	return min(480 / (numDungeons * 5), 1) -- 24 17      480
end

-- Must return a fontstring
function addon:CreateNumberFontstring(parentButton)
	local number = parentButton:CreateFontString(parentButton:GetName().."Number", "OVERLAY", "SystemFont_Outline")
	number:SetPoint("TOPLEFT", -4, 4)
	number:SetPoint("BOTTOMRIGHT", 5, -5)
	return number
end

-- Must return a texture, which will be pointing to selected dungeon's button
function addon:CreateArrow()
	local arrow = GroupFinderFrame:CreateTexture("BossesKilledArrow", "ARTWORK")
	arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
	arrow:SetTexCoord(1, 0, 0, 1) -- This somehow turns the arrow other way around. Magic. /shrug
	arrow:SetSize(32, 32) -- Originally 16, 16
	arrow:Hide()
	return arrow
end

--------------------------------------- Update functions -------------------------------------

function addon:UpdateButtonsAndTooltips(parentFrame)
	local buttons = parentFrame.BossesKilledButtons

	for id, button in pairs(buttons) do
		local numKilled = 0

		-- GetLFGDungeonNumEncounters returns the full set of bosses for the whole raid, while LFR and Flex raids
		-- are split into several separate raids, so get the amount of bosses and where to start from from our data file
		local index = self.raidData[id].startFrom
		local numEncounters = self.raidData[id].numEncounters

		-- Tooltip format:
		--     Button.tooltip = {
		--        { -- #1
		--            text = "Text for the button",
		--            color = { redValueFloat, greenValueFloat, blueValueFloat } -- Omit to get default color
		--        },
		--        {...} -- #2 etc etc
		--     }
		local tooltip = {{text = button.dungeonName}} -- Set up tooltip data with the dungeon name
		for i = index, numEncounters + index - 1 do
      
            if id == 847 and i == 3 then
				i = 7
			end

            if id == 846 and i == 4 then
                i = 3
            end
            if id == 846 and i == 6 then
                i = 8
            end

            if id == 848 and i == 7 then
                i = 4
            end
            if id == 848 and i == 8 then
                i = 6
            end    
      
            if id == 984 and i == 9 then
                i = 11
            end
            if id == 985 and i == 10 then
                i = 9
            end
            if id == 985 and i == 11 then
                i = 10
            end
      
			local encounterLine = {}
			local bossName, _, isDead = GetLFGDungeonEncounterInfo(id, i)
            
			if isDead then
				--[[ if ENABLE_COLORBLIND_MODE == "0" then ]] -- TODO: figure out if it's 0/false/null when not set
					encounterLine.color = {RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b}
				--[[ end ]]
                if bossName == nil then
                    bossName = "bossname"
                    encounterLine.text = "Dead - "..bossName
                else 
				    encounterLine.text = "Dead - "..bossName
                    numKilled = numKilled + 1
                end
			else
				--[[ if ENABLE_COLORBLIND_MODE == "0" then ]]
					encounterLine.color = {GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b}
				--[[ end ]]
                if bossName == nil then
                    bossName = "bossname"
                    encounterLine.text = "Alive - "..bossName
                else 
				    encounterLine.text = "Alive - "..bossName
                end
			end
			table.insert(tooltip, encounterLine)
		end
		button.tooltip = tooltip

		local statusString = numKilled.."/"..numEncounters
		if ENABLE_COLORBLIND_MODE == "1" then
			button.number:SetFormattedText("|c00ffffff%s|r", statusString)
		else
			button.number:SetFormattedText(self.textColorTable[statusString], statusString)
		end
	end
end

function addon:UpdateQueueStatuses()
	for id, button in pairs(RaidFinderQueueFrame.BossesKilledButtons) do
		local mode = GetLFGMode(LE_LFG_CATEGORY_RF, id);
		if mode == "queued" or mode == "listed" or mode == "rolecheck" or mode == "suspended" then
			button:SetChecked(true)
			button.checked = true -- This is for the PostClick script earlier
		else
			button:SetChecked(false)
			button.checked = false
		end
	end
end

-- Not a method because it's used as callback for hooksecurefuncs so it would get the wrong "self"
function addon.UpdateArrow()
	local self = addon

	if not self.arrow then
		self.arrow = self:CreateArrow()
	end

	local parent
	if RaidFinderQueueFrame and RaidFinderQueueFrame:IsVisible() then
		parent = RaidFinderQueueFrame
	else
		self.arrow:Hide()
		return
	end

	if parent.raid and parent.BossesKilledButtons[parent.raid] then
		local button = parent.BossesKilledButtons[parent.raid]
		self.arrow:SetParent(button) -- Re-set the parent so we inherit the scale, so our smaller LFR buttons get a smaller arrow
		self.arrow:SetPoint("LEFT", button, "RIGHT")
		self.arrow:Show()
	end
end

--------------------------------- Tooltip and colorization stuff -----------------------------

function addon:ShowTooltip(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	for i = 1, #button.tooltip do
		tooltip = button.tooltip[i]
		if tooltip.color then
			GameTooltip:AddLine(tooltip.text, unpack(tooltip.color))
		else
			GameTooltip:AddLine(tooltip.text)
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("<Click to select this raid>")
	GameTooltip:AddLine(" ")
	if ENABLE_COLORBLIND_MODE == "1" then -- TODO: Remove duplicates. Only check for not ENABLE_COLORBLIND_MODE in which case add the first AddLine. After outside of if, add second AddLine
		GameTooltip:AddLine("(Button lights up if you're queued for this raid)")
	else
		GameTooltip:AddLine("(|c00ff0000Red|r for killed bosses, |c0000ff00green|r for alive ones,")
		GameTooltip:AddLine(" button lights up if you're queued for this raid)")
	end
	GameTooltip:Show()
end

-- gets passed a "x/y" STRING. No sanity checks so make sure the calling function feeds it the expected format.
-- the vararg gets passed color triples, eg. 0.0,1.0,0.0,  1.0,0.0,0.0 (green to red)
function addon:TextColorGradient(str_percent, ...)
	local num = select("#", ...)
	local low, high = strmatch(str_percent, "(%d+)/(%d+)")
	local percent = (low + 0) / (high + 0) -- implicit cast to number, cheaper than tonumber
	local r, g, b

	if percent >= 1 then
		r, g, b = select(num - 2, ...), select(num - 1, ...), select(num, ...)
		return format("|cff%02x%02x%02x%%s|r", r * 255, g * 255, b * 255)
	elseif percent <= 0 then
		r, g, b = ...
		return format("|cff%02x%02x%02x%%s|r", r * 255, g * 255, b * 255)
	end

	local segment, relperc = math.modf(percent * (num / 3 - 1))
	local r1, g1, b1, r2, g2, b2
	r1, g1, b1 = select((segment * 3) + 1, ...), select((segment * 3) + 2, ...), select((segment * 3) + 3, ...)
	r2, g2, b2 = select((segment * 3) + 4, ...), select((segment * 3) + 5, ...), select((segment * 3) + 6, ...)

	if not r2 or not g2 or not b2 then
		r, g, b = r1, g1, b1
	else
		r, g, b = r1 + (r2 - r1) * relperc,
		          g1 + (g2 - g1) * relperc,
		          b1 + (b2 - b1) * relperc
	end
	return format("|cff%02x%02x%02x%%s|r", r * 255, g * 255, b * 255)
end

-- Use a memoization table so each x/y colorstring is only computed once and then does a simple lookup
addon.textColorTable = setmetatable({}, {__index = function(t, k)
	local colorStr = addon:TextColorGradient(k, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, -- "From" color
	                                            RED_FONT_COLOR.r,   RED_FONT_COLOR.g,   RED_FONT_COLOR.b)   -- "To" color
	rawset(t, k, colorStr)
	return colorStr
end})
