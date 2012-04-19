--[[ TODO:
	* Watch changes to return values (color changed items red)
	** For this, I need line-based rendering instead of putting everything in a
	   html container.
	* hierarchy-based safe-funcs
	* 
]]

local MAJOR = "Watch";

local safefuncs = {
	["AtBottom"] = true,
	["AtTop"] = true,
	["CanNonSpaceWrap"] = true,
	["CanChangeProtectedState"] = true,
	["CanSaveTabardNow"] = true,
	["GetAlpha"] = true,
	["GetAltArrowKeyMode"] = true,
	["GetAnchorType"] = true,
	["GetAnimations"] = true,
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
	["GetInitialOffset"] = true,
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
	["GetMaxOrder"] = true,
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
	["GetSize"] = true,
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
local updateframe;

padnum = function(padchar, value, digits)
	local sv = tostring(value);
	for i=#sv, digits-1, 1 do
		sv = padchar..sv;
	end
	
	return sv;
end

local toColorString = function(value)
	local vt = type(value);
	local retval;
	if vt == "table" and type(rawget(value, 0)) == "userdata" and type(value.GetObjectType) == "function" then
		retval = value:GetObjectType()..":"..(value:GetName() or "(anon)");
	elseif vt == "string" then
		retval = "|cFF007700\""..value.."\"|r";
	elseif vt == "number" then
		retval = "|cFFFF00FF"..value.."|r";
	elseif vt == "function" then
		retval = ""..tostring(value).."";
	elseif vt == "table" then
		retval = tostring(value);
	elseif vt == "boolean" and value then
		retval = "|cFF00FF00"..tostring(value).."|r";
	elseif vt == "boolean" and not value then
		retval = "|cFFFF0000"..tostring(value).."|r";
	elseif not value then
		retval = "|cFFFF0000"..tostring(value).."|r";
	else
		retval = ""..gsub(tostring(value), "-", " ").."";
	end
	
	-- remove stuff we don't like so we don't break HTML
	retval = gsub(retval, ">", "&gt;");
	retval = gsub(retval, "<", "&lt;");
	--retval = gsub(retval, "&", "&amp;");
	return retval;
end

local toKeyLink = function(key, keynum)
	return "<a href=\""..keynum.."\">"..toColorString(key).."</a>";
end

toFancyString = function(watchstring, r, rt, nodescend)
	local rt = rt or type(r);
	local t = "";
	local keys = {};
	
	-- functions returning a single value get special treatment
	-- todo: current method would result in discarding values if function
	--       returns nil as 1st or 2nd return value.
	-- todo: use for ... pairs(...) with sticky max value for key to
	--       find out the real size. This could also be used further down
	--       to create a simple for i=1, max, 1 do loop, discarding all the
	--       gapsense shit.
	if rt == "list" and #r <= 1 then
		r = r[1];
		rt = type(r);
	end
	if rt == "table" and not nodescend then
		local tbl = {};
		-- the <!-- "..k.." --> part is for correct sorting
		for k,v in pairs(r) do
			tinsert(keys, k);
			tinsert(tbl, "  <!-- "..tostring(k).." -->["..toKeyLink(k, #keys).."] = "..toColorString(v));
		end
		-- ui object?
		if type(rawget(r, 0)) == "userdata" and type(r.GetObjectType) == "function" then
			for k,v in pairs(getmetatable(r).__index) do
				tinsert(keys, k);
				local rv;
				-- make safe functions clickable and directly show their return value
				if type(v) == "function" and safefuncs[k] then
					rv = toFancyString(watchstring, { v(r) }, "list", true);
					--print(v(r));
					tinsert(tbl,"  <!-- "..tostring(k).." -->["..toKeyLink(k,#keys).."] = "..rv);
				-- make unsafe functions un-clickable
				elseif type(v) == "function" then
					rv = toColorString(v);
					tinsert(tbl,"  <!-- "..tostring(k).." -->["..toColorString(k).."] = "..rv);
				else
					rv = toColorString(v);
					tinsert(tbl,"  <!-- "..tostring(k).." -->["..toKeyLink(k,#keys).."] = "..rv);
				end
			end
		end
		sort(tbl);
		t = t..tostring(r).."|n"..strjoin("|n", unpack(tbl));
	elseif rt == "list" then
		-- TODO: use
		-- local n = select('#', ...)
		-- 
		local tbl = {};
		local gapsense = {};
		for k,v in pairs(r) do
			tinsert(keys, k);
			tinsert(gapsense, k);
			tinsert(tbl, "<!-- "..padnum("0",k,3).." -->"..toColorString(v));
		end
		sort(gapsense);
		local lastv = 0;
		for k,v in ipairs(gapsense) do
			if lastv+1 ~= v then
				for i=lastv+1, v-1, 1 do
					tinsert(keys, i);
					tinsert(tbl, "<!-- "..padnum("0",i,3).." -->"..toColorString(nil));
				end
			end
			lastv = v;
		end
		sort(tbl);
		t = t..strjoin(", ", unpack(tbl));
	else
		t = t..toColorString(r);
	end
	
	return t, keys;
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
	if p then
		p[1], p[2], p[3], p[4] = self:GetRect();
	end
end

local WatchFrame_onEvent = function(self, event)
	--print("Watch", "update");
	local ok, value = pcall(self.Watch);
	if not ok then
		self.SimpleHTML:SetText("|cFFFF0000ERROR"..value.."|r");
	else
		local s, keys = toFancyString(self.WatchString, value, "list");
		self.SimpleHTML:SetText("<html><body><p>"..s.."</p></body></html>");
		self.LinkKeys = keys
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
		EasyMenu(dropdownconfig, WatchFrameDropDownMenu, "cursor", 0, -10, "MENU", 10);
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

local WatchFrameSimpleHTML_onHyperlink = function(self, key)
	key = tonumber(key);
	local top = self:GetParent():GetParent();
	local keyval = top.LinkKeys[key];
	--print("WatchFrame_onHyperlink", #top.LinkKeys, key, keyval);
	if key and keyval then
		local kt = type(keyval);
		if kt == "string" then
			watch(top.WatchString.."[\""..keyval.."\"]");
		elseif kt == "number" then
			watch(top.WatchString.."["..keyval.."]");
		else
			watch(top.Watch()[1][keyval], top.WatchString.."["..tostring(keyval).."]");
		end
	end
end

local WatchFrame_unwatch = function(self)
	unwatch(self.id);
end

local WatchFrame_onActivate = function(self, input, inputstring)
	self.elapsed = 0;
	self.Watch = input;
	self.WatchString = inputstring;
	self.Unwatch = WatchFrame_unwatch;
	self.TitleRegion = select(3, self:GetRegions());
	self.TitleRegion:SetText(inputstring);
	self.TitleRegionID = select(4, self:GetRegions());
	self.TitleRegionID:SetText(tostring(self.id));
	self:SetScript("OnEvent", WatchFrame_onEvent);
	--self:SetScript("OnUpdate", WatchFrame_onUpdate);
	self:SetScript("OnClick", nil);
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

watch = function(what, keyname)
	print(what, keyname);
	if what then
		local load;
		if type(what) == "string" then
			load = loadstring(watchcase:format(what), "Watched expression: '"..what.."'");
			keyname = what;
		else
			load = function() return {what} end;
			keyname = keyname or "(unknown)";
		end
		local frame = tremove(framebuffer) or CreateFrame("Button", nil, UIParent, "WatchFrameTemplate");
		tinsert(watchers, frame);
		local id = #watchers;
		frame.id = id;
		frame.savePosition = WatchFrame_savePosition;
		-- save watchers
		if type(what) == "string" then -- only if watching a string - for now
			SavedWatchers[id] = what;
			SavedWatchersPos[id] = {};
		end
		-- OnLoad?
		WatchFrame_onActivate(frame, load, keyname);
		frame:SetWidth(250);
		frame:SetHeight(250);
		frame:savePosition();
		updateframe:Show();
		return frame;
	end
end

unwatch = function(id)
	if strmatch(id, "%s*ALL%s*") then
		for k,v in pairs(watchers) do
			unwatch(k);
		end
		return;
	end
	id = tonumber(id);
	if id and watchers[id] then
		local watcher = tremove(watchers, id);
		watcher:Hide();
		tinsert(framebuffer, watcher);
		tremove(SavedWatchers, id);
		tremove(SavedWatchersPos, id);
		-- update ids of other watchers
		for k,watcher in pairs(watchers) do
			watcher.id = k;
			watcher.TitleRegionID:SetText(k);
		end
	end
	if #watchers == 0 then
		updateframe:Hide();
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
SlashCmdList["WATCH_PRINT"] = watch_print;
SLASH_WATCH_PRINT1 = "/print";


updateframe = CreateFrame("frame");
updateframe:EnableMouse(false);
updateframe:Hide();
local updateframepos = 1;
local updateframedt = 0;
local updatedtmin = 0.5;
updateframe:SetScript("OnUpdate", function(self, elapsed)
	if updateframedt < updatedtmin then
		updateframedt = updateframedt+elapsed;
		return;
	end
	
	if updateframepos > #watchers then
		updateframepos = 1;
		updateframedt = 0;
		return;
	end
	
	if watchers[updateframepos] then
		WatchFrame_onEvent(watchers[updateframepos], "UPDATE");
	else
		self:Hide(); -- we assume there's nothing to update then
	end
	updateframepos = updateframepos+1;
end);