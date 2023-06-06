---
-- Watch.
-- 
-- Periodically evaluates a number of expressions and outputs them in frames in
-- the UI.
-- 
-- TODO:
-- * Change / Fix watcher saving.
--   * Always display last watchers (if saveable)
--   * Command to shelve & restore workspaces
--   * Convert all saved watchers to shelves (saved globally)
-- * Mark watchers that are not saveable
-- * Highlight changes to return values (eg. color changed items red)
--   * For this, I need line-based rendering instead of putting everything in a
--     html container. (DONE)
-- * Hierarchy-based safe methods
-- DONE:
-- * Only update the fields that are in view of a watcher

local MAJOR, Addon = ...;

Addon.API = {} -- Table for public add-on API
local Watcher = {} --- Watcher prototype

-- localised globals
local type, pcall, pairs, tremove, wipe, gsub, tostring, format, match
    = type, pcall, pairs, tremove, wipe, gsub, tostring, format, string.match;

-- Constants
local ERROR1 = "Error: %s is not a valid watch expression";
local ERROR2 = "Invalid operation '%s' for '%s'";

local STR_RED    = "|cFFFF0000%s|r";
local STR_GREEN  = "|cFF00FF00%s|r";
local STR_BLUE   = "|cFF0000FF%s|r";
local STR_PURPLE = "|cFFFF00FF%s|r";

local watchcase = [[
	local stack = ...;
	--print([==[ %s ]==], unpack(stack))
	return %s;]];
local function defensive_sort(A,B) return tostring(A)<tostring(B); end
local UNKNOWN = setmetatable({},{__tostring=function() return "<invalid>" end});

-- Global-to-file variables
local Safe_Methods = Addon.Safe_Methods;
local Frame_Buffer, Watchers, WatcherIds, Updater_Frame = {}, {}, {};
local Watch_Shelves_Current = nil;

-- Global-to-file functions
local watch, unwatch, rewatch, watchstr, pad_num, color_string;

-- Saved-variables init
SavedWatchers = {};
SavedWatchersPos = {};
Watch_Shelves = {};
Watch_Config = {
	_Version = 1,
	Character_Mode = false,
	Previous_Shelf = false,
};


--    ###    #######  #######   #######  ##    ##        ###    ########  ####
--   ## ##   ##    ## ##    ## ##     ## ###   ##       ## ##   ##     ##  ##
--  ##   ##  ##    ## ##    ## ##     ## ####  ##      ##   ##  ##     ##  ##
-- ##     ## ##    ## ##    ## ##     ## ## ## ##     ##     ## ########   ##
-- ######### ##    ## ##    ## ##     ## ##  ####     ######### ##         ##
-- ##     ## ##    ## ##    ## ##     ## ##   ###     ##     ## ##         ##
-- ##     ## #######  #######   #######  ##    ##     ##     ## ##        ####

-- Make the call Addon(...) possible
Addon.API=setmetatable(Addon.API,{__call=function(self, ...)return watch(...)end});

---
-- Creates a new watcher.
-- Any resulting errors will be shown in the created Watcher but will not be
-- handed to the game's error handler.
-- @param what (mixed) the thing to watch. Can be of any type. Including nil,
--        false, userdata, etc.
-- @param hint a string hint that may be shown on the title, defaults to 
--        `tostring(what)` if falsy. If truthy, `what` will be evaluated as a
--        variable instead of Lua-code. Truthy-ness is only tested if `what` is 
--        not a string.
-- @returns (Watcher) Watcher
function Addon.API.watch(what, hint)
	Watcher.Create(what, hint);
	Updater_Frame:Show();
	return Watcher;
end

---
-- Creates a new watcher.
-- Any resulting errors will be shown in the created Watcher but will not be
-- handed to the game's error handler.
-- @param str (string) the string to watch. Can be of any type, but show an
--        error if it is anything else than a string containing a Lua code.
-- @returns (Watcher) Watcher
function Addon.API.watchstr(str)
	Watcher.Create(tostring(str));
	Updater_Frame:Show();
	return Watcher;
end

