-- DoIKnowYou
-- enUS & enGB localisation.
local L = LibStub("AceLocale-3.0"):NewLocale("DoIKnowYou", "enUS", true)
if not L then return end

L["DoIKnowYou"] = true

-- Options texts

L["Options for DoIKnowYou!"] = true
L["Tooltip"] = true
L["Options for DoIKnowYou's additions to the game tooltip"] = true
L["Show reputation tooltip"] = true
L["Hide reputation tooltip when neutral"] = true
L["Show prefix"] = true
L["Prefix text:"] = true
L["Colour reputation text by reputation"] = true
L["Show comment tooltip"] = true
L["Hide comment tooltip when neutral"] = true
L["Show prefix:"] = true
L["Prefix text:"] = true
L["Colour comment text by reputation"] = true
L["Trusted tooltip comment authors to check when no personal comment exists (separated by commas):"] = true

L["Auto Query"] = true
L["Options for automatic queries"] = true
L["Use Auto Query"] = true
L["... when group members change"] = true
L["This event includes pretty much everything to do with a group, such as joining a new group, a new member joining an existing group, or someone leaving the group."] = true
L["... when whispering another player"] = true
L["This option enable auto-query when whispering another player, with data output to the summary frame."] = true
L["... when trading with another player"] = true
L["This option works like the others, on trade."] = true
L["... when you move your mouse over another player"] = true
L["This option creates a lot of queries, which you really won't need most of the time. You can already see your own data on tooltips, this simply broadcasts a request for data too, and adds info to the summary frame."] = true
L["Announce status in chat window"] = true
L["Announce the result of an auto-query in the chat window. This message will only be visible to yourself, not to other players."] = true
L["Report when auto-query returns neutral"] = true
L["When this option is disabled, you will only see reports on players with positive or negative ratings announced in your chat window."] = true

L["Other"] = true
L["Other options"] = true
L["Use right-click drop down \"Do I Know You?\""] = true
L["When enabled, the option \"Do I Know You?\" will be added to the right-click menu on players, allowing you to query them by that menu easily from chat channels, unit frames, etc.."] = true

L["Show reputation indicator in chat"] = true
L["When enabled, a colour-coded indicator will be added to your chat frame next to players names."] = true
L["Hide chat indicator when neutral"] = true
L["Chat indicator text:"] = true

L["Send addon messages"] = true
L["Parse incoming addon messages"] = true

L["Purge data from a guild when you no longer have any characters in it."] = true

-- Important!

L["Positive"] = true
L["Negative"] = true
L["Neutral"] = true

-- Frame texts
--Main frame
L["Data generated from %s sources."] = true -- number of data source
L["running query on %s"] = true -- player
L["Query on: %s"] = true -- player name
L["No notes received from shared data sources."] = true
L["Note for %s saved as \"%s\""] = true -- player name, note
L["Rep changed for %s to %d"] = true -- player name, rep (-1, 0 or 1)

L["Input the name of the player"] = true
L["Player comment:"] = true
L["Shared data:"] = true
L["Options"] = true
L["Console"] = true
L["Data View"] = true
L["From Target"] = true
L["Sync Data"] = "Refresh"
L["Global Sync"] = true


--Dataview
L["Search all saved data"] = true
L["Summary Data"] = true
L["Reset"] = true
L["Filter"] = true
L["Name"] = true
L["Note"] = true
L["Rep"] = true
L["Total"] = true
L["Sources"] = true
L["Notes"] = true

L["No data shown. Use the filters below to view data."] = true
L["Now viewing %d to %d of %d (Page %d of %d)"] = true

--Auto-query
L["Auto-Query (%s): %s has returned positive!"] = true
L["Auto-Query (%s): %s has returned neutral."] = true
L["Auto-Query (%s): %s has returned negative!"] = true

-- Other

L["Do I Know You?"] = true -- Dropdown text
L["DogTag-3.0 tags registered"] = true
L["r%d loaded. use /diky or /doiknowyou to access."] = true -- Loaded text
L["version is %d"] = true
L["Realm saved data purged."] = true
L[" error: Target must be a player character."] = true
L["You have left %s, no characters left in guild - purging data."] = true --  Guild name

L["Set DoIKnowYou note for this player"] = true

-- Slash command options

L["console"] = true
L["options"] = true
L["dataview"] = true
L["data"] = true
L["summary"] = true
L["version"] = true
L["versioncheck"] = true
L["purge"] = true

-- The slash commands!

L["/doiknowyou"] = true
L["/diky"] = true

