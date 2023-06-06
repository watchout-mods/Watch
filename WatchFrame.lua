local MAJOR, Addon = ...;
local Frame_Buffer, Empty = {}, {};

local min, max = math.min, math.max;

-- https://wow.gamepedia.com/Creating_simple_pop-up_dialog_boxes
StaticPopupDialogs["Watch_StringChange"] = {
  text = "Do you want to greet the world today?",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,

  OnAccept = function(self, data, data2)
      data.API.update(data.Id, self.editBox:GetText(), data.Key)
  end,
}

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


local function WatchScrollFrame_onScroll(self, so, ...)
	local offset = HybridScrollFrame_GetOffset(self, self.scrollFrame);
	local Watcher = self:GetParent().Watcher;
	local keys = Watcher:GetKeys();

	-- save current scroll-position so that we can keep it when resizing
	if so ~= -1 then -- ignore when onscroll was called from refresh
		self.scrollpos = offset;
	end

	for i=1,min(#self.buttons, #keys-offset) do
		local line, key = self.buttons[i], keys[i+offset];
		line:SetText(Watcher:GetHighlightedLine(key));
		line.Id = i+offset;
		line.Key = key;
	end
	-- The following should iterate through buttons that are unused because the
	-- number of entries is < the number of visible buttons
	for i=max(1, #keys-offset+1),#self.buttons do
		local line = self.buttons[i];
		line:SetText("-");
		line.Key = nil;
	end
end

local function WatchFrame_onLineClick(self, line, mousebutton)
	-- TODO: Handle mouse buttons and modifiers, maybe move back to .xml
	--print(line.Key, line.Id, line:GetText())
	if line.Key ~= nil then
		self.Watcher:Descend(line.Key, false, true);
	end
end

-- Called when GUI or Data changes such that re-rendering is required
local function WatchFrame_onEvent(self, event, ...)
	local watcher = self.Watcher;
	self.Title:SetText(watcher:GetTitle());
	self.TitleID:SetText(tostring(watcher:GetId()));

	local scroll = self.Scrollframe;
	local num = watcher:GetNumKeys();
	local bh = scroll.buttonHeight;
	self.NumKeys = num;

	HybridScrollFrame_Update(scroll, bh*num, bh);
	WatchScrollFrame_onScroll(scroll, -1);
end

local function WatchFrame_enable(self, watcher --[[, input, inputstring]])
	self.Watcher = watcher;
	self.Title:SetText(watcher:GetTitle());
	self.TitleID:SetText(tostring(watcher:GetId()));

	self:Show();
	self:SetToplevel(true);

	self.Scrollframe.stepSize = 53;

	WatchFrame_onEvent(self, "UPDATE");

	-- self:SetWidth(self:GetWidth()+1);
	-- self:SetWidth(self:GetWidth()-1);
	self:SetWidth(300);
	self:SetHeight(240);

	return self;
end

local function WatchFrame_unwatch(self)
	Addon.API.unwatch(self.Watcher:GetId());
end

local function WatchFrame_savePosition(self)
	local p = SavedWatchersPos[self.Watcher:GetId()];
	if p then
		p[1], p[2], p[3], p[4] = self:GetRect();
	end
end

local function WatchFrame_init(self, watcher)
	self.API = Addon.API;
	self.Unwatch = WatchFrame_unwatch;
	self.SavePosition = WatchFrame_savePosition;
	self.DropdownConfig = dropdownconfig;
	self.Update = WatchFrame_onEvent;
	self.OnLineClick = WatchFrame_onLineClick;
	self.Watcher = watcher;

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
