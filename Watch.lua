---
-- Watch.
--
-- Periodically evaluates a number of expressions and outputs them in frames in
-- the UI.
-- 
-- TODO:
-- * Watch changes to return values (color changed items red)
-- ** For this, I need line-based rendering instead of putting everything in a
--    html container.
-- * Hierarchy-based safe methods
-- 

local MAJOR, Addon = ...;

-- Global-to-file variables
local Updater_Frame, Safe_Methods;
local Frame_Buffer, Watchers = {}, {};
local watchcase = [[
	return {%s};
]];

-- Global-to-file functions
local watch, unwatch, rewatch, pad_num, color_string, fancy_string

-- localised globals
local pairs, tremove, max, gsub
    = pairs, tremove, max, gsub;

-- Saved-variables init
SavedWatchers = {};
SavedWatchersPos = {};


-- ######## ########     ###    ##     ## ########        ###    ########  ####
-- ##       ##     ##   ## ##   ###   ### ##             ## ##   ##     ##  ##
-- ##       ##     ##  ##   ##  #### #### ##            ##   ##  ##     ##  ##
-- ######   ########  ##     ## ## ### ## ######       ##     ## ########   ##
-- ##       ##   ##   ######### ##     ## ##           ######### ##         ##
-- ##       ##    ##  ##     ## ##     ## ##           ##     ## ##         ##
-- ##       ##     ## ##     ## ##     ## ########     ##     ## ##        ####

local dropdownconfig = { {
		text = "disable watcher", -- string. This is the text to put on this menu item.
		func = function(self)
			local f = (select(2, self:GetParent():GetPoint()));
			unwatch(f.id);
		end, -- function. This is the function that will fire when you click on this menu item.
	}, {
		text = "",
		disabled = true,
	}, {
		text = "Show safe items only",
		disabled = true,
		func = function(...) return; end,
	}, {
		text = "set interval",
		disabled = true,
		func = function(...) return; end,
	}, {
		text = "set events",
		disabled = true,
		func = function(...) return; end,
	}, {
		text = "Automatic Refresh",
		disabled = true,
		checked = true,
		func = function(...) return; end,
	}, {
		text = "Update",
		disabled = true,
		func = function(self)
		end,
	},
}

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
		local s, keys = fancy_string(self.WatchString, value, "list");
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


--    ###    ########  ########   #######  ##    ##        ###    ########  ####
--   ## ##   ##     ## ##     ## ##     ## ###   ##       ## ##   ##     ##  ##
--  ##   ##  ##     ## ##     ## ##     ## ####  ##      ##   ##  ##     ##  ##
-- ##     ## ##     ## ##     ## ##     ## ## ## ##     ##     ## ########   ##
-- ######### ##     ## ##     ## ##     ## ##  ####     ######### ##         ##
-- ##     ## ##     ## ##     ## ##     ## ##   ###     ##     ## ##         ##
-- ##     ## ########  ########   #######  ##    ##     ##     ## ##        ####

-- Make the call Addon(...) possible
Addon = setmetatable(Addon, {__call = function(self, ...) return watch(...) end});

function Addon.watch(what, keyname)
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
		local frame = tremove(Frame_Buffer) or CreateFrame("Button", nil, UIParent, "WatchFrameTemplate");
		tinsert(Watchers, frame);
		local id = #Watchers;
		frame.id = id;
		frame.savePosition = WatchFrame_savePosition;
		-- save Watchers
		if type(what) == "string" then -- only if watching a string - for now
			SavedWatchers[id] = what;
			SavedWatchersPos[id] = {};
		end
		-- OnLoad?
		WatchFrame_onActivate(frame, load, keyname);
		frame:SetWidth(250);
		frame:SetHeight(250);
		frame:savePosition();
		Updater_Frame:Show();
		return frame;
	end
end

function Addon.unwatch(id)
	if strmatch(id, "%s*ALL%s*") then
		for k,v in pairs(Watchers) do
			unwatch(k);
		end
		return;
	end
	id = tonumber(id);
	if id and Watchers[id] then
		local watcher = tremove(Watchers, id);
		watcher:Hide();
		tinsert(Frame_Buffer, watcher);
		tremove(SavedWatchers, id);
		tremove(SavedWatchersPos, id);
		-- update ids of other Watchers
		for k,watcher in pairs(Watchers) do
			watcher.id = k;
			watcher.TitleRegionID:SetText(k);
		end
	end
	if #Watchers == 0 then
		Updater_Frame:Hide();
	end
end

function Addon.rewatch()
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

function Addon.getWatchers()
	return Watchers;
end

-- assign addon-api locally
watch = Addon.watch
unwatch = Addon.unwatch
rewatch = Addon.rewatch

--
-- ######## ##     ## ##    ##  ######  ######## ####  #######  ##    ##  ######
-- ##       ##     ## ###   ## ##    ##    ##     ##  ##     ## ###   ## ##    ##
-- ##       ##     ## ####  ## ##          ##     ##  ##     ## ####  ## ##
-- ######   ##     ## ## ## ## ##          ##     ##  ##     ## ## ## ##  ######
-- ##       ##     ## ##  #### ##          ##     ##  ##     ## ##  ####       ##
-- ##       ##     ## ##   ### ##    ##    ##     ##  ##     ## ##   ### ##    ##
-- ##        #######  ##    ##  ######     ##    ####  #######  ##    ##  ######

