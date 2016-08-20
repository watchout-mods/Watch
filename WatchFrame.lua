local MAJOR, Addon = ...;
local Frame_Buffer, Empty = {}, {};

local dropdownconfig = { {
		text = "disable watcher", -- string. This is the text to put on this menu item.
		func = function(self, ...)
			--Addon.API.watch(self)
			--Addon.API.watch(self:GetParent().dropdown.Watcher)
			local f = self:GetParent().dropdown.Watcher;
			Addon.API.unwatch(f.Id);
		end, -- function. This is the function that will fire when you click on this menu item.
	}, {
		text = "",
		disabled = true,
	}, {
		text = "Show safe items only",
		disabled = true,
		func = function(...) return; end,
	}, {
		text = "Set interval",
		disabled = true,
		func = function(...) return; end,
	}, {
		text = "Set events",
		disabled = true,
		func = function(...) return; end,
	}, {
		text = "Auto-refresh",
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

local function WatchScrollFrame_onScroll(self, so)
	local offset = HybridScrollFrame_GetOffset(self, self.scrollFrame);
	local p = self:GetParent();
	local data, keys, drill = p.Data, p.Keys, p.Drilldown;

	for i=1,math.min(#self.buttons, #keys-offset) do
		local button, key = self.buttons[i], keys[i+offset];
		button:SetText(data[key]);
		button.Id = i+offset;
		if drill[key] ~= false then
			button.Key = key;
		else
			button.Key = nil;
		end
	end
	-- The following should iterate through buttons that are unused because the
	-- number of entries is < the number of visible buttons
	for i=#keys-offset+1,#self.buttons do
		local button = self.buttons[i];
		button:SetText("")
		button.Id = i+offset;
		button.Key = nil;
	end
end

local function WatchFrame_onEvent(self, event)
	--print("Watch", "update");
	local ok, value = pcall(self.Watch);
	if not ok then
		self.Data = Empty;
		self.Keys = Empty;
		self.Drilldown = Empty;
		self.Scrollframe.buttons[1]:SetText("|cFFFF0000ERROR"..value.."|r");
	else
		local data,keys,drill = Addon.Highlight(self.WatchString, value, "list");
		self.Data = data or Empty;
		self.Keys = keys or Empty;
		self.Drilldown = drill or Empty;
	end

	WatchScrollFrame_onScroll(self.Scrollframe, -1);
end

local function WatchFrame_enable(self, id, input, inputstring)
	self.Watch = input;
	self.WatchString = inputstring;
	self.Id = id;

	self.Title:SetText(inputstring);
	self.TitleID:SetText(tostring(self.Id));

	self:Show();
	self:SetToplevel(true);

	WatchFrame_onEvent(self, "UPDATE");

	self:SetWidth(self:GetWidth()+1);
	self:SetWidth(self:GetWidth()-1);

	return self
end

local function WatchFrame_unwatch(self)
	Addon.API.unwatch(self.Id);
end

local function WatchFrame_savePosition(self)
	local p = SavedWatchersPos[self.Id];
	if p then
		p[1], p[2], p[3], p[4] = self:GetRect();
	end
end

local function WatchFrame_init(self, id, input, inputstring)
	self.API = Addon.API;
	self.Unwatch = WatchFrame_unwatch;
	self.SavePosition = WatchFrame_savePosition;
	self.DropdownConfig = dropdownconfig;
	self.Update = WatchFrame_onEvent;

	self:SetScript("OnEvent", WatchFrame_onEvent);
	--self:SetScript("OnClick", nil);
	self.Scrollframe:SetScript("OnVerticalScroll", WatchScrollFrame_onScroll);
	
	--self.SimpleHTML:SetScript("OnHyperlinkClick", WatchFrameSimpleHTML_onHyperlink);

	return WatchFrame_enable(self, id, input, inputstring);
end

function Addon.GetFrame(id, input, inputstring)
	if #Frame_Buffer <= 0 then
		local f = CreateFrame("frame", nil, UIParent, "Watch2FrameTemplate");
		return WatchFrame_init(f, id, input, inputstring);
	else
		return WatchFrame_enable(table.remove(Frame_Buffer), id, input, inputstring);
	end
end
