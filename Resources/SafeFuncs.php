<?php

# remove headers
preg_replace("^=+.*", "", $t);
# remove anything that does not start with :
preg_replace("^[^\:].*", "", $t);
# extract method name only
preg_replace(": \[\[.*\|([_\w]+\:[_\w]+)\]\]", "$1", $t);
# remove any overhead from methods that have no arguments 
preg_replace("^\w+:(\w+)\(\).*", "$1", $t);
# same for methods with only 1 argument
preg_replace("^\w+:(\w+)\(([^\,]+)\).*", "$1 ## $2", $t);
# find the rest and purge it
preg_replace("^.*\(.*", "", $t);
# remove anything starting with "Set"
preg_replace("^[Ss]et.*", "", $t);
# remove anything left with a colon somewhere in the line
preg_replace("^.*:.*", "", $t);
# strip the #-stuff
preg_replace("\s+##.*", "", $t);
# make a lua-compatible list
preg_replace("^(\w+)", '["$1"] = true,', $t);


$blacklist = array(
"Play",
"Pause",
"Stop",
"Finish",
"ClearAllPoints",
"Hide",
"Show",
"StopAnimating",
"CopyFontObject",
"CreateTitleRegion",
"DisableDrawLayer",
"EnableDrawLayer",
"EnableKeyboard",
"EnableMouse",
"EnableMouseWheel",
"IgnoreDepth",
"Lower",
"Raise",
"RegisterAllEvents",
"RegisterEvent",
"StartMoving",
"StartSizing",
"StopMovingOrSizing",
"UnregisterAllEvents",
"UnregisterEvent",
"Click",
"Disable",
"Enable",
"LockHighlight",
"UnlockHighlight",
"AddHistoryLine",
"ClearFocus",
"Insert",
"ToggleInputLanguage",
"AddTexture",
"AppendText",
"ClearLines",
"Clear",
"AdvanceTime",
"ClearFog",
"ClearModel",
"ReplaceIconTexture",
"UpdateScrollChildRect",
"Clear",
"PageDown",
"PageUp",
"ScrollDown",
"ScrollToBottom",
"ScrollToTop",
"ScrollUp",
"Disable",
"Enable",
"RefreshUnit",
"Dress",
"TryOn",
"Undress",
"InitializeTabardColors",
"Save",

# stuff that can't be used but is "safe"
"IsFrameType", ## "type"
"IsEventRegistered", ## "event"
"GetScript", ## "handler"
"IsUnit", ## "unit"
"GetLowerEmblemTexture", ## "textureName"
"GetUpperEmblemTexture", ## "textureName"
"HasScript", ## "handler"
"IsObjectType", ## "type"

# multiple footprints
#"GetFont", ## ["element"]
#"GetFontObject", ## ["element"]
#"GetJustifyH", ## ["element"]
#"GetJustifyV", ## ["element"]
#"GetPoint", ## pointNum
#"GetShadowColor", ## ["element"]
#"GetShadowOffset", ## ["element"]
#"GetSpacing", ## ["element"]
#"GetTextColor", ## ["element"]
)
?>