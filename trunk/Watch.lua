--[[ TODO:
	* Watch changes to return values (color changed items red)
	* Make table indexes click-able, clicking a table index opens a new watcher
	  watching for this
]]

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
SavedWatchersPos = {};
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
		return value:GetObjectType()..":"..(value:GetName() or "(anon)");
	elseif vt == "table" then
		return ""..tostring(value).."";
	elseif vt == "boolean" and value then
		return "|cFF00FF00"..tostring(value).."|r";
	elseif vt == "boolean" and not value then
		return "|cFFFF0000"..tostring(value).."|r";
	elseif not value then
		return "|cFFFF0000"..tostring(value).."|r";
	else
		return ""..tostring(value).."";
	end
end

local toKeyLink = function(watchstring, tbl, key, issafe)
	watchstring = watchstring or "";
	watchstring:gsub("\"", "'");
	
	if issafe and type(tbl[key]) == "function" then
		watchstring = watchstring..":"..key.."()";
	else
		if type(key) == "string" then
			watchstring = watchstring.."['"..key.."']";
		else
			watchstring = watchstring.."["..key.."]";
		end
	end
	
	return "<a href=\""..watchstring.."\">"..toColorString(key).."</a>";
end

toFancyString = function(watchstring, r, rt, nodescend)
	local rt = rt or type(r);
	local t = "";
	if rt == "list" and #r <= 1 then
		r = r[1];
		rt = type(r);
	end
	if rt == "table" and not nodescend then
		local tbl = {};
		for k,v in pairs(r) do
			tinsert(tbl, "  ["..toKeyLink(watchstring, r, k).."] = "..toColorString(v));
		end
		-- ui object?
		if type(rawget(r, 0)) == "userdata" and type(r.GetObjectType) == "function" then
			for k,v in pairs(getmetatable(r).__index) do
				local rv;
				if type(v) == "function" and safefuncs[k] then
					rv = toFancyString(watchstring, { v(r) }, "list", true);
					--print(v(r));
					tinsert(tbl,"  ["..toKeyLink(watchstring,r,k,true).."] = "..rv);
				else
					rv = toColorString(v);
					tinsert(tbl,"  ["..toKeyLink(watchstring,r,k).."] = "..rv);
				end
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
		end, -- function. This is the function that will fire when you click on this menu item.
	},
	{
		text = "",
		disabled = true,
	},
	{
		text = "Show safe items only",
		disabled = true,
		func = function(...) return; end,
	},
	{
		text = "set interval",
		disabled = true,
		func = function(...) return; end,
	},
	{
		text = "set events",
		disabled = true,
		func = function(...) return; end,
	},
	{
		text = "Automatic Refresh",
		disabled = true,
		checked = true,
		func = function(...) return; end,
	},
	{
		text = "Update",
		disabled = true,
		func = function(self)
		end,
	},

}

local watchcase = [[
	return {%s};
]];

local WatchFrame_savePosition = function(self)
	local p = SavedWatchersPos[self.id];
	p[1], p[2], p[3], p[4] = self:GetRect();
end

local WatchFrame_onEvent = function(self, event)
	local ok, value = pcall(self.Watch, self);
	if not ok then
		self.SimpleHTML:SetText("|cFFFF0000ERROR"..value.."|r");
	else
		self.SimpleHTML:SetText("<html><body><p>"..
			toFancyString(self.WatchString, value, "list")..
			"</p></body></html>"
		);
	end
end

local WatchFrame_onUpdate = function(self, elapsed)
	if self.elapsed > .9 then
		self.elapsed = 0;
		WatchFrame_onEvent(self, "UPDATE");
	end
	
	--print(elapsed);
	self.elapsed = self.elapsed + elapsed;
end

local WatchFrame_onMouseDown = function(self, button)
	if button ~= "RightButton" then
		self.IsDragging = true;
		self:StartMoving();
	end
end

