local MAJOR, MINOR = "LibObjectDocumentation-1.0", 1
local Lib = LibStub:NewLibrary(MAJOR, MINOR);
if not Lib then
	return;
end

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
function Lib:SetDefaultParser(parser)
	
end
function Lib:InsertType(object, id, ...)
	local object_clone = {};
	local metatable = {};
	-- Check if id well-formed
	if type(id) ~= "string" then
		error(MAJOR.." Error: Type id not well formed (id should be string but is "..type(id)..")");
	end
	if not id:match("[a-Z][a-Z0-9_ -]+") then
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
	
	-- refine metatable
	metatable.index = function(tbl, key)
		local mt = getmetatable(tbl);
		for k,parent in pairs(mt.parents) do
			if parent[key] then
				return parent[key];
			end
		end
	end;
	metatable.newindex = function(tbl, key)
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

do -- builtin objects

local t;
local Object = {
	GetObjectType = {
		type = 2,
		desc = "Returns the object's type.",
		info = [[
==Usage==
 {{type}}:GetObjectType();

==Return values==
*string: The object's type.
]]
	},
}
Lib:InsertType(Object, "Object");

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

local AnimationGroup = {
	CreateAnimation = {type = 9, desc = "Create and return an Animation as a child of this group."}
	Finish          = {type = 9, desc = "Notify this group to stop playing once the current loop cycle is done. Does nothing if this group is not playing."},
	Pause           = {type = 9, desc = "Pause the animations in this group."},
	Play            = {type = 9, desc = "Start playing the animations in this group."},
	Stop            = {type = 9, desc = "Stop all animations in this group."},
	GetDuration     = {type = 2, desc = "Gets the total duration across all child Animations that the group will take to complete one loop cycle."}
	GetLooping      = {type = 2, desc = "Gets the type of looping for the group."}
	GetLoopState    = {type = 2, desc = "Gets the current loop state of the group. Output is [NONE, FORWARD, or REVERSE]."}
	GetProgress     = {type = 2, desc = "Returns the progress of this animation as a unit value [0,1]."}
	GetScript       = {type = 2, desc = "Same as Frame:GetScript. Input is [OnLoad, OnPlay, OnPaused, OnStop, OnFinished, OnUpdate]."}
	HasScript       = {type = 3, desc = "Same as Frame:HasScript. Input is [OnLoad, OnPlay, OnPaused, OnStop, OnFinished, OnUpdate]."}
	IsDone          = {type = 2, desc = "Returns true if the group has finished playing."}
	IsPlaying       = {type = 2, desc = "Returns true if the group is playing."}
	IsPaused        = {type = 2, desc = "Returns true if the group is paused."}
	SetLooping      = {type = 1, desc = "Sets the type of looping for the group. Input is [NONE, REPEAT, or BOUNCE]."}
	SetScript       = {type = 1, desc = "Same as Frame:SetScript. Input is [OnLoad, OnPlay, OnPaused, OnStop, OnFinished, OnUpdate]."}
}
Lib:InsertType(AnimationGroup, "AnimationGroup", "UIObject");

t = {};
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

-- Other
t = {};
Lib:InsertType(t, "WorldFrame", "Frame");

end