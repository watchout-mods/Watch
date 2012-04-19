local MAJOR, MINOR = "LibObjectDocumentation-1.0", 1
local Lib = LibStub:NewLibrary(MAJOR, MINOR);
if not Lib then
	return;
end

--- Constant for setters
-- setters require one or more arguments and are not safe to call.
Lib.METHOD_TYPE_SETTER = 1;

--- Constant for getters
-- getters may require any number of arguments but are safe to call.
-- the interface may eventually allow definition of default arguments that yield
-- an exemplary return value.
Lib.METHOD_TYPE_GETTER = 2;

--- Constant for testers
-- Usually named Is*. Usually safe to call. But some may require arguments (like
-- :IsType(string)
Lib.METHOD_TYPE_TESTER = 3;

--- Constant for actions
-- Actions like :Play(), :Run(), :StopMovingOrSizing(), etc. They are all unsafe
-- thus will not be called.
Lib.METHOD_TYPE_ACTION = 4;

--- Constant for safe methods that may not be any of the above
Lib.METHOD_TYPE_SAFEOTHER = 8;

--- Constant for unsafe methods that may not be any of the above
Lib.METHOD_TYPE_UNSAFEOTHER = 9;

-- types: 
--   1 - Setter
--   2 - Getter 
--   3 - Tester (Is*, returns boolean, usually safe, but needs argument)
--   4 - Action (Do*, Copy*, etc.)
--   9 - misc/unknown
local ObjectLibrary = {};
local AllowedEntryKeys = {
	type = function(value) return value >= 1 and value <=9 and floor(value) == value; end,
	desc = function(value) return type(value) == "string"; end,
	more = function(value) return type(value) == "string"; end,
}
function Lib:SetDefaultMarkupParser(parser)
	
end
function Lib:InsertType(object, id, ...)
	local object_clone = {};
	local metatable = {};
	-- Check if id well-formed
	if type(id) ~= "string" then
		error(MAJOR.." Error: Type id not well formed (id should be string but is "..type(id)..")");
	end
	if not id:match("[a-Z_][a-Z0-9_ -]+") then
		error(MAJOR.." Error: Type id not well formed ("..tostring(id)..")");
	end
	-- entry metatable
	local entry_metatable = {
		index = function(tbl, val)
			if val == "parse" then
				
			end
		end,
	}
	
	-- Clone object and make sure it's well formed
	for k,v in pairs(object) do
		if type(k) ~= "string" then
			error(MAJOR.." Error: Table key not well formed (key should be string but is "..type(k)..")");
		end
		if not k:match("[a-Z][a-Z0-9_-]+") then
			error(MAJOR.." Error: Table key not well formed ("..tostring(k)..")");
		end
		if type(v) ~= "table" then
			error(MAJOR.." Error: Table entry not well formed (table expected, but found "..type(k)..")");
		end
		local entry = {};
		for j,w in pairs(v) do
			if AllowedEntryKeys[j] and AllowedEntryKeys[j](w) then
				entry[j] = w;
			else
				error(MAJOR.." Error: Table entry not well formed (invalid key or value "..tostring(k).."."..tostring(j)..")");
			end
		end
		-- add metatable
		
		object_clone[k] = entry;
	end
	
	-- handle parents
	for k,parent in pairs({...}) do
		if parent and type(parent) == "string" and ObjectLibrary[parent] then
			metatable.parents[parent] = true;
		else
			error(MAJOR.." Error: Type "..tostring(parent).." given as parent but is no valid parent.");
		end
	end
	
	-- refine metatable -- TODO: Make this into non-enclosed function
	metatable.index = function(tbl, key)
		local mt = getmetatable(tbl);
		for k,parent in pairs(mt.parents) do
			if parent[key] then
				return parent[key];
			end
		end
	end;
	metatable.newindex = function(tbl, key) -- TODO: Make this into non-enclosed function
		error(MAJOR.." Error: Do not write to this table.");
	end;
	setmetatable(object_clone, metatable);
	ObjectLibrary[id] = object_clone;
	
	return object_clone;
end

function Lib:GetTypeInfo(t, silent)
	if not ObjectLibrary[t] and not silent then
		error(MAJOR.." Error: Type not found '"..tostring(t).."'");
	end
	return ObjectLibrary[t];
end

function Lib:GetMethodDescription(t, m, silent)
	local u = ObjectLibrary[t];
	if not u then
		return "";
	end
	local v = u[m];
	if not v then 
		return "";
	end
	
	
	
end

---
-- Returns whether a method is classified as a simple getter method (meaning a
-- method that does not modify the object and requires no arguments)
function Lib:IsSimpleGetter(t, m, silent)
	local u = ObjectLibrary[t];
	if not u then
		if not silent then
			error(MAJOR.." Error: Type not found '"..tostring(t).."'");
		end
		u = {};
	end
	
	return u[m] and (u[m] == 2);
end


function DefaultMarkupParser(typenode, method, text)
	-- todo: error handling for typenode[method]
	text = text or rawget(typenode[method], "desc");
	-- replace double(or more) newlines with single newline
	text = text:gsub("\n\n+", "<br/>");
	-- remove single newlines
	text = text:gsub("\n", " ");
	-- remove multiple spaces
	text = text:gsub(" +", " ");
	
	
	local t = {text:split("<br/>")};
	local r = {};
	
	for k,line in ipairs(t) do
		-- remove whitespace at end and beginning
		line = strtrim(line);
		-- parse headers
		line = line:gsub("^==(.*)==(.*)", "|n|cffffcc00%1|r|n%2|n");
		-- parse lists
		line = line:gsub("^%*%s*", "  |TInterface\\QUESTFRAME\\UI-Quest-BulletPoint:12:12|t ");
		-- parse templates
		local function callback(hit)
			if hit
		end
		line = line:gsub("{{([%.%^])?(%w+)}}", type);
	end
end






--------------------------------------------------------------------------------
--------------------------- BUILT IN OBJECT HIERARCHY --------------------------
--------------------------------------------------------------------------------
do -- builtin objects

local t;
local Object = {
	GetObjectType = {
		type = 2,
		desc = "Returns the object's type.",
		more = [[
==Usage==
 {{type}}:GetObjectType();

==Return values==
*string: The object's type.
]]
	},
}
Lib:InsertType(Object, "Object");

-- script interface
local i = {}
i.GetScript = {};
i.GetScript.type = 3;
i.GetScript.args = '"Handler"';
i.GetScript.desc = [[
Get the function for the given handler.
 function = {{call}}
==Arguments==
;Handler [string]: The required handler
==Return values==
#[function] the function set as a handler, or nil if no handler was set.
]];
i.HasScript = {};
i.HasScript.type = 3;
i.HasScript.args = '"Handler"';
i.HasScript.desc = [[
Return true if the {{type}} supports the given handler.
 boolean = {{call}}
==Arguments==
;Handler:The required handler
{{handlers}}
]];
i.HasScript.handlers = [[
==Supported Handlers==
Arguments passed to the handler function are in parentheses
* OnEvent(self, event, ...) Called when a registered event occured.
* OnLoad(self) Called when the {{type}} is created. Only useful when created by XML
* OnUpdate(self, elapsed) Called each time the screen is drawn by the game engine.
]]

i.SetScript = {};
i.SetScript.type = 1;
i.SetScript.args = '"Handler", function(...)';
i.SetScript.desc = [[
 nil = {{call}}
Set the function to use for a handler on this {{type}}.
==Arguments==
;Handler:The required handler
]];
Lib:InsertType(i, "_Script");


local UIObject = {
	GetParent = {
		type = 2,
		desc = "returns the parent UIObject.",
		more = [[
inherited from [[UIObject]]
		
==Usage==
 uiobject = {{type}}:GetParent()

==Returns==
* the parent UIObject.
]],
	},
	GetAlpha = {
		type = 2,
		desc = "",
		more = [[
]]
	},
	GetName = {
		type = 2,
		desc = "",
		more = [[
]]
	},
	GetObjectType = {
		type = 2,
		desc = "",
		more = [[
]]
	},
	IsObjectType = {
		type = 3,
		desc = "",
		more = [[
]]
	},
	SetAlpha = {
		type = 1,
		desc = "Sets the transparency (alpha-value) of an UIObject",
		more = [[
inherited from [[UIObject]]
==Usage==
 {{type}}:SetAlpha(value)
==Arguments==
;value:floating point value. Can have a value from 0 to 1.
]]
	},
}
Lib:InsertType(UIObject, "UIObject");

t = {
	CreateAnimation = {type = 9, desc = "Create and return an Animation as a child of this group."}
	Finish          = {type = 9, desc = "Notify this group to stop playing once the current loop cycle is done. Does nothing if this group is not playing."},
	Pause           = {type = 9, desc = "Pause the animations in this group."},
	Play            = {type = 9, desc = "Start playing the animations in this group."},
	Stop            = {type = 9, desc = "Stop all animations in this group."},
	GetDuration     = {type = 2, desc = "Gets the total duration across all child Animations that the group will take to complete one loop cycle."}
	GetLooping      = {type = 2, desc = "Gets the type of looping for the group."}
	GetLoopState    = {type = 2, desc = "Gets the current loop state of the group. Output is [NONE, FORWARD, or REVERSE]."}
	GetProgress     = {type = 2, desc = "Returns the progress of this animation as a unit value [0,1]."}
	GetScript       = {type = 3, desc = "Same as Frame:GetScript. Input is [OnLoad, OnPlay, OnPaused, OnStop, OnFinished, OnUpdate]."}
	HasScript       = {type = 3, desc = "Same as Frame:HasScript. Input is [OnLoad, OnPlay, OnPaused, OnStop, OnFinished, OnUpdate]."}
	IsDone          = {type = 2, desc = "Returns true if the group has finished playing."}
	IsPlaying       = {type = 2, desc = "Returns true if the group is playing."}
	IsPaused        = {type = 2, desc = "Returns true if the group is paused."}
	SetLooping      = {type = 1, desc = "Sets the type of looping for the group. Input is [NONE, REPEAT, or BOUNCE]."}
	SetScript       = {type = 1, desc = "Same as Frame:SetScript. Input is [OnLoad, OnPlay, OnPaused, OnStop, OnFinished, OnUpdate]."}
}
Lib:InsertType(t, "AnimationGroup", "UIObject", "_Script");

t = {
	Pause           = {type = 9, desc = "Pause the animation."},
	Play            = {type = 9, desc = "Start playing the animation."},
	Stop            = {type = 9, desc = "Stop the animation."},
	GetDuration     = {type = 2, desc = "Get the number of seconds it takes for the animation to progress from start to finish. "},
	GetElapsed      = {type = 2, desc = "Gets the amount of time in seconds that the animation has been playing for. "},
	GetEndDelay     = {type = 2, desc = "Get the number of seconds the animation delays after finishing. "},
	GetMaxFramerate = {type = 2, desc = "Gets the maximum frames per second that the animation will update its progress. "},
	GetOrder        = {type = 2, desc = "Gets the order of the animation within its parent group. "},
	GetProgress     = {type = 2, desc = "Returns the progress of the animation as a unit value [0,1]. Ignores start and end delay. "},
	GetProgressWithDelay = {type = 2, desc = "Returns the progress of the animation combined with its start and end delay. "},
	GetRegionParent = {type = 2, desc = "Gets the Region object that the animation operates on. The region object is this Animation's parent's parent (the AnimationGroup's parent). "},
	GetSmoothing    = {type = 2, desc = "Gets the smoothing type for the animation. "},
	GetSmoothProgress = {type = 2, desc = "Returns a smoothed, [0,1] progress value for the animation. "},
	GetStartDelay   = {type = 2, desc = "Get the number of seconds that the animation delays before it starts to progress. "},
	IsDone          = {type = 2, desc = "Returns true if the animation has finished playing."}
	IsPlaying       = {type = 2, desc = "Returns true if the animation is playing."}
	IsPaused        = {type = 2, desc = "Returns true if the animation is paused."}
	IsDelaying      = {type = 2, desc = "Returns true if the animation is in the middle of a start or end delay. "},
	SetStartDelay   = {type = 1, desc = "Set the number of seconds that the animation delays before it starts to progress. "},
	SetEndDelay     = {type = 1, desc = "Set the number of seconds the animation delays after finishing. "},
	SetDuration     = {type = 1, desc = "Set the number of seconds it takes for the animation to progress from start to finish. "},
	SetMaxFramerate = {type = 1, desc = "Sets the maximum frames per second that the animation will update its progress. "},
	SetOrder        = {type = 1, desc = "Sets the order that the animation plays within its parent group. Range is [1,100]. "},
	SetSmoothing    = {type = 1, desc = "Sets the smoothing type for the animation. Input is [IN,OUT, or IN_OUT]. "},
	SetParent       = {type = 1, desc = "Sets the parent for the animation. If the animation was not already a child of the parent, the parent will insert the animation into the proper order amongst its children. "},
	HasScript       = {type = 3, desc = "Same as Frame:HasScript, Input is [OnLoad, OnPlay, OnPaused, OnStop, OnFinished, OnUpdate]. "},
	GetScript       = {type = 3, desc = "Same as Frame:GetScript, Input is [OnLoad, OnPlay, OnPaused, OnStop, OnFinished, OnUpdate]. "},
	SetScript       = {type = 1, desc = "Same as Frame:SetScript, Input is [OnLoad, OnPlay, OnPaused, OnStop, OnFinished, OnUpdate]. "},
};
Lib:InsertType(t, "Animation", "UIObject");
t = {};
Lib:InsertType(t, "Translation", "Animation");
t = {};
Lib:InsertType(t, "Rotation", "Animation");
t = {};
Lib:InsertType(t, "Scale", "Animation");
t = {};
Lib:InsertType(t, "Alpha", "Animation");

t = {};
Lib:InsertType(t, "FontInstance", "UIObject");
t = {};
Lib:InsertType(t, "Font", "FontInstance");

t = {};
Lib:InsertType(t, "Region", "UIObject");

-- Region derivatives
t = {};
Lib:InsertType(t, "Frame", "Region");
t = {};
Lib:InsertType(t, "LayeredRegion", "Region");

-- Frame derivatives
t = {};
Lib:InsertType(t, "Button", "Frame");
t = {};
Lib:InsertType(t, "Cooldown", "Frame");
t = {};
Lib:InsertType(t, "ColorSelect", "Frame");
t = {};
Lib:InsertType(t, "EditBox", "Frame", "FontInstance");
t = {};
Lib:InsertType(t, "GameTooltip", "Frame");
t = {};
Lib:InsertType(t, "MessageFrame", "Frame", "FontInstance");
t = {};
Lib:InsertType(t, "Minimap", "Frame");
t = {};
Lib:InsertType(t, "Model", "Frame");
t = {};
Lib:InsertType(t, "ScrollFrame", "Frame");
t = {};
Lib:InsertType(t, "ScrollingMessageFrame", "Frame", "FontInstance");
t = {};
Lib:InsertType(t, "SimpleHTML", "Frame", "FontInstance"); -- special, read wiki
t = {};
Lib:InsertType(t, "Slider", "Frame");
t = {};
Lib:InsertType(t, "StatusBar", "Frame");

-- Button derivatives
t = {};
Lib:InsertType(t, "CheckButton", "Button");
t = {};
Lib:InsertType(t, "LootButton", "Button");

-- Model Derivatives 
t = {};
Lib:InsertType(t, "PlayerModel", "Button");

-- PlayerModel Derivatives 
t = {};
Lib:InsertType(t, "DressUpModel", "PlayerModel");
t = {};
Lib:InsertType(t, "TabardModel", "PlayerModel");

-- LayeredRegion Derivatives 
t = {};
Lib:InsertType(t, "Texture", "LayeredRegion");
t = {};
Lib:InsertType(t, "FontString", "LayeredRegion");

end -- end builtin objects