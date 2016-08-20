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

Addon.API = {} -- Table for public add-on API

-- Localise tables
local Safe_Methods = Addon.Safe_Methods;

-- Global-to-file variables
local Updater_Frame;
local Frame_Buffer, Watchers = {}, {};
local watchcase = [[
	return {%s};
]];

-- Global-to-file functions
local watch, unwatch, rewatch, pad_num, color_string

-- localised globals
local pcall, pairs, tremove, gsub, tostring, format
    = pcall, pairs, tremove, gsub, tostring, format;

-- Saved-variables init
SavedWatchers = {};
SavedWatchersPos = {};

--    ###    ########  ########   #######  ##    ##        ###    ########  ####
--   ## ##   ##     ## ##     ## ##     ## ###   ##       ## ##   ##     ##  ##
--  ##   ##  ##     ## ##     ## ##     ## ####  ##      ##   ##  ##     ##  ##
-- ##     ## ##     ## ##     ## ##     ## ## ## ##     ##     ## ########   ##
-- ######### ##     ## ##     ## ##     ## ##  ####     ######### ##         ##
-- ##     ## ##     ## ##     ## ##     ## ##   ###     ##     ## ##         ##
-- ##     ## ########  ########   #######  ##    ##     ##     ## ##        ####

-- Make the call Addon(...) possible
Addon.API = setmetatable(Addon.API, {__call = function(self, ...) return watch(...) end});

function Addon.API.watch(what, keyname)
	--print(what, keyname);
	if what then
		local load;
		if type(what) == "string" then
			load = loadstring(format(watchcase, what), "Watched expression: '"..what.."'");
			keyname = what;
		else
			load = function() return {what} end;
			keyname = keyname or "(unknown)";
		end
		local id = #Watchers+1;
		local frame = Addon.GetFrame(id, load, keyname);
		tinsert(Watchers, frame);
		-- save Watchers
		if type(what) == "string" then -- only if watching a string - for now
			SavedWatchers[id] = what;
			SavedWatchersPos[id] = {};
		else
			SavedWatchers[id] = false;
			SavedWatchersPos[id] = false;
		end
		-- OnLoad?
		frame:SetWidth(250);
		frame:SetHeight(250);
		frame:SavePosition();
		Updater_Frame:Show();
		return frame;
	else
		local e = format("Error: %s is not a valid watch expression", tostring(what))
		print(e)
		return false, e
	end
end

function Addon.API.unwatch(id)
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
			watcher.Id = k;
			watcher.TitleID:SetText(k);
		end
	end
	if #Watchers == 0 then
		Updater_Frame:Hide();
	end
end

function Addon.API.rewatch()
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
			f:SavePosition();
		end
	end
end

function Addon.API.getWatchers()
	return Watchers;
end

-- assign addon-api locally
watch = Addon.API.watch
unwatch = Addon.API.unwatch
rewatch = Addon.API.rewatch

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
		if value.IsForbidden and value:IsForbidden() then
			retval = "|cFFFF0000Forbidden|r"..":"..tostring(value or "(anon)");
		else
			retval = value:GetObjectType()..":"..(value:GetName() or "(anon)");
		end
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

function Addon.Highlight(watchstring, r, rt, nodescend)
	local rt = rt or type(r);
	local t = "";
	local keys = {};
	local drilldown = {};
	
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
			tbl[k] = "["..color_string(k).."] = "..color_string(v)
		end
		-- ui object?
		if type(rawget(r, 0)) == "userdata" and type(r.GetObjectType) == "function" then
			for k,v in pairs(getmetatable(r).__index) do
				tinsert(keys, k);
				local rv;
				-- make safe functions clickable and directly show their return value
				if type(v) == "function" and Safe_Methods[k] then
					rv = Addon.Highlight(watchstring, {v(r)}, "list", true)[1] or color_string(nil);
				elseif type(v) == "function" then
					drilldown[k] = false;
					rv = color_string(v);
				else
					drilldown[k] = "function";
					rv = color_string(v);
				end
				tbl[k] = "["..color_string(k).."] = "..rv;
			end
		end
		sort(keys, function(A, B)
			return tostring(A) < tostring(B);
		end);
		t = tbl;
		--t = t..tostring(r).."|n"..strjoin("|n", unpack(tbl));
	elseif rt == "list" then
		local tbl = {};
		local mx = 0;
		for k,v in pairs(r) do
			if mx < k then mx = k end
		end
		for k=1, mx do
			tbl[k] = color_string(r[k])
		end
		keys[1] = 1
		drilldown[1] = false;
		t = {t..strjoin(", ", unpack(tbl))};
	else
		keys[1] = 1
		drilldown[1] = false;
		t = {t..color_string(r)};
	end
	
	return t, keys, drilldown;
end

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
			Watchers[update_pos]:Update("UPDATE");
		end
		update_pos = update_pos+1;
	end);
	
	-- Create an Ace-Addon if Ace-Addon is in environment:
	Updater_Frame:SetScript("OnEvent", function()
		if LibStub and LibStub("AceAddon-3.0") then
			LibStub("AceAddon-3.0"):NewAddon(Addon.API, MAJOR);
			Updater_Frame:UnregisterEvent("ADDON_LOADED");
		end
	end);
	Updater_Frame:RegisterEvent("ADDON_LOADED");
end

-- Make add-on accessible as a global variable
_G.Watch = Addon.API;
