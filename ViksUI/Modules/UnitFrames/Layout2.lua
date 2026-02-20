local T, C, L = unpack(ViksUI)
if C.unitframe.enable ~= true then return end

print("|cff00ff00Layout2.lua: Starting to load...|r")

local _, ns = ...
local oUF = ns.oUF

if not oUF then
	print("|cffff0000Layout2.lua: oUF not found!|r")
	return
end

-- Store reference to CreateShadow from Layout.lua
local CreateShadow

----------------------------------------------------------------------------------------
--	LAYOUT2 OPTIONS
--	Customize Layout2 behavior with these easy-to-toggle options
----------------------------------------------------------------------------------------

local Layout2Options = {
	-- Use portrait-style borders for secondary frames (pet, target's target, focus, etc.)
	-- Set to true to use SetTemplate("Invisible") + SetBackdropColor like portrait
	-- Set to false to use default SetTemplate("Default") borders
	use_portrait_borders = true,
}

----------------------------------------------------------------------------------------
--	TAG CONFIGURATION
--	Configure which tags appear on player and target frames
--	Set enable = false to hide a tag
--	Modify the "tag" field to change what information is displayed
----------------------------------------------------------------------------------------

local Layout2Tags = {
	----- PLAYER FRAME -----
	player = {
		health_bar = {
			enable = true,
			top_left = {
				enable = true,
				tag = "[drk:color2][name][drk:afkdnd]",
				font_type = "name_font",
				x = 2,
				y = -1,
				justify = "LEFT",
			},
			top_center = {
				enable = false,
				tag = "",
				font_type = "name_font",
				x = 0,
				y = -1,
				justify = "CENTER",
			},
			top_right = {
				enable = false,
				tag = "[drk:color2][drk:Shp]",
				font_type = "number_font",
				x = -2,
				y = -1,
				justify = "RIGHT",
			},
		},
		text_bar = {
			enable = true,
			bottom_left = {
				enable = true,
				tag = "[drk:color][drk:power2]",
				font_type = "number_font",
				x = 2,
				y = 1,
				justify = "LEFT",
			},
			bottom_center = {
				enable = false,
				tag = "",
				font_type = "name_font",
				x = 0,
				y = 1,
				justify = "CENTER",
			},
			bottom_right = {
				enable = true,
				-- tag = "[drk:color][cur|max]",
				font_type = "number_font",
				x = -2,
				y = 1,
				justify = "RIGHT",
			},
		},
	},
	
	----- TARGET FRAME -----
	target = {
		health_bar = {
			enable = true,
			top_left = {
				enable = true,
				tag = "[drk:level] [drk:color2][name][drk:afkdnd]",
				font_type = "name_font",
				x = 2,
				y = -1,
				justify = "LEFT",
			},
			top_center = {
				enable = false,
				tag = "",
				font_type = "name_font",
				x = 0,
				y = -1,
				justify = "CENTER",
			},
			top_right = {
				enable = true,
				tag = "[drk:color2][NameplateHealth]",
				font_type = "number_font",
				x = -2,
				y = -1,
				justify = "RIGHT",
			},
		},
		text_bar = {
			enable = true,
			bottom_left = {
				enable = true,
				tag = "[drk:color][drk:power2]",
				font_type = "number_font",
				x = 2,
				y = 1,
				justify = "LEFT",
			},
			bottom_center = {
				enable = false,
				tag = "",
				font_type = "name_font",
				x = 0,
				y = 1,
				justify = "CENTER",
			},
			bottom_right = {
				enable = true,
				tag = "[drk:color][NameplateHealth]",
				font_type = "number_font",
				x = -2,
				y = 1,
				justify = "RIGHT",
			},
		},
	},
}

-- Font Configuration
local Layout2Fonts = {
	name_font = {
		font = C.unitframe.UFNamefont or C.font.unit_frames_font,
		size = 26,
		style = "NONE",
	},
	number_font = {
		font = C.font.unit_frames_font,
		size = C.font.unit_frames_font_size,
		style = C.font.unit_frames_font_style,
	},
}

----------------------------------------------------------------------------------------
--	SHADOW CONFIGURATION
--	Controls drop shadows on text for better readability
--	Set enable = false to disable shadows
--	offset_x: horizontal shadow distance (positive = right, negative = left)
--	offset_y: vertical shadow distance (positive = up, negative = down)
----------------------------------------------------------------------------------------

local Layout2Shadow = {
	name_shadow = {
		enable = true,
		color = {0, 0, 0, 1},
		offset_x = 1,
		offset_y = -2,
	},
	number_shadow = {
		enable = false,
		color = {0, 0, 0, 1},
		offset_x = 1,
		offset_y = -1,
	},
}

----------------------------------------------------------------------------------------
--	LAYOUT2 CONFIGURATION
--	Main configuration for all Layout2 frame sizes, positions, and offsets
--	
--	TIPS FOR EDITING:
--	- layout2_w and layout2_h: Main frame dimensions (from Config)
--	- offset_x/offset_y: Position adjustments relative to parent frame
--	- frame_level: Drawing order (higher = on top)
--	- pet_offset_x: Horizontal distance from portrait to pet frame
--	- pet_offset_y: Vertical alignment adjustment for pet frame
----------------------------------------------------------------------------------------

local Layout2Config = {
	-- Health frame styling and size
	health = {
		width = C.unitframe.layout2_w,
		height = C.unitframe.layout2_h,
		texture = C.unitframe.layout2_health_texture,
		backdrop_color = C.media.border_color,
		frame_level = 6,
	},
	
	-- Power frame (mana, rage, energy, etc.) styling and size
	power = {
		width = C.unitframe.layout2_w,
		height = C.unitframe.layout2_h,
		texture = C.unitframe.layout2_power_texture,
		backdrop_color = C.media.border_color,
		frame_level = 5,
		offset_x = -6,  -- Position relative to health frame
		offset_y = -7,  -- Position relative to health frame
	},
	
	-- Text bar (below health/power) for additional info
	text_bar = {
		width = C.unitframe.layout2_w,
		height = C.unitframe.layout2_h,
		texture = C.unitframe.layout2_textbar_texture,
		texture_color = {0.125, 0.125, 0.125, 1},
		frame_level = 4,
		offset_x = 6,   -- Horizontal offset from health frame
		offset_y = 13,  -- Vertical offset below health frame
	},
	
	-- Portrait frame (player/target face)
	portrait = {
		size = C.unitframe.layout2_portrait,
		frame_level = 5,
		backdrop_color = C.media.border_color,
		texcoord = {0.15, 0.85, 0.15, 0.85},
		pet_offset_x = 40,  -- Distance from portrait RIGHT to pet frame (increase for more space)
		pet_offset_y = 0,   -- Vertical alignment for pet frame
	},
	
	-- Castbar positioning (below text bar)
	castbar = {
		offset_y = -6,  -- Space between text bar and castbar
	},
	
	-- Experience and Reputation bars (beside portrait)
	bars = {
		width = 3,      -- Width of experience/reputation bars
		spacing = -6,   -- Space between bars
		frame_level = 8, -- Behind health/power/text frames
	},
}

----------------------------------------------------------------------------------------
--	HELPER FUNCTIONS
----------------------------------------------------------------------------------------

local function GetCreateShadow()
	if CreateShadow then return CreateShadow end
	
	if _G.CreateShadow then
		CreateShadow = _G.CreateShadow
		return CreateShadow
	end
	
	CreateShadow = function(f)
		if f.shadow then return end
		local shadow = CreateFrame("Frame", nil, f, "BackdropTemplate")
		shadow:SetFrameLevel(1)
		shadow:SetFrameStrata(f:GetFrameStrata())
		shadow:SetPoint("TOPLEFT", -4, 4)
		shadow:SetPoint("BOTTOMRIGHT", 4, -4)
		shadow:SetBackdrop({
			edgeFile = "Interface\\AddOns\\ViksUI\\Media\\Other\\glowTex",
			edgeSize = 4,
			insets = { left = 3, right = 3, top = 3, bottom = 3 }
		})
		shadow:SetBackdropColor(0, 0, 0, 0)
		shadow:SetBackdropBorderColor(0, 0, 0, 1)
		f.shadow = shadow
		return shadow
	end
	
	return CreateShadow
end

-- Create a single tag (text) on a frame
local function CreateTag(self, parent, tagConfig, point)
	if not tagConfig or not tagConfig.enable or tagConfig.tag == "" then
		return nil
	end
	
	local fontType = tagConfig.font_type or "name_font"
	local font = Layout2Fonts[fontType]
	if not font then
		font = Layout2Fonts.name_font
	end
	
	local fontString = T.SetFontString(parent, font.font, font.size, font.style)
	fontString:SetJustifyH(tagConfig.justify or "LEFT")
	fontString:SetPoint(point, parent, point, tagConfig.x or 0, tagConfig.y or 0)
	
	-- Apply shadow based on font type
	if fontType == "name_font" and Layout2Shadow.name_shadow.enable then
		fontString:SetShadowColor(unpack(Layout2Shadow.name_shadow.color))
		fontString:SetShadowOffset(Layout2Shadow.name_shadow.offset_x, Layout2Shadow.name_shadow.offset_y)
	elseif fontType == "number_font" and Layout2Shadow.number_shadow.enable then
		fontString:SetShadowColor(unpack(Layout2Shadow.number_shadow.color))
		fontString:SetShadowOffset(Layout2Shadow.number_shadow.offset_x, Layout2Shadow.number_shadow.offset_y)
	end
	
	self:Tag(fontString, tagConfig.tag)
	return fontString
end

-- Apply all configured health bar tags
local function ApplyHealthBarTags(self, unit)
	if not Layout2Tags[unit] or not Layout2Tags[unit].health_bar then return end
	if not Layout2Tags[unit].health_bar.enable then return end
	
	local config = Layout2Tags[unit].health_bar
	if not self.Health then return end
	
	if config.top_left and config.top_left.enable then
		self.Health.TagTopLeft = CreateTag(self, self.Health, config.top_left, "TOPLEFT")
	end
	
	if config.top_center and config.top_center.enable then
		self.Health.TagTopCenter = CreateTag(self, self.Health, config.top_center, "TOP")
	end
	
	if config.top_right and config.top_right.enable then
		self.Health.TagTopRight = CreateTag(self, self.Health, config.top_right, "TOPRIGHT")
	end
	
	if config.show_missing_hp then
		self.Health.TagMissingHP = T.SetFontString(self.Health, Layout2Fonts.number_font.font, Layout2Fonts.number_font.size, Layout2Fonts.number_font.style)
		self.Health.TagMissingHP:SetPoint("CENTER", self.Health, "CENTER", 0, -8)
		self.Health.TagMissingHP:SetJustifyH("CENTER")
		
		if Layout2Shadow.number_shadow.enable then
			self.Health.TagMissingHP:SetShadowColor(unpack(Layout2Shadow.number_shadow.color))
			self.Health.TagMissingHP:SetShadowOffset(Layout2Shadow.number_shadow.offset_x, Layout2Shadow.number_shadow.offset_y)
		end
		
		self:Tag(self.Health.TagMissingHP, "[MissingHP]")
	end
end

-- Apply all configured text bar tags
local function ApplyTextBarTags(self, textFrame, unit)
	if not Layout2Tags[unit] or not Layout2Tags[unit].text_bar then return end
	if not Layout2Tags[unit].text_bar.enable then return end
	
	local config = Layout2Tags[unit].text_bar
	
	if config.bottom_left and config.bottom_left.enable then
		CreateTag(self, textFrame, config.bottom_left, "BOTTOMLEFT")
	end
	
	if config.bottom_center and config.bottom_center.enable then
		CreateTag(self, textFrame, config.bottom_center, "BOTTOM")
	end
	
	if config.bottom_right and config.bottom_right.enable then
		CreateTag(self, textFrame, config.bottom_right, "BOTTOMRIGHT")
	end
end

----------------------------------------------------------------------------------------
--	PLAYER FRAME PORTRAIT REFERENCE
--	Stored for use when positioning pet and target's target frames
----------------------------------------------------------------------------------------

local playerFramePortrait = nil

----------------------------------------------------------------------------------------
--	SECONDARY FRAME TEMPLATE APPLIER
--	Applies portrait-style borders to secondary frames (pet, target's target, etc.)
--	if use_portrait_borders option is enabled
----------------------------------------------------------------------------------------

local function ApplySecondaryFrameTemplate(frame)
	if Layout2Options.use_portrait_borders then
		frame:SetTemplate("Invisible")
		frame:SetBackdropColor(unpack(C.media.border_color))
		CreateShadow(frame)
	else
		frame:SetTemplate("Default")
	end
end

----------------------------------------------------------------------------------------
--	MAIN HOOK - RegisterStyle
--	This hooks into oUF's RegisterStyle function to apply Layout2 modifications
--	to the "Viks" style frames after they are created
----------------------------------------------------------------------------------------

local originalRegisterStyle = oUF.RegisterStyle

function oUF:RegisterStyle(styleName, sharedFunc)
	if styleName == "Viks" then
		local OriginalShared = sharedFunc
		CreateShadow = GetCreateShadow()
		
		local function SharedWithLayout2(self, unit)
			-- Call original Layout.lua function first
			OriginalShared(self, unit)
			
			-- Only apply Layout2 if enabled in config
			if not C.unitframe.layout2 then
				return self
			end
			
			local unitType = (unit and unit:find("arena%dtarget")) and "arenatarget"
				or (unit and unit:find("arena%d")) and "arena"
				or (unit and unit:find("boss%d")) and "boss" or unit
			
			-- Only modify player and target frames for Layout2 styling
			-- Secondary frames (pet, targettarget, focus, etc.) use ApplySecondaryFrameTemplate
			if unitType ~= "player" and unitType ~= "target" then
				-- Apply portrait-style borders to secondary frames if enabled
				if Layout2Options.use_portrait_borders and self.backdrop then
					ApplySecondaryFrameTemplate(self)
				end
				return self
			end
			
			-- ========== BACKDROP SETUP ==========
			-- Remove borders from main frame backdrop
			if self.backdrop then
				self.backdrop:SetBackdrop({edgeFile = nil})
				self.backdrop:SetBackdropBorderColor(0, 0, 0, 0)
			end
			
			-- ========== PORTRAIT SETUP ==========
			-- Create new Layout2 portrait (replaces default portrait)
			if self.Portrait and self.Portrait:GetParent() == self and not self.Portrait.isLayout2 then
				self.Portrait:Hide()
				self.Portrait = nil
			end
			
			self.Portrait = CreateFrame("Frame", self:GetName().."_Portrait", self, "BackdropTemplate")
			self.Portrait:SetSize(Layout2Config.portrait.size, Layout2Config.portrait.size)
			self.Portrait.isLayout2 = true
			
			if unitType == "player" then
				self.Portrait:SetPoint(unpack(C.position.unitframes.player_portrait_2))
			elseif unitType == "target" then
				self.Portrait:SetPoint(unpack(C.position.unitframes.target_portrait_2))
			end
			
			self.Portrait:SetFrameLevel(Layout2Config.portrait.frame_level)
			self.Portrait:SetTemplate("Invisible")
			self.Portrait:SetBackdropColor(unpack(C.media.border_color))
			self.Portrait:SetBackdropBorderColor(0, 0, 0, 0)
			CreateShadow(self.Portrait)
			
			self.Portrait.Icon = self.Portrait:CreateTexture(nil, "ARTWORK")
			self.Portrait.Icon:SetAllPoints()
			self.Portrait.Icon:SetTexCoord(unpack(Layout2Config.portrait.texcoord))
			
			-- Store player portrait reference AFTER creation for pet/target's target positioning
			if unitType == "player" then
				playerFramePortrait = self.Portrait
			end
			
			-- Apply class color to portrait border if enabled
			if C.unitframe.portrait_classcolor_border == true then
				if unitType == "player" then
					self.Portrait:SetBackdropColor(T.color.r, T.color.g, T.color.b)
				elseif unitType == "target" then
					self.Portrait:RegisterEvent("PLAYER_TARGET_CHANGED")
					self.Portrait:SetScript("OnEvent", function()
						local _, class = UnitClass("target")
						local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
						if color then
							self.Portrait:SetBackdropColor(color.r, color.g, color.b)
						else
							self.Portrait:SetBackdropColor(unpack(C.media.border_color))
						end
					end)
				end
			end
			
			-- ========== HEALTH FRAME SETUP ==========
			local healthFrame = CreateFrame("Frame", self:GetName().."_HealthFrame", self, "BackdropTemplate")
			healthFrame:SetSize(Layout2Config.health.width, Layout2Config.health.height)
			healthFrame:SetPoint("LEFT", self, "LEFT", 0, 0)
			healthFrame:SetFrameLevel(Layout2Config.health.frame_level)
			healthFrame:SetTemplate("Invisible")
			healthFrame:SetBackdropColor(unpack(C.media.border_color))
			CreateShadow(healthFrame)
			
			-- Move health bar into health frame
			if self.Health then
				self.Health:SetParent(healthFrame)
				self.Health:ClearAllPoints()
				self.Health:SetAllPoints()
				self.Health:SetStatusBarTexture(C.unitframe.layout2_health_texture)
				self.Health:SetFrameLevel(Layout2Config.health.frame_level)
				self.Health.colorTapping = true
				self.Health.colorDisconnected = true
				self.Health:SetStatusBarColor(0.2, 0.2, 0.2, 1)
				
				if not self.Health.bg then
					self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
					self.Health.bg:SetAllPoints()
					self.Health.bg:SetTexture(C.unitframe.layout2_health_texture)
					self.Health.bg:SetVertexColor(0.1, 0.1, 0.1, 0.2)
				end
			end
			
			-- Hide original health bar tags
			if self.Health and self.Health.value then self.Health.value:Hide() end
			if self.Health and self.Health.short_value then self.Health.short_value:Hide() end
			if self.Info then self.Info:Hide() end
			if self.Level then self.Level:Hide() end
			
			if C.unitframe.portrait_type == "OVERLAY" then
				local healthTex = self.Health:GetStatusBarTexture()
				self.Portrait:ClearAllPoints()
				self.Portrait:SetPoint("TOPLEFT", healthTex, "TOPLEFT", 0, 0)
				self.Portrait:SetPoint("BOTTOMRIGHT", healthTex, "BOTTOMRIGHT", 0, 1)
				self.Portrait:SetFrameLevel(self.Health:GetFrameLevel())
				-- self.Portrait.backdrop:Hide()
				self.Portrait:SetAlpha(0.5)
			end
			
			-- Apply custom health bar tags from Layout2Tags
			ApplyHealthBarTags(self, unitType)
			
			-- ========== POWER FRAME SETUP ==========
			if self.Power then
				local powerFrame = CreateFrame("Frame", self:GetName().."_PowerFrame", self, "BackdropTemplate")
				powerFrame:SetSize(Layout2Config.power.width, Layout2Config.power.height)
				
				if unitType == "player" then
					powerFrame:SetPoint("TOPLEFT", self.Health, "TOPLEFT", Layout2Config.power.offset_x, Layout2Config.power.offset_y)
				elseif unitType == "target" then
					powerFrame:SetPoint("TOPRIGHT", self.Health, "TOPRIGHT", -Layout2Config.power.offset_x, Layout2Config.power.offset_y)
				end
				
				powerFrame:SetFrameLevel(Layout2Config.power.frame_level)
				powerFrame:SetTemplate("Default")
				powerFrame:SetBackdropColor(unpack(C.media.border_color))
				CreateShadow(powerFrame)
				
				-- Move power bar into power frame
				self.Power:SetParent(powerFrame)
				self.Power:ClearAllPoints()
				self.Power:SetAllPoints()
				self.Power:SetStatusBarTexture(C.unitframe.layout2_power_texture)
				self.Power:SetFrameLevel(Layout2Config.power.frame_level)
				self.Power.colorClass = true
				
				if not self.Power.bg then
					self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
					self.Power.bg:SetAllPoints()
					self.Power.bg:SetTexture(C.unitframe.layout2_power_texture)
					self.Power.bg:SetVertexColor(0.1, 0.1, 0.1, 0.2)
				end
				
				-- Hide original power bar tags
				if self.Power.value then self.Power.value:Hide() end
				if self.Power.short_value then self.Power.short_value:Hide() end
			end
			
			-- ========== TEXT BAR SETUP ==========
			local textFrame = CreateFrame("Frame", self:GetName().."_TextFrame", self, "BackdropTemplate")
			textFrame:SetSize(Layout2Config.text_bar.width, Layout2Config.text_bar.height)
			
			if unitType == "player" then
				textFrame:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", Layout2Config.text_bar.offset_x, Layout2Config.text_bar.offset_y)
			elseif unitType == "target" then
				textFrame:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", -Layout2Config.text_bar.offset_x, Layout2Config.text_bar.offset_y)
			end
			
			textFrame:SetFrameLevel(Layout2Config.text_bar.frame_level)
			textFrame:SetTemplate("Default")
			
			local textBarTexture = textFrame:CreateTexture(nil, "BACKGROUND")
			textBarTexture:SetAllPoints()
			textBarTexture:SetTexture(C.unitframe.layout2_textbar_texture)
			textBarTexture:SetVertexColor(unpack(Layout2Config.text_bar.texture_color))
			
			-- Apply custom text bar tags from Layout2Tags
			ApplyTextBarTags(self, textFrame, unitType)
			
			-- ========== CASTBAR REPOSITIONING ==========
			if self.Castbar then
				self.Castbar:ClearAllPoints()
				if unitType == "player" then
					self.Castbar:SetPoint("TOPLEFT", textFrame, "BOTTOMLEFT", 2, Layout2Config.castbar.offset_y)
					self.Castbar:SetWidth(Layout2Config.text_bar.width-4)
				elseif unitType == "target" then
					self.Castbar:SetPoint("TOPRIGHT", textFrame, "BOTTOMRIGHT", -2, Layout2Config.castbar.offset_y)
					self.Castbar:SetWidth(Layout2Config.text_bar.width-4)
				end
			end
			
			-- ========== EXPERIENCE & REPUTATION BARS REPOSITIONING ==========
			if self.Experience then
				self.Experience:ClearAllPoints()
				if unitType == "player" then
					self.Experience:SetPoint("TOPRIGHT", self.Portrait, "TOPLEFT", -2, -4)
					self.Experience:SetSize(Layout2Config.bars.width, Layout2Config.portrait.size-14)
					self.Experience:SetFrameLevel(Layout2Config.bars.frame_level)
				end
			end
			
			if self.Reputation then
				self.Reputation:ClearAllPoints()
				if unitType == "player" then
					self.Reputation:SetPoint("TOPRIGHT", self.Experience, "TOPLEFT", Layout2Config.bars.spacing, 0)
					self.Reputation:SetSize(Layout2Config.bars.width, Layout2Config.portrait.size-14)
					self.Reputation:SetFrameLevel(Layout2Config.bars.frame_level)
				end
			end
			
			-- ========== CLASS BARS REPOSITIONING ==========
			-- Adjust all class-specific bars (ComboPoints, Runes, Chi, etc.) to match Layout2 width
			if unitType == "player" then
				-- Runes (Death Knight)
				if self.Runes then
					self.Runes:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
					self.Runes:SetSize((C.unitframe.layout2_w - 3), 7)
					
					for i = 1, 6 do
						if self.Runes[i] then
							self.Runes[i]:SetSize(((C.unitframe.layout2_w - 3) - 5) / 6, 7)
						end
						if i == 1 then
							self.Runes[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
						end
					end
				end
				
				-- ComboPoints (Rogue, Druid)
				if self.ComboPoints then
					self.ComboPoints:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
					self.ComboPoints:SetSize((C.unitframe.layout2_w - 3), 7)
					
					for i = 1, 7 do
						if self.ComboPoints[i] then
							self.ComboPoints[i]:SetSize(((C.unitframe.layout2_w - 3) - 5) / 7, 7)
						end
						if i == 1 then
							self.ComboPoints[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
						end
					end
				end
				
				-- HarmonyBar / Chi (Monk)
				if self.HarmonyBar then
					self.HarmonyBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
					self.HarmonyBar:SetSize((C.unitframe.layout2_w - 3), 7)
					
					for i = 1, 6 do
						if self.HarmonyBar[i] then
							self.HarmonyBar[i]:SetSize(((C.unitframe.layout2_w - 3) - 5) / 6, 7)
						end
						if i == 1 then
							self.HarmonyBar[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
						end
					end
				end
				
				-- Stagger (Monk)
				if self.Stagger then
					self.Stagger:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
					self.Stagger:SetSize((C.unitframe.layout2_w - 3), 7)
				end
				
				-- HolyPower (Paladin)
				if self.HolyPower then
					self.HolyPower:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
					self.HolyPower:SetSize((C.unitframe.layout2_w - 3), 7)
					
					for i = 1, 5 do
						if self.HolyPower[i] then
							self.HolyPower[i]:SetSize(((C.unitframe.layout2_w - 3) - 4) / 5, 7)
						end
						if i == 1 then
							self.HolyPower[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
						end
					end
				end
				
				-- SoulShards (Warlock)
				if self.SoulShards then
					self.SoulShards:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
					self.SoulShards:SetSize((C.unitframe.layout2_w - 3), 7)
					
					for i = 1, 5 do
						if self.SoulShards[i] then
							self.SoulShards[i]:SetSize(((C.unitframe.layout2_w - 3) - 4) / 5, 7)
						end
						if i == 1 then
							self.SoulShards[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
						end
					end
				end
				
				-- ArcaneCharge (Mage)
				if self.ArcaneCharge then
					self.ArcaneCharge:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
					self.ArcaneCharge:SetSize((C.unitframe.layout2_w - 3), 7)
					
					for i = 1, 4 do
						if self.ArcaneCharge[i] then
							self.ArcaneCharge[i]:SetSize(((C.unitframe.layout2_w - 3) - 3) / 4, 7)
						end
						if i == 1 then
							self.ArcaneCharge[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
						end
					end
				end
				
				-- Essence (for new content)
				if self.Essence then
					self.Essence:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
					self.Essence:SetSize((C.unitframe.layout2_w - 3), 7)
					
					for i = 1, 6 do
						if self.Essence[i] then
							self.Essence[i]:SetSize(((C.unitframe.layout2_w - 3) - 5) / 6, 7)
						end
						if i == 1 then
							self.Essence[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
						end
					end
				end
				
				-- SoulFragments (Demon Hunter)
				if self.SoulFragments then
					self.SoulFragments:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
					self.SoulFragments:SetSize((C.unitframe.layout2_w - 3), 7)
				end
				
				-- TotemBar (Shaman)
				if self.TotemBar then
					self.TotemBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
					self.TotemBar:SetSize((C.unitframe.layout2_w - 3), 7)
					
					for i = 1, 4 do
						if self.TotemBar[i] then
							self.TotemBar[i]:SetSize(((C.unitframe.layout2_w - 3) - 3) / 4, 7)
						end
						if i == 1 then
							self.TotemBar[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 7)
						end
					end
				end
			end
			
			-- ========== PET & TARGET'S TARGET POSITIONING ==========
			-- Position pet frame to the right of player portrait
			-- Position target's target below pet frame
			if unitType == "player" then
				C_Timer.After(0.1, function()
					if oUF_Pet and playerFramePortrait then
						oUF_Pet:ClearAllPoints()
						oUF_Pet:SetPoint("TOPLEFT", playerFramePortrait, "TOPRIGHT", Layout2Config.portrait.pet_offset_x, Layout2Config.portrait.pet_offset_y)
					end
					
					if oUF_TargetTarget and oUF_Pet then
						oUF_TargetTarget:ClearAllPoints()
						oUF_TargetTarget:SetPoint("BOTTOMLEFT", playerFramePortrait, "BOTTOMRIGHT", Layout2Config.portrait.pet_offset_x, 0)
					end
				end)
			end
			
			return self
		end
		
		-- Re-register oUF style with Layout2 modifications
		return originalRegisterStyle(self, styleName, SharedWithLayout2)
	else
		return originalRegisterStyle(self, styleName, sharedFunc)
	end
end

print("|cff00ff00Layout2.lua: Hook registered|r")

----------------------------------------------------------------------------------------
--	API FUNCTIONS
--	Use these functions to modify Layout2 settings at runtime via console commands
----------------------------------------------------------------------------------------

-- Update a specific tag's display text
-- Example: T.UpdateLayout2Tag("player", "health_bar", "top_left", "[PercentHP]")
function T.UpdateLayout2Tag(unit, section, position, newTag)
	if Layout2Tags[unit] and Layout2Tags[unit][section] and Layout2Tags[unit][section][position] then
		Layout2Tags[unit][section][position].tag = newTag
		print("|cff00ff00Layout2: Updated tag|r")
	end
end

-- Enable or disable a specific tag
-- Example: T.SetLayout2TagEnabled("player", "health_bar", "top_right", true)
function T.SetLayout2TagEnabled(unit, section, position, enabled)
	if Layout2Tags[unit] and Layout2Tags[unit][section] and Layout2Tags[unit][section][position] then
		Layout2Tags[unit][section][position].enable = enabled
	end
end

-- Update font properties
-- Example: T.UpdateLayout2Font("name_font", "size", 28)
function T.UpdateLayout2Font(fontType, key, value)
	if Layout2Fonts[fontType] then
		Layout2Fonts[fontType][key] = value
		print("|cff00ff00Layout2: Updated font|r")
	end
end

-- Update shadow properties
-- Example: T.UpdateLayout2Shadow("name_shadow", "enable", false)
function T.UpdateLayout2Shadow(shadowType, key, value)
	if Layout2Shadow[shadowType] then
		Layout2Shadow[shadowType][key] = value
		print("|cff00ff00Layout2: Updated shadow|r")
	end
end

-- Retrieve all tag configurations
function T.GetLayout2Tags() return Layout2Tags end

-- Retrieve all font configurations
function T.GetLayout2Fonts() return Layout2Fonts end

-- Retrieve all shadow configurations
function T.GetLayout2Shadow() return Layout2Shadow end

print("|cff00ff00Layout2.lua loaded successfully|r")