---
-- Drill-down on an existing watcher
-- @param id (integer) the id of the existing watcher
-- @param key (mixed) the key to drill 
-- @param reuse (truthy) whether to re-use the given watcher
function Addon.API.drilldown(id, key, reuse)
	id = tonumber(id);
	local watcher = SavedWatchers[id];
	if not watcher then return end
	-- TODO TODO TODO
	if not reuse then
		local newwatcher = watch(watcher);
	end

	--print(what, keyname);
	if what then
		local load;
		if type(what) == "string" then
			load = loadstring(format(watchcase, what), "Watched expression: '"..what.."'");
			keyname = what;
		else
			load = function() return {what} end;
			keyname = keyname or UNKNOWN;
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
		frame:StopMovingOrSizing();
		Updater_Frame:Show();
		return frame;
	else
		local e = format(ERROR1, tostring(what))
		print(e)
		return false, e
	end
end

function Addon.API.update(id, what, keyname)
	--print(id, what, keyname);
	id = tonumber(id);

	if what and Watchers[id] then
		local frame = Watchers[id];
		local load;
		if type(what) == "string" then
			load = loadstring(format(watchcase, what), "Watched expression: '"..what.."'");
			keyname = what;
		else
			load = function() return {what} end;
			keyname = keyname or UNKNOWN;
		end
		-- save Watchers
		if type(what) == "string" then -- only if watching a string - for now
			SavedWatchers[id] = what;
		else
			SavedWatchers[id] = false;
		end
		return frame;
	else
		local e = format(ERROR1, tostring(what))
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
		Watchers[id]:Remove();
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
			f:StopMovingOrSizing();
		end
	end
end

---
-- Returns all Watchers. This is mostly a debugging function, but it does return
-- a table of the stable Watcher objects.
-- DO NOT change the keys of the table.
-- DO NOT modify the Watchers unless through their API.
function Addon.API.getWatchers()
	return Watchers;
end

-- assign addon-api locally
watch = Addon.API.watch
unwatch = Addon.API.unwatch
rewatch = Addon.API.rewatch
watchstr = Addon.API.watchstr

-- ##      ##      ###     ########    ######    ##     ##   ########  ######## 
-- ##  ##  ##     ## ##       ##      ##    ##   ##     ##   ##        ##     ##
-- ##  ##  ##    ##   ##      ##      ##         ##     ##   ##        ##     ##
-- ##  ##  ##   ##     ##     ##      ##         #########   ######    ######## 
-- ##  ##  ##   #########     ##      ##         ##     ##   ##        ##   ##  
-- ##  ##  ##   ##     ##     ##      ##    ##   ##     ##   ##        ##    ## 
--  ###  ###    ##     ##     ##       ######    ##     ##   ########  ##     ##

local Watcher_MT = {__index = Watcher};