---
-- Pad a number value to n digits, using the specified character
-- @param padchar (string) the character that is used for padding
-- @param digits (integer) the number of minimum characters that the output must
--      contain. Note that the output *can* be longer.
-- @return always returns a string value
pad_num = function(padchar, value, digits)
	local sv = tostring(value);
	for i=#sv, digits-1, 1 do
		sv = padchar..sv;
	end
	
	return sv;
end

color_string = function(value)
	local vt = type(value);
	local retval;
	if vt == "table" and type(rawget(value, 0)) == "userdata" and type(value.GetObjectType) == "function" then
		retval = value:GetObjectType()..":"..(value:GetName() or "(anon)");
	elseif vt == "string" then
		retval = "|cFF007700\""..value:gsub("\n","|n").."\"|r";
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

key_link = function(key, keynum)
	return "<a href=\""..keynum.."\">"..color_string(key).."</a>";
end


fancy_string = function(watchstring, r, rt, nodescend)
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
			tinsert(tbl, "  <!-- "..tostring(k).." -->["..key_link(k, #keys).."] = "..color_string(v));
		end
		-- ui object?
		if type(rawget(r, 0)) == "userdata" and type(r.GetObjectType) == "function" then
			for k,v in pairs(getmetatable(r).__index) do
				tinsert(keys, k);
				local rv;
				-- make safe functions clickable and directly show their return value
				if type(v) == "function" and Safe_Methods[k] then
					rv = fancy_string(watchstring, { v(r) }, "list", true);
					--print(v(r));
					tinsert(tbl,"  <!-- "..tostring(k).." -->["..key_link(k,#keys).."] = "..rv);
				-- make unsafe functions un-clickable
				elseif type(v) == "function" then
					rv = color_string(v);
					tinsert(tbl,"  <!-- "..tostring(k).." -->["..color_string(k).."] = "..rv);
				else
					rv = color_string(v);
					tinsert(tbl,"  <!-- "..tostring(k).." -->["..key_link(k,#keys).."] = "..rv);
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
			tinsert(tbl, "<!-- "..pad_num("0",k,3).." -->"..color_string(v));
		end
		sort(gapsense);
		local lastv = 0;
		for k,v in ipairs(gapsense) do
			if lastv+1 ~= v then
				for i=lastv+1, v-1, 1 do
					tinsert(keys, i);
					tinsert(tbl, "<!-- "..pad_num("0",i,3).." -->"..color_string(nil));
				end
			end
			lastv = v;
		end
		sort(tbl);
		t = t..strjoin(", ", unpack(tbl));
	else
		t = t..color_string(r);
	end
	
	return t, keys;
end;

--    ###    ########  ########   #######  ##    ##    #### ##    ## #### ########
--   ## ##   ##     ## ##     ## ##     ## ###   ##     ##  ###   ##  ##     ##
--  ##   ##  ##     ## ##     ## ##     ## ####  ##     ##  ####  ##  ##     ##
-- ##     ## ##     ## ##     ## ##     ## ## ## ##     ##  ## ## ##  ##     ##
-- ######### ##     ## ##     ## ##     ## ##  ####     ##  ##  ####  ##     ##
-- ##     ## ##     ## ##     ## ##     ## ##   ###     ##  ##   ###  ##     ##
-- ##     ## ########  ########   #######  ##    ##    #### ##    ## ####    ##

-- Setup slash commands
SlashCmdList["WATCH"  ] = watch;   SLASH_WATCH1   = "/watch";
SlashCmdList["UNWATCH"] = unwatch; SLASH_UNWATCH1 = "/unwatch";
SlashCmdList["REWATCH"] = rewatch; SLASH_REWATCH1 = "/rewatch";
--SlashCmdList["WATCH_PRINT"] = watch_print; SLASH_WATCH_PRINT1 = "/print";

do -- Set up global update frame (spread watcher evaluations across game-frames)
	Updater_Frame = CreateFrame("frame");
	Updater_Frame:EnableMouse(false);
	Updater_Frame:Hide();
	local update_pos = 1;
	local update_dt = 0;
	local update_dt_min = 0.5;
	Updater_Frame:SetScript("OnUpdate", function(self, elapsed)
		if update_dt < update_dt_min then
			update_dt = update_dt+elapsed;
			return;
		end
		if #Watchers <= 0 then
			self:Hide(); -- we assume there's nothing to update then
			return;
		end

		if update_pos > #Watchers then
			update_pos = 1;
		end
		
		if Watchers[update_pos] then
			WatchFrame_onEvent(Watchers[update_pos], "UPDATE");
		end
		update_pos = update_pos+1;
	end);
end

-- Create an Ace-Addon if Ace-Addon is in environment:
if LibStub and LibStub("AceAddon-3.0") then
	LibStub("AceAddon-3.0"):NewAddon(Addon, MAJOR);
end

-- Make add-on accessible as a global variable
_G.Watch = Addon

--  ######     ###    ######## ########     ######## ##    ##  ######   ######
-- ##    ##   ## ##   ##       ##           ##       ###   ## ##    ## ##    ##
-- ##        ##   ##  ##       ##           ##       ####  ## ##       ##
--  ######  ##     ## ######   ######       ######   ## ## ## ##        ######
--       ## ######### ##       ##           ##       ##  #### ##             ##
-- ##    ## ##     ## ##       ##           ##       ##   ### ##    ## ##    ##
--  ######  ##     ## ##       ########     ##       ##    ##  ######   ######

Safe_Methods = {
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
