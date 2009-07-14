local safefuncs = {
	["AtBottom"] = true,
	["AtTop"] = true,
	["CanNonSpaceWrap"] = true,
	["CanSaveTabardNow"] = true,
	["GetAlpha"] = true,
	["GetAltArrowKeyMode"] = true,
	["GetAnchorType"] = true,
	["GetAnimationGroups"] = true,
	["GetBackdrop"] = true,
	["GetBackdropBorderColor"] = true,
	["GetBackdropColor"] = true,
	["GetBlendMode"] = true,
	["GetBlinkSpeed"] = true,
	["GetBottom"] = true,
	["GetButtonState"] = true,
	["GetCenter"] = true,
	["GetChange"] = true,
	["GetChecked"] = true,
	["GetCheckedTexture"] = true,
	["GetChildren"] = true,
	["GetClampRectInsets"] = true,
	["GetColorHSV"] = true,
	["GetColorRGB"] = true,
	["GetColorValueTexture"] = true,
	["GetColorValueThumbTexture"] = true,
	["GetColorWheelTexture"] = true,
	["GetColorWheelThumbTexture"] = true,
	["GetCurrentLine"] = true,
	["GetCurrentScroll"] = true,
	["GetCursorPosition"] = true,
	["GetDegrees"] = true,
	["GetDepth"] = true,
	["GetDisabledCheckedTexture"] = true,
	["GetDisabledFontObject"] = true,
	["GetDisabledTexture"] = true,
	["GetDrawLayer"] = true,
	["GetDuration"] = true,
	["GetEffectiveAlpha"] = true,
	["GetEffectiveDepth"] = true,
	["GetEffectiveScale"] = true,
	["GetElapsed"] = true,
	["GetEndDelay"] = true,
	["GetFacing"] = true,
	["GetFadeDuration"] = true,
	["GetFading"] = true,
	["GetFogColor"] = true,
	["GetFogFar"] = true,
	["GetFogNear"] = true,
	["GetFont"] = true,
	["GetFontObject"] = true,
	["GetFontString"] = true,
	["GetFrameLevel"] = true,
	["GetFrameStrata"] = true,
	["GetFrameType"] = true,
	["GetHeight"] = true,
	["GetHighlightFontObject"] = true,
	["GetHighlightTexture"] = true,
	["GetHistoryLines"] = true,
	["GetHitRectInsets"] = true,
	["GetHorizontalScroll"] = true,
	["GetHorizontalScrollRange"] = true,
	["GetHyperlinkFormat"] = true,
	["GetHyperlinksEnabled"] = true,
	["GetID"] = true,
	["GetInputLanguage"] = true,
	["GetInsertMode"] = true,
	["GetItem"] = true,
	["GetJustifyH"] = true,
	["GetJustifyV"] = true,
	["GetLeft"] = true,
	["GetLight"] = true,
	["GetLooping"] = true,
	["GetLoopState"] = true,
	["GetMaxBytes"] = true,
	["GetMaxFramerate"] = true,
	["GetMaxLetters"] = true,
	["GetMaxLines"] = true,
	["GetMaxResize"] = true,
	["GetMinimumWidth"] = true,
	["GetMinMaxValues"] = true,
	["GetMinResize"] = true,
	["GetModel"] = true,
	["GetModelScale"] = true,
	["GetName"] = true,
	["GetNormalFontObject"] = true,
	["GetNormalTexture"] = true,
	["GetNumber"] = true,
	["GetNumChildren"] = true,
	["GetNumLetters"] = true,
	["GetNumLinesDisplayed"] = true,
	["GetNumMessages"] = true,
	["GetNumPoints"] = true,
	["GetNumRegions"] = true,
	["GetObjectType"] = true,
	["GetOffset"] = true,
	["GetOrder"] = true,
	["GetOrientation"] = true,
	["GetOrigin"] = true,
	["GetOwner"] = true,
	["GetParent"] = true,
	["GetPingPosition"] = true,
	["GetPoint"] = true,
	["GetPosition"] = true,
	["GetProgress"] = true,
	["GetProgressWithDelay"] = true,
	["GetPushedTextOffset"] = true,
	["GetPushedTexture"] = true,
	["GetRadians"] = true,
	["GetRect"] = true,
	["GetRegionParent"] = true,
	["GetRegions"] = true,
	["GetRight"] = true,
	["GetScale"] = true,
	["GetShadowColor"] = true,
	["GetShadowOffset"] = true,
	["GetSmoothing"] = true,
	["GetSmoothProgress"] = true,
	["GetSpacing"] = true,
	["GetSpell"] = true,
	["GetStartDelay"] = true,
	["GetStatusBarTexture"] = true,
	["GetStringHeight"] = true,
	["GetStringWidth"] = true,
	["GetTexCoord"] = true,
	["GetTexCoordModifiesRect"] = true,
	["GetText"] = true,
	["GetTextColor"] = true,
	["GetTextHeight"] = true,
	["GetTextInsets"] = true,
	["GetTexture"] = true,
	["GetTextWidth"] = true,
	["GetThumbTexture"] = true,
	["GetTimeVisible"] = true,
	["GetTitleRegion"] = true,
	["GetTop"] = true,
	["GetUnit"] = true,
	["GetValue"] = true,
	["GetValueStep"] = true,
	["GetVertexColor"] = true,
	["GetVerticalScroll"] = true,
	["GetVerticalScrollRange"] = true,
	["GetWidth"] = true,
	["GetZoom"] = true,
	["GetZoomLevels"] = true,
	["IsAutoFocus"] = true,
	["IsClampedToScreen"] = true,
	["IsDelaying"] = true,
	["IsDesaturated"] = true,
	["IsDone"] = true,
	["IsDone"] = true,
	["IsDragging"] = true,
	["IsEnabled"] = true,
	["IsEnabled"] = true,
	["IsIgnoringDepth"] = true,
	["IsKeyboardEnabled"] = true,
	["IsMouseEnabled"] = true,
	["IsMouseWheelEnabled"] = true,
	["IsMovable"] = true,
	["IsMultiLine"] = true,
	["IsNumeric"] = true,
	["IsPassword"] = true,
	["IsPaused"] = true,
	["IsPaused"] = true,
	["IsPlaying"] = true,
	["IsPlaying"] = true,
	["IsProtected"] = true,
	["IsResizable"] = true,
	["IsShown"] = true,
	["IsStopped"] = true,
	["IsToplevel"] = true,
	["IsUserPlaced"] = true,
	["IsVisible"] = true,
	["NumLines"] = true,
}
SavedWatchers = {};
local framebuffer = {};
local watchers = {};
gw = watchers;
local watch, unwatch, rewatch, toFancyString;