local WatchFrame_onMouseUp = function(self, button)
	if self.IsDragging then
		self:StopMovingOrSizing();
		self.IsDragging = false;
		self:savePosition();
	elseif button == "RightButton" then
		EasyMenu(dropdownconfig, WatchFrameDropDownMenu, self, 0, -10, "MENU", 10);
	end
end

local WatchFrameScrollframe_onMouseDown = function(self, button)
	if IsControlKeyDown() then
		WatchFrame_onMouseDown(self:GetParent(), button);
	end
end

local WatchFrameScrollframe_onMouseUp = function(self, button)
	WatchFrame_onMouseUp(self:GetParent(), button);
end

local WatchFrameSimpleHTML_onMouseDown = function(self, button)
	if IsControlKeyDown() then
		WatchFrame_onMouseDown(self:GetParent():GetParent(), button);
	end
end

local WatchFrameSimpleHTML_onMouseUp = function(self, button)
	WatchFrame_onMouseUp(self:GetParent():GetParent(), button);
end

local WatchFrameSimpleHTML_onHyperlink = function(self, watchstr)
	print("WatchFrame_onHyperlink", watchstr);
	watch(watchstr);
end

local WatchFrame_onActivate = function(self, inputstring, input)
	self.elapsed = 0;
	self.Watch = input;
	self.WatchString = inputstring;
	self.TitleRegion = select(3, self:GetRegions());
	self.TitleRegion:SetText("(("..self.id..")) "..inputstring);
	self:SetScript("OnEvent", WatchFrame_onEvent);
	self:SetScript("OnUpdate", WatchFrame_onUpdate);
	self:SetScript("OnClick", WatchFrame_onClick);
	self:SetScript("OnMouseDown", WatchFrame_onMouseDown);
	self:SetScript("OnMouseUp", WatchFrame_onMouseUp);
	self.SimpleHTML:SetScript("OnHyperlinkClick", WatchFrameSimpleHTML_onHyperlink);
	self.Scrollframe:SetScript("OnMouseDown", WatchFrameScrollframe_onMouseDown);
	self.Scrollframe:SetScript("OnMouseUp",   WatchFrameScrollframe_onMouseUp);
	self:RegisterForClicks("AnyUp", "AnyDown");
	self:Show();
	self:SetToplevel(true);
	WatchFrame_onEvent(self, "UPDATE");
end

local id = 1;
watch = function(what, keyname)
	if what then
		local load = loadstring(watchcase:format(what), "Watched expression: '"..what.."'");
		local frame = tremove(framebuffer) or CreateFrame("Button", nil, UIParent, "WatchFrameTemplate");
		watchers[id] = frame;
		frame.id = id;
		frame.savePosition = WatchFrame_savePosition;
		-- save watchers
		SavedWatchers[id] = what;
		SavedWatchersPos[id] = {};
		-- OnLoad?
		WatchFrame_onActivate(frame, what, load);
		id = id+1;
		return frame;
	end
end

unwatch = function(id)
	id = tonumber(id);
	if id and watchers[id] then
		tinsert(framebuffer, watchers[id]);
		watchers[id]:Hide();
		watchers[id] = nil;
		-- unsave watchers
		SavedWatchers[id] = nil;
	end
end

rewatch = function()
	local sw = SavedWatchers;
	local swp = SavedWatchersPos;
	SavedWatchers = {};
	SavedWatchersPos = {};
	for k,v in pairs(sw) do 
		local p = swp[k];
		local f = watch(v);
		if p and #p > 0 then
			f:ClearAllPoints();
			f:SetPoint("BOTTOMLEFT", p[1], p[2])
			f:SetWidth(p[3]);
			f:SetHeight(p[4]);
			f:savePosition();
		end
	end
end

SlashCmdList["WATCH"] = watch;
SLASH_WATCH1 = "/watch";
SlashCmdList["UNWATCH"] = unwatch;
SLASH_UNWATCH1 = "/unwatch";
SlashCmdList["REWATCH"] = rewatch;
SLASH_REWATCH1 = "/rewatch";