---
-- Analyses the Stack of the Watcher and assembles a function to be called when
-- the Watcher updates.
-- This is run every time the Watcher is changed - ie. not very often.
-- TODO: rewrite to use `format` and 
local function Watcher_Eval(self)
	local expr, etype = "", "expression";
	local stack = {}; -- stack for passing non-renderable arguments to closure

	-- First element requires special handling (for now)
	local op, expr1, arg = unpack(self.Stack[1] or {});
	if op == "code" then
		-- if match(expr1, "^[a-zA-Z_]+$") then
			expr = expr .. expr1;
		-- else
		-- 	expr = expr .. "(" .. expr1 .. ")";
		-- end
	else
		stack[1] = expr1;
		expr = "stack[1]";
	end

	for i=2, #self.Stack do
		local op, key, arg = unpack(self.Stack[i]);
		local key_t = type(key);

		if op == "call" then
			expr = expr .. "()";
		elseif op == "index" then
			if key_t == "string" then
				if match(key, "^[_a-zA-Z][_a-zA-Z0-9]*$") then
					expr = expr .. "." .. key;
				else
					expr = expr .. "['" .. key .. "']";
				end
			elseif key_t == "number" then
				expr = expr .. "[" .. key .. "]";
			else
				stack[#stack+1] = key;
				expr = expr .. "[stack[" .. #stack .. "]]";
			end
		elseif op == "method" and key_t == "string" and
				match(key, "^[_a-zA-Z][_a-zA-Z0-9]*$") then
			expr = expr .. ":" .. key .. "()";
		else
			error(format(ERROR2, op, key))
		end
	end

	self.Expression = expr;
	
	print(format(watchcase, expr, expr));
	print(unpack(stack));

	local closure,e=loadstring(format(watchcase,expr,expr),"Watch: '"..expr.."'");
	if closure == nil then
		return function() return nil, e; end
	else
		return function() return pcall(closure, stack); end
	end
end

---
-- Creates a new watcher
-- @param what (mixed) the thing to watch. Can be of any type. Including nil,
--        false, userdata, etc.
-- @param hint a string hint that may be shown on the title, defaults to 
--        `tostring(what)` if falsy. If truthy, `what` will be evaluated as a
--        variable instead of Lua-code. Truthy-ness is only tested if `what` is 
--        not a string.
-- @returns (object) Watcher
function Watcher.Create(what, hint)
	local watcher = setmetatable({}, Watcher_MT);
	tinsert(Watchers, watcher);
	local id = #Watchers;
	WatcherIds[watcher] = id;
	watcher.Id = id;
	watcher.NumKeys = 0;
	watcher.Keys = {};
	watcher.Values = {};
	watcher.Lines = {};

	watcher.Stack = {};
	if type(what) == "string" and not hint then -- Evaluate 'what' as Lua
		watcher.Stack[1] = {"code", what, what};
	else
		watcher.Stack[1] = {"variable", what, hint or tostring(what)};
	end

	watcher.Frame = Addon.GetFrame(watcher);
	watcher:Save();
	return watcher;
end

---
-- Returns a sorted list of all keys for this Watcher
-- @returns (array)
-- @TODO
function Watcher:GetKeys()
	return self.Keys or {};
end

---
-- Returns the number of keys returned by the current expression
-- @returns (integer) number of keys 0..inf.
function Watcher:GetNumKeys()
	return self.NumKeys;
end

---
-- Refreshes the data behind the watcher.
-- Work is spread among multiple frames for performance reasons.
-- @returns (nothing)
-- @TODO
function Watcher:Refresh()
	assert(self.Frame); -- Frame is nil if Refresh is run in the same game-time-
	                    -- frame as the ui frame is created. This function can
	                    -- not be run at this point.
	-- debugprofilestart() -- TODO: REMOVE

	-- TODO: embed this into Watcher_Eval return function instead
	local function wrapper(ok, ...)
		return ok, {...};
	end

	local ok, value = wrapper(self:Run());
	if not ok then
		self.Type   = "ERROR";
		self.Keys   = {1, 2};
		self.Values = {"|cFFFF0000ERROR|r", tostring(value[1])};
		return self.Keys;
	end

	local V, Vt, keys, numKeys = value, "none", self.Keys, 0;
	if #V > 1 then
		Vt = "list";
	else
		V = V[1];
		Vt = type(V);
	end
	self.Type = Vt;
	if Vt == "table" then
		local numbers, strings, others, ik,is,io = {}, {}, {}, 0,0,0;
		for k in pairs(V) do
			local t = type(k);
			if t == "number" then
				ik=ik+1; numbers[ik] = k;
			elseif t == "string" then
				is=is+1; strings[is] = k;
			else
				io=io+1;  others[io] = k;
			end
		end
		-- ui object?
		if type(rawget(V,0))=="userdata" and type(V.GetObjectType)=="function" then
			self.Type = "Object";
			self.UIObjectType = V:GetObjectType();
			for k in pairs(getmetatable(V).__index) do
				local t = type(k);
				if t == "number" then
					ik=ik+1; numbers[ik] = k;
				elseif t == "string" then
					is=is+1; strings[is] = k;
				else
					io=io+1;  others[io] = k;
				end
			end
		end

		-- defer evaluation - sort keys
		local watcher = self;
		self.Frame:SetScript("OnUpdate", function(self)
			-- debugprofilestart() -- TODO: REMOVE
			
			sort(numbers);
			sort(strings);
			sort(others, defensive_sort);

			-- print("TOCK #keys", #keys, debugprofilestop()) -- TODO: REMOVE
			-- defer evaluation - merge key tables
			self:SetScript("OnUpdate", function(self, ... )
				-- debugprofilestart() -- TODO: REMOVE

				local i, keys = ik, numbers;
				for j=1, is do i=i+1; keys[i] = strings[j]; end
				for j=1, io do i=i+1; keys[i] =  others[j]; end
				
				watcher.NumKeys = ik + is + io;
				watcher.Keys = keys;
				watcher.Values = V;
				watcher.Lines = {};
				self:SetScript("OnUpdate", nil);

				-- print("TUCK #keys", #keys, debugprofilestop()) -- TODO: REMOVE
				
				self:Update();
			end)
		end)
		-- print("TICK #keys", #keys, debugprofilestop()) -- TODO: REMOVE
		return; -- we don't want to run the rest of the stuff right now
	elseif Vt == "list" then
		for i=1, #V do keys[i] = i; end
		self.Values = V;
		self.Lines = {};
		self.Keys = keys;
	else
		keys[1] = 1;
		self.Values = {V};
		self.Lines = {};
		self.Keys = keys;
	end

	self.Frame.NumKeys = self.NumKeys;
	self.Frame:Update();
	-- print("REFRESH #keys", #keys, debugprofilestop()) -- TODO: REMOVE
end

---
-- Returns a sorted list of all keys for this Watcher
-- @param key (mixed) returns a highlighted string for the given key
-- @returns (array)
-- @TODO
function Watcher:GetHighlightedLine(key)
	if key == nil then
		return STR_RED:format("Key is nil");
	end
	if self.Lines[key] then
		return self.Lines[key];
	end
	local tpl1, tpl2 = "[%s] = %s %s", "%s %s,";
	local value, retval, opt = self.Values[key], "", "";
	local vt = type(value);

	if vt == "function" and self.Type == "Object" and self.UIObjectType and Safe_Methods[key] then
		local vv, r = {value(self.Values)}, {};
		for i=1,min(4, #vv) do
			r[i] = color_string(vv[i]);
		end
		if #vv > 4 then r[5] = "..."; end
		retval = table.concat(r, ", ");
	else
		retval = color_string(value);
	end

	if self.Type ~= "table" and self.Type ~= "userdata" and self.Type ~= "Object" then
		self.Lines[key] = tpl2:format(opt, retval);
	else
		self.Lines[key] = tpl1:format(color_string(key), opt, retval);
	end
	return self.Lines[key];
end

---
-- Returns the current integer ID of this Watcher
-- @returns (integer) ID
function Watcher:GetId()
	return WatcherIds[self];
end

---
-- Walks the stack to evaluate 
function Watcher:Eval_x()
	local expr = "return ";
	local now = nil;

	local op, key, arg = unpack(self.Stack[1]);
	if op == "string" then
		now = pcall(loadstring(key))
	elseif op == "expression" then
		now = pcall(loadstring(key))
	end

	for i=2, i < #self.Stack do
		local op, key, arg = unpack(self.Stack[i]);
		local arg_t = type(key);

		if op == "call" then
			expr = expr .. "()";
		elseif op == "index" then
			if arg_t == "string" then
				if match(key, "^[_a-zA-Z][_a-zA-Z0-9]*$") then
					expr = expr .. "." .. key;
				else
					expr = expr .. "['" .. key .. "']";
				end
			elseif arg_t == "number" then
				expr = expr .. "[" .. key .. "]";
			else
				expr = expr .. "['" .. key .. "']";
			end
		elseif false and op == "methodcall" then
			if arg_t == "string" then
				if match(key, "^[_a-zA-Z][_a-zA-Z0-9]*$") then
					expr = expr .. "." .. key;
				else
					expr = expr .. "['" .. key .. "']";
				end
			elseif arg_t == "number" then
				expr = expr .. "[" .. key .. "]";
			else
				expr = expr .. "['" .. key .. "']";
			end
		end
	end
	loadstring()
end


---
-- Runs the current watcher expression.
-- This effectively executes the expression and returns its result.
-- @returns (mixed) the result of the Watcher or `nil` followed by an error
--    message.
function Watcher:Run()
	self.Run = Watcher_Eval(self);
	return self:Run();
end

---
-- Drill down from this Watcher.
-- @param key (mixed) the key of the field to drill down into
-- @param call (boolish) whether to call the field (i.e. as a function), or
--        handle it as a inactive table field.
-- @param new (boolish) whether to create a new Watcher for drill-down
function Watcher:Descend(key, call, new)
	local w = self;
	if new then
		w = Watcher.Create(select(2, unpack(self.Stack[1])));
		for i=1, #self.Stack do
			w.Stack[i] = self.Stack[i];
		end
	end

	w.Run = nil; -- resets "Run" to "Run"-from-metatable
	w.Stack[#w.Stack+1] = {'index', key};

	if call then
		w.Stack[#w.Stack+1] = {'call'};
	end

	return w;
end

---
-- Returns a meaningful title if possible
-- @returns (string) the title
function Watcher:GetTitle()
	return self.Expression or "<unknown>";
end

function Watcher:Update(...)
	self.Frame:Update(...);
end

function Watcher:UpdateId()
	self.Frame.TitleID:SetText(self:GetId());
	self:Save();
end

---
-- Returns whether the watcher can be persisted through WoW sessions.
-- Mostly what prevents watchers to be saved are keys that are non-constant
-- values (i.e. functions, tables, userdata) and initial watch expressions that
-- can't be run from the global namespace
-- @returns true if the Watcher can be saved, falsy if not.
function Watcher:IsSaveable()
	local s, saveable = self.Stack, true;
	for i=1, #s do
		print(unpack(s))
		local op, key, arg = unpack(s[i]);
		local t2, t3 = type(key), type(arg);
		if t2 == "function" or t2 == "userdata" or t2 == "table" or
		   t3 == "function" or t3 == "userdata" or t2 == "table"
		then
			saveable = false;
			break;
		end
	end

	return saveable;
end

---
-- Returns the shelf the current Watcher is in.
-- @returns shelf
function Watcher:GetShelf()
	if Watch_Shelves_Current then
		return Watch_Shelves[Watch_Shelves_Current];
	end
	
	-- date("%Y%m%d-%H%M")
	local u,shelfid,lastused = UnitName("player").."-"..GetRealmName(),false,"";
	for k,v in pairs(Watch_Shelves) do
		if Watch_Config.Character_Mode and v.Last_Owner == u and lastused < v.Last_Used then
			lastused = v.Last_Used;
			shelfid = k;
		elseif lastused < v.Last_Used then
			lastused = v.Last_Used;
			shelfid = k;
		end
	end

	if not Watch_Shelves[shelfid] then
		Watch_Shelves[shelfid] = {
			Last_Owner = u,
			Last_Used = date("%Y%m%d-%H%M"),
		}
	end

	return Watch_Shelves[shelfid];
end

---
-- Saves the current watcher. Position, watch-data, etc.
function Watcher:Save()
	if self:IsSaveable() then
		local shelf = self:GetShelf();
		shelf[self:GetId()] = self.Stack;
		
		self.Frame:StopMovingOrSizing() -- TODO: Inline, will be part of Watcher, not Frame.
		SavedWatchers[self:GetId()] = self.Stack;
	else
		SavedWatchers[self:GetId()] = false;
	end
end

---
-- Removes this Watcher.
function Watcher:Remove()
	local id = WatcherIds[self];
	WatcherIds[self] = nil;
	tremove(Watchers, id);
	tremove(SavedWatchers, id);
	tremove(SavedWatchersPos, id);

	self.Frame:Hide();
	tinsert(Frame_Buffer, self.Frame);

	-- Give all of them new IDs
	local i = 1;
	for watcher, oldId in pairs(WatcherIds) do
		WatcherIds[watcher] = i;
		i = i + 1;
		watcher:UpdateId();
	end

	if #Watchers == 0 then
		Updater_Frame:Hide();
	end
end

--
-- ##########     ## ##    ##  ###### ######## ####  #######  ##    ##  ######
-- ##      ##     ## ###   ## ##    ##   ##     ##  ##     ## ###   ## ##    ##
-- ##      ##     ## ####  ## ##         ##     ##  ##     ## ####  ## ##
-- #####   ##     ## ## ## ## ##         ##     ##  ##     ## ## ## ##  ######
-- ##      ##     ## ##  #### ##         ##     ##  ##     ## ##  ####       ##
-- ##      ##     ## ##   ### ##    ##   ##     ##  ##     ## ##   ### ##    ##
-- ##       #######  ##    ##  ######    ##    ####  #######  ##    ##  ######

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

local color_string_patterns = {
	["string"]   = "%s|cFF007700\"%s\"|r",
	["number"]   = "%s|cFFFF00FF%s|r",
	["function"] = "%s%s",
	["table"]    = "%s%s",
	["true"]     = "%s|cFF00FF00%s|r",
	["false"]    = "%s|cFFFF0000%s|r",
	["nil"]      = "%s|cFFFF0000%s|r",
	["Object"]   = "%s: %s",
	FORBIDDEN    = "%s|cFFFF0000Forbidden|r: %s",
}

color_string = function(value)
	local vt, bonus = type(value), "";

	if vt=="table" and type(rawget(value,0))=="userdata" and type(value.GetObjectType)=="function" then
		if value.IsForbidden and value:IsForbidden() then
			vt = "FORBIDDEN";
			value = value or "(anon)";
		else
			vt = "Object";
			bonus = value:GetName() or "(anon)";
		end
	elseif vt == "string" then
		value = value:gsub("\n","|n");
	elseif vt == "boolean" then
		vt = tostring(value);
	else
		value = gsub(tostring(value), "[|]", "_"); -- TODO: Check for ... why do I replace this???
	end
	
	-- remove stuff we don't like so we don't break HTML
	-- retval = gsub(retval, ">", "&gt;");
	-- retval = gsub(retval, "<", "&lt;");
	--retval = gsub(retval, "&", "&amp;");
	if color_string_patterns[vt] then
		return color_string_patterns[vt]:format(bonus, tostring(value));
	else
		return tostring(value);
	end
end

--    ###    #######  #######   #######  ##    ##    #### ##    ## ############
--   ## ##   ##    ## ##    ## ##     ## ###   ##     ##  ###   ##  ##    ##
--  ##   ##  ##    ## ##    ## ##     ## ####  ##     ##  ####  ##  ##    ##
-- ##     ## ##    ## ##    ## ##     ## ## ## ##     ##  ## ## ##  ##    ##
-- ######### ##    ## ##    ## ##     ## ##  ####     ##  ##  ####  ##    ##
-- ##     ## ##    ## ##    ## ##     ## ##   ###     ##  ##   ###  ##    ##
-- ##     ## #######  #######   #######  ##    ##    #### ##    ## ####   ##

---
-- Command-interface for Watch
local function watchci(msg, editbox)
	local splitter, nxt = string.gmatch(msg, "%s*([^%s]+)%s*");

	local cmd = splitter();
	if cmd == "help" then
		print("|cFFFF7777Watch|r available commands:");
		print(" - list |cFFBBBBBB-- Lists saved shelves");
		print(" - shelve [name] |cFFBBBBBB-- Puts the current session on a "..
			  "shelf. If no name is supplied, the shelf is named '[char] - "..
			  "[datetime]' ");
		print(" - restore [name|id] |cFFBBBBBB-- Restores a previous session "..
			  "from a shelf. You can use either name or id, but IDs are "..
			  "searched for first. If you ommit the argument, the most recent"..
			  " session from the current character is restored.");
	elseif cmd == "list"  then
	elseif cmd == "shelve"  then
	elseif cmd == "restore"  then

	end
	--watch(...);
end

-- Setup slash commands
SlashCmdList["WATCH"  ] = watchstr;  SLASH_WATCH1 = "/watch";
SlashCmdList["UNWATCH"] = unwatch; SLASH_UNWATCH1 = "/unwatch";
SlashCmdList["REWATCH"] = rewatch; SLASH_REWATCH1 = "/rewatch";
SlashCmdList["WATCHCI"] = watchci; SLASH_WATCHCI1 = "/watch!";
--SlashCmdList["WATCH_PT"] = watchprint; SLASH_WATCH_PT1 = "/print";

do -- Set up global update frame (spread watcher evaluations across game-frames)
	Updater_Frame = CreateFrame("frame");
	Updater_Frame:EnableMouse(false);
	Updater_Frame:Hide();
	local update_pos = 1;
	local update_dt = 0;
	local update_dt_min = 0.5;
	Updater_Frame:SetScript("OnUpdate", function(self, elapsed)
		if update_dt < update_dt_min then
			update_dt = update_dt + elapsed;
			return;
		end

		if not Watchers[1] then
			return self:Hide(); -- we assume there's nothing to update then
		end

		if update_pos > #Watchers then
			update_dt = elapsed;
			update_pos = 1;
		end
		
		if Watchers[update_pos] then
			--Watchers[update_pos]:Update("UPDATE", update_dt, elapsed);
			Watchers[update_pos]:Refresh("UPDATE", update_dt, elapsed);
		end
		update_pos = update_pos+1;
	end);
	
	local Addon_Registered_With_Ace = false;
	local Addon_Varaibles_Loaded = false;
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