local toColorString = function(value)
	local vt = type(value);
	if vt == "string" then
		return "|cFF007700\""..value.."\"|r";
	elseif vt == "number" then
		return "|cFFFF00FF"..value.."|r";
	elseif vt == "function" then
		return ""..tostring(value).."";
	elseif vt == "table" and type(rawget(value, 0)) == "userdata" and type(value.GetObjectType) == "function" then
		return "<"..value:GetObjectType()..":"..(value:GetName() or "(anon)")..">";
	elseif vt == "table" then
		return ""..tostring(value).."";
	elseif vt == "boolean" and value then
		return "|cFF00FF00"..tostring(value).."|r";
	elseif vt == "boolean" and not value then
		return "|cFFFF0000"..tostring(value).."|r";
	elseif not vt then
		return "|cFFFF0000"..tostring(value).."|r";
	else
		return ""..tostring(value).."";
	end
end

toFancyString = function(r, rt, nodescend)
	local rt = rt or type(r);
	local t = "";
	if rt == "list" and #r <= 1 then
		r = r[1];
		rt = type(r);
	end
	if rt == "table" and not nodescend then
		local tbl = {};
		for k,v in pairs(r) do
			tinsert(tbl, "  ["..toColorString(k).."] = "..toColorString(v));
		end
		-- ui object?
		if type(rawget(r, 0)) == "userdata" and type(r.GetObjectType) == "function" then
			for k,v in pairs(getmetatable(r).__index) do
				local rv;
				if type(v) == "function" and safefuncs[k] then
					rv = toFancyString({ v(r) }, "list", true);
					--print(v(r));
				else
					rv = toColorString(v);
				end
				tinsert(tbl, "  ["..toColorString(k).."] = "..rv);
			end
		end
		sort(tbl);
		t = t..tostring(r).."|n"..strjoin("|n", unpack(tbl));
	elseif rt == "list" then
		local tbl = {};
		for k,v in ipairs(r) do
			tinsert(tbl, toColorString(v));
		end
		t = t..strjoin(", ", unpack(tbl));
	else
		t = t..toColorString(r);
	end
	
	return t;
end;

local dropdownconfig = {
	{
		text = "disable watcher", -- string. This is the text to put on this menu item.
		func = function(self)
			local f = (select(2, self:GetParent():GetPoint()));
			unwatch(f.id);
			watchers[self] = nil;
			tinsert(framebuffer, self);
		end, -- function. This is the function that will fire when you click on this menu item.
	},
	{
		text = "",
	},
	{
		text = "set interval",
		func = function(...) return; end,
	},
	{
		text = "disable onUpdate refresh",
		func = function(...) return; end,
	},
	{
		text = "set events",
		func = function(...) return; end,
	},
	{
		text = "update watcher",
		func = function(self)
			local f = (select(2, self:GetParent():GetPoint()));

			local frame = CreateFrame("Button", nil, UIParent, "WatchFrameTemplate");
			frame.SimpleHTML:SetText(toFancyString(v));
		end,
	},

}

local watchcase = [[
	return {%s};
]];

local WatchFrame_onEvent = function(self, event)
	local ok, value = pcall(self.Watch, self);
	if not ok then
		self.SimpleHTML:SetText("|cFFFF0000ERROR"..value.."|r");
	else
		self.SimpleHTML:SetText("<html><body><p>"..toFancyString(value, "list").."</p></body></html>");
	end
end

local WatchFrame_onUpdate = function(self, elapsed)
	if self.elapsed > 1.5 then
		self.elapsed = 0;
		WatchFrame_onEvent(self, "UPDATE");
	end
	
	self.elapsed = self.elapsed + elapsed;
end

local WatchFrame_onClick = function(self)
	EasyMenu(dropdownconfig, WatchFrameDropDownMenu, self, 0, -10, "MENU", 10);
	self:Raise();
end

local WatchFrame_onActivate = function(self, inputstring, input)
	self.elapsed = 0;
	self.Watch = input;
	self.TitleRegion = select(3, self:GetRegions());
	self.TitleRegion:SetText(inputstring);
	self:SetScript("OnEvent", WatchFrame_onEvent);
	self:SetScript("OnUpdate", WatchFrame_onUpdate);
	self:SetScript("OnClick", WatchFrame_onClick);
	self:RegisterForClicks("RightButtonUp");
	WatchFrame_onEvent(self, "UPDATE");
end

local id = 1;
watch = function(what)
	if what then
		local load = loadstring(watchcase:format(what), "Watched expression: '"..what.."'");
		local frame = tremove(framebuffer) or CreateFrame("Button", nil, UIParent, "WatchFrameTemplate");
		watchers[id] = frame;
		frame.id = id;
		WatchFrame_onActivate(frame, what, load);
		-- save watchers
		SavedWatchers[id] = what;
		id = id+1;
	end
end

unwatch = function(id)
	if id and watchers[id] then
		tinsert(framebuffer, watchers[id]);
		watchers[id]:Hide();
		watchers[id] = nil;
		-- unsave watchers
		SavedWatchers[id] = nil;
	end
end

rewatch = function()
	for k,v in pairs(SavedWatchers) do 
		watch(v);
	end
end

SlashCmdList["WATCH"] = watch;
SLASH_WATCH1 = "/watch";
SlashCmdList["UNWATCH"] = unwatch;
SLASH_UNWATCH1 = "/unwatch";
SlashCmdList["REWATCH"] = rewatch;
SLASH_REWATCH1 = "/rewatch";
