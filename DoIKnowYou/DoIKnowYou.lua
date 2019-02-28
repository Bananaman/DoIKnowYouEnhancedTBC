DoIKnowYou = LibStub("AceAddon-3.0"):NewAddon("DoIKnowYou", "AceEvent-3.0", "AceHook-3.0")

local L   = LibStub("AceLocale-3.0"):GetLocale("DoIKnowYou", false)
local gameLocale = GetLocale()

local VERSION_COMM = 1.14; local VERSION_DB = 1.14;
local VERSION = tonumber(("$Revision: 74680 $"):match("%d+"))
local latestVersion = VERSION
local commprefix = "DoIKnowYou" .. tostring(VERSION_COMM)
local versionCheckPrefix = "DoIKnowYouVersionCheck"
local namestring = "|cff00ff00D|cff18ff00o|cff30ff00I|cff48ff00K|cff60ff00n|cff78ff00o|cff90ff00w|cffa8ff00Y|cffc0ff00o|cffd8ff00u|r"

local CTL = assert(ChatThrottleLib, "DoIKnowYou requires ChatThrottleLib.")

local playername, playerguild
local addonEnabled = false
local chatOutBuffer = {}
local grscall = 0
local activeQuery = ""
local cData = {}; local cPointer = 0; local cLimit = 30;
local ignoreDialogName

local tEvents = {} -- timeToAct, method, args
local tQuery = {} -- name, query
local queryTTL = 3600 -- 60 minute query expire

local tSummaryData = {} -- name, note, rep, sources, notes
local summaryPage = 1; local summaryPerPage = 12; local summaryNoteLen = 40
local tViewing = {} -- stores the current table view, for paging!
local viewingQuery = "" -- stores the name of the person you cal query from dataview on, so we don't auto-summary it again.

local vFrame;

local oldPartyCount, tParty = 0, {}

local tVersions, versionRequest = {}, false

local dataTTL = 60 * 60 * 24 * 14 -- 2 week expiry time on notes.

local origGameTooltip

local tTrades, tWhispers = {}, {} -- simply the names of players who interact, for looking them up when reporting auto-query.

local DIKY_SOURCE = {}
DIKY_SOURCE["GUILD"]=1
DIKY_SOURCE["FRIEND"]=2

local defaultData = {
 	realm = {
		data = {},
		primaryChar = false,
		guilds = {},
	},
	profile = {
		showRepTooltip = true,
		hideRepNeutral = true,
		showRepPrefix = true,
		showRepPrefixText = "DoIKnowYou: ",
		colourRep = true,
		
		showCommentTooltip = true,
		hideCommentNeutral = true,
		showCommentPrefix = false,
		showCommentPrefixText = "",
		colourComment = true,
		trustedCommentAuthors = {"Trustedauthornames", "Inthislist"},
		
		useDropDown = true,
		
		useAutoQuery = true,
		autoQueryGroup = true,
		autoQueryWhisper = true,
		autoQueryTrade = true,
		autoQueryMouse = true,
		
		autoAnnounceChat = true,
		autoQueryReportNeutral = false,
		
		showChatIndicator = true,
		hideChatIndicatorNeutral = true,
		chatIndicatorText = "!",
		
		sendComms = true,
		recvComms = true,
		
		purgeGuildData = false,
		
		debugMode = false,
	},
	global = {
		version = 0,
	}
}

local optionsTable = {
	type = "group",
	name = L["DoIKnowYou"],
	desc = L["Options for DoIKnowYou!"],
	get = function(info) return DoIKnowYou.db.profile[info.arg] end,
	set = function(info, val) DoIKnowYou.db.profile[info.arg] = val end,
	childGroups = "tab",
	args = {
		group_tooltip = {
			type = "group",
			name = L["Tooltip"],
			desc = L["Options for DoIKnowYou's additions to the game tooltip"],
			order = 0,
			args = {
				showRepTooltip = {
					type = "toggle",
					name = L["Show reputation tooltip"],					
					arg = "showRepTooltip",
					width = "full",
					order = 1,
				},
				hideRepNeutral = {
					type = "toggle",
					name = L["Hide reputation tooltip when neutral"],
					arg = "hideRepNeutral",
					width = "full",
					order = 2,
					disabled = function() return not DoIKnowYou.db.profile.showRepTooltip; end,
				},
				showRepPrefix = {
					type = "toggle",
					name = L["Show prefix"],
					arg = "showRepPrefix",
					order = 3,
					disabled = function() return not DoIKnowYou.db.profile.showRepTooltip; end,
				},
				showRepPrefixText = {
					type = "input",
					name = L["Prefix text:"],
					arg = "showRepPrefixText",
					width = "double",
					order = 4,
					disabled = function() return not (DoIKnowYou.db.profile.showRepTooltip and DoIKnowYou.db.profile.showRepPrefix) end,
				},
				colourRep = {
					type = "toggle",
					name = L["Colour reputation text by reputation"],
					arg = "colourRep",
					width = "full",
					order = 5,
					disabled = function() return not DoIKnowYou.db.profile.showRepTooltip; end,
				},
		
				showCommentTooltip = {
					type = "toggle",
					name = L["Show comment tooltip"],
					arg = "showCommentTooltip",
					width = "full",
					order = 6,
				},
				hideCommentNeutral = {
					type = "toggle",
					name = L["Hide comment tooltip when neutral"],
					arg = "hideCommentNeutral",
					width = "full",
					order = 7,
					disabled = function() return not DoIKnowYou.db.profile.showCommentTooltip; end,
				},
				showCommentPrefix = {
					type = "toggle",
					name = L["Show prefix:"],
					arg = "showCommentPrefix",
					order = 8,
					disabled = function() return not DoIKnowYou.db.profile.showCommentTooltip; end,
				},
				showCommentPrefixText = {
					type = "input",
					name = L["Prefix text:"],
					arg = "showCommentPrefixText",
					width = "double",
					order = 9,
					disabled = function() return not (DoIKnowYou.db.profile.showCommentTooltip and DoIKnowYou.db.profile.showCommentPrefix); end,
				},
				colourComment = {
					type = "toggle",
					name = L["Colour comment text by reputation"],
					arg = "colourComment",
					width = "full",
					order = 10,
					disabled = function() return not DoIKnowYou.db.profile.showCommentTooltip; end,
				},
				trustedCommentAuthors = {
					type = "input",
					name = L["Trusted tooltip comment authors to check when no personal comment exists (separated by commas):"],
					arg = "trustedCommentAuthors",
					width = "full",
					order = 11,
					disabled = function() return not DoIKnowYou.db.profile.showCommentTooltip; end,
					get = function(info) return table.concat(DoIKnowYou.db.profile[info.arg], ",") end,
					set = function(info, val)
						-- We cannot trust the user's input. Player names are VERY CASE SENSITIVE. So we'll split by commas and clean up their names!
						local trustedAuthors = {}
						if (type(val) == "string") then
							for name in val:gmatch("([^,]+)") do
								-- Remove ALL whitespace (spaces, tabs, etc) everywhere in the string.
								name = name:gsub("%s+", "")
								if (name:len() > 0) then -- Only proceed with non-empty names.
									-- Uppercase the first letter, and lowercase all other letters. Ensures the name matches perfectly.
									-- NOTE: Doesn't work properly on Unicode! But The Burning Crusade client doesn't allow Unicode names! ;-)
									name = name:sub(1,1):upper() .. name:sub(2):lower()
									trustedAuthors[#trustedAuthors+1] = name
								end
							end
						end
						DoIKnowYou.db.profile[info.arg] = trustedAuthors
					end,
				},
			}
		},
		group_autoquery = {
			type = "group",
			name = L["Auto Query"],
			desc = L["Options for automatic queries"],
			order = 100,
			args = {
				useAutoQuery = {
					type = "toggle",
					name = L["Use Auto Query"],
					arg = "useAutoQuery",
					width = "full",
					order = 101,
				},
				autoQueryGroup = {
					type = "toggle",
					name = L["... when group members change"],
					desc = L["This event includes pretty much everything to do with a group, such as joining a new group, a new member joining an existing group, or someone leaving the group."],
					arg = "autoQueryGroup",
					width = "full",
					order = 102,
					disabled = function() return not DoIKnowYou.db.profile.useAutoQuery; end,
				},
				autoQueryWhisper = {
					type = "toggle",
					name = L["... when whispering another player"],
					desc = L["This option enable auto-query when whispering another player, with data output to the summary frame."],
					arg = "autoQueryWhisper",
					width = "full",
					order = 103,
					disabled = function() return not DoIKnowYou.db.profile.useAutoQuery; end,
				},
				autoQueryTrade = {
					type = "toggle",
					name = L["... when trading with another player"],
					desc = L["This option works like the others, on trade."],
					arg = "autoQueryTrade",
					width = "full",
					order = 104,
					disabled = function() return not DoIKnowYou.db.profile.useAutoQuery; end,
				},
				autoQueryMouse = {
					type = "toggle",
					name = L["... when you move your mouse over another player"],
					desc = L["This option creates a lot of queries, which you really won't need most of the time. You can already see your own data on tooltips, this simply broadcasts a request for data too, and adds info to the summary frame."],
					arg = "autoQueryMouse",
					width = "full",
					order = 105,
					disabled = function() return not DoIKnowYou.db.profile.useAutoQuery; end,
					hidden = true,
				},
				autoAnnounceChat = {
					type = "toggle",
					name = L["Announce status in chat window"],
					desc = L["Announce the result of an auto-query in the chat window. This message will only be visible to yourself, not to other players."],
					arg = "autoAnnounceChat",
					width = "full",
					order = 106,
					disabled = function() return not DoIKnowYou.db.profile.useAutoQuery; end,
				},
				autoQueryReportNeutral = {
					type = "toggle",
					name = L["Report when auto-query returns neutral"],
					desc = L["When this option is disabled, you will only see reports on players with positive or negative ratings announced in your chat window."],
					arg = "autoQueryReportNeutral",
					width = "full",
					order = 107,
					disabled = function() return not DoIKnowYou.db.profile.useAutoQuery; end,
				},
			}
		},
		group_misc = {
			type = "group",
			name = L["Other"],
			desc = L["Other options"],
			order = 200,
			args = {
				useDropDown = {
					type = "toggle",
					name = L["Use right-click drop down \"Do I Know You?\""],
					desc = L["When enabled, the option \"Do I Know You?\" will be added to the right-click menu on players, allowing you to query them by that menu easily from chat channels, unit frames, etc.."],
					arg = "useDropDown",
					width = "full",
					order = 201,
					set = function(k, v) DoIKnowYou.db.profile[k.arg] = v; DoIKnowYou:updateRegisterDropdown(v) end,
				},
				showChatIndicator = {
					type = "toggle",
					name = L["Show reputation indicator in chat"],
					desc = L["When enabled, a colour-coded indicator will be added to your chat frame next to players names."],
					arg = "showChatIndicator",
					width = "full",
					order = 202,
				},
				hideChatIndicatorNeutral = {
					type = "toggle",
					name = L["Hide chat indicator when neutral"],
					arg = "hideChatIndicatorNeutral",
					width = "double",
					order = 203,
					disabled = function() return not DoIKnowYou.db.profile.showChatIndicator; end,
				},
				chatIndicatorText = {
					type = "input",
					name = L["Chat indicator text:"],
					arg = "chatIndicatorText",
					order = 204,
					disabled = function() return not DoIKnowYou.db.profile.showChatIndicator; end,
				},
				sendComms = {
					type = "toggle",
					name = L["Send addon messages"],
					arg = "sendComms",
					width = "double",
					order = 205,
				},
				recvComms = {
					type = "toggle",
					name = L["Parse incoming addon messages"],
					arg = "recvComms",
					width = "double",
					order = 206,
				},
				purgeGuildData = {
					type = "toggle",
					name = L["Purge data from a guild when you no longer have any characters in it."],
					arg = "purgeGuildData",
					width = "double",
					order = 207,
				},
				purgePlayerData = {
					type = "input",
					name = "Purge player data",
					width = "full",
					order = 299,
					set = function(k, v) DoIKnowYou:purgePlayerData(v); end,
					disabled = function() return not DoIKnowYou.db.profile.debugMode; end,
				}
			}
		},
	}
}
local OptFrame

function DoIKnowYou:initFrameTexts()
	
	DoIKnowYouFrame_EditBoxPromptText:SetText(L["Input the name of the player"])
	DoIKnowYouFrame_CommentBoxText:SetText(L["Player comment:"])
	DoIKnowYouFrame_SharedDataText:SetText(L["Shared data:"])
	DoIKnowYouFrame_ShowOptionsButton:SetText(L["Options"])
	DoIKnowYouFrame_ShowConsoleButton:SetText(L["Console"])
	DoIKnowYouFrame_ShowDataviewButton:SetText(L["Data View"])
	DoIKnowYouFrame_GetTargetButton:SetText(L["From Target"])
	DoIKnowYouFrame_SyncButton:SetText(L["Sync Data"])
	DoIKnowYouFrame_GlobalSyncButton:SetText(L["Global Sync"])
	
	local font = DoIKnowYouFrame_QueryStatus:GetFont()
	
	DoIKnowYouFrame_QueryStatus:SetFont(font, 40)
	DoIKnowYouFrame_SharedDataStatus:SetFont(font, 50)
	for i=1, 12 do
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_NameText"):SetFont(font, 12)
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_NoteText"):SetFont(font, 10)
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_RepData"):SetFont(font, 10)
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_TotalData"):SetFont(font, 10)
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_SourceData"):SetFont(font, 10)
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_NoteData"):SetFont(font, 10)
		
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_NameText"):SetTextColor(1,1,1)
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_NoteText"):SetTextColor(1,1,1)
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_RepData"):SetTextColor(1,1,1)
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_TotalData"):SetTextColor(1,1,1)
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_SourceData"):SetTextColor(1,1,1)
		getglobal("DoIKnowYouDataview_DataRow" .. tostring(i) .. "_NoteData"):SetTextColor(1,1,1)
	end
	
	self:updateSummaryDisplay() -- Clear display!
	DoIKnowYouDataview_FilterModeText:SetText(L["Search all saved data"])
	DoIKnowYouDataview_SummaryButton:SetText(L["Summary Data"])
	DoIKnowYouDataview_ClearButton:SetText(L["Reset"])
	DoIKnowYouDataview_FilterButton:SetText(L["Filter"])
	DoIKnowYouDataview_HeaderName:SetText(L["Name"])
	DoIKnowYouDataview_HeaderNote:SetText(L["Note"])
	DoIKnowYouDataview_HeaderRep:SetText(L["Rep"])
	DoIKnowYouDataview_HeaderTotal:SetText(L["Total"])
	DoIKnowYouDataview_HeaderSources:SetText(L["Sources"])
	DoIKnowYouDataview_HeaderNotes:SetText(L["Notes"])
end

local function strproper(text)
	if(gameLocale=="enUS" or gameLocale=="frFR" or gameLocale=="deDE" or gameLocale=="esES" or gameLocale=="esMX") then
		return strupper(strsub(text, 1, 1)) .. strlower(strsub(text, 2))
	end
	return text
end

local function addonMsgSend(text)
	if(DoIKnowYou.db.profile.sendComms) then
		if(IsInGuild()) then
			local finalText = tostring(VERSION_COMM) .. ":" .. text
			local finalLen = finalText:len() + 11 -- 11 = prefix ("DoIKnowYou") + 1 (separator)

			-- Enforce length limit. Max data length allowed by the WoW API: 255 bytes. One more (256) would fail to send!
			-- The prefix is 11 characters, which means the final payload data length allowed is 244 characters. Total: 255.
			-- NOTE ABOUT THIS BUGFIX: DoIKnowYou wasn't programmed to properly handle long messages; however, the only kind
			-- of payload that may exceed 255 bytes is long comments. So we'll simply chop off the end of the note cleanly.
			-- As follows: "End of a really long message." -> "End of a [...]".
			-- It's a decent solution for this old addon, without breaking backwards compatibility (ie. by doing multi-chunked sending).
			if(finalLen > 255) then
				DoIKnowYou:debugOut("Truncating (Was Over 255 Bytes): " .. finalText)
				finalText = finalText:sub(1, 238) .. ' [...]'; -- Indicate truncation. 238 + 6 (trunc chars) = 244 chars. Max allowed!
				finalLen = finalText:len() + 11
				DoIKnowYou:debugOut("Shortened To: " .. finalText)
			end

			-- Blizzard only allows sending 2 messages at a time, before they throttle/disconnect you. So we'll use ChatThrottleLib.
			-- NOTE: Priority "BULK" means sending with low priority, and prefix "DoIKnowYou" is required by Blizzard's API for message sorting.
			CTL:SendAddonMessage("BULK", "DoIKnowYou", finalText, "GUILD")
			DoIKnowYou:debugOut("Sent: " .. tostring(finalText))
		end
	end
end
	
function DoIKnowYou:debugOut(text)
	text = tostring(text)
	if self.db.profile.debugMode == true then
		self:chatOut("DEBUG: " .. text)
	end
end
function DoIKnowYou:consoleOut(text)
	local n; local cText = "";
	if(cPointer <= cLimit) then
		cData[cPointer] = text
		cPointer = cPointer + 1
		for n = 0, cPointer-1, 1 do
			cText = cText .. namestring .. ": " .. cData[n] .. "\n"
		end
	else
		for n = 0, cLimit - 1, 1 do
			cData[n] = cData[n + 1]
			cText = cText .. namestring .. ": " .. cData[n] .. "\n"
		end
		cData[cLimit] = text
		cText = cText .. namestring .. ": " .. cData[cLimit] .. "\n"
	end
	DoIKnowYouConsole_ConsoleScrollFrame_ConsoleEditBox:SetText(cText .. "\n")
end
function DoIKnowYou:chatOut(text)
	if(addonEnabled) then
		DEFAULT_CHAT_FRAME:AddMessage(namestring .. " " .. text, 1, 1, 1, 1)
	else
		chatOutBuffer[#chatOutBuffer+1]=text
	end
end

function DoIKnowYou:getRepStatus(unit)
	local name, server = UnitName(unit)
	name = strupper(name)
	if(self.db.realm.data[name]) then
		if(self.db.realm.data[name].total) then
			return self.db.realm.data[name].total
		end
	end
	return 0
end
function DoIKnowYou:getRepStatusText(unit)
	local name, server = UnitName(unit)
	name = strupper(name)
	if(self.db.realm.data[name]) then
		if(self.db.realm.data[name].total) then
			if(math.ceil(self.db.realm.data[name].total)>0) then
				return L["Positive"]
			end
			if(math.floor(self.db.realm.data[name].total)<0) then
				return L["Negative"]
			end
		end
	end
	return L["Neutral"]
end
function DoIKnowYou:getPlayerNote(unit, useTrustedAuthors)
	local name, server = UnitName(unit)
	name = strupper(name)
	if self.db.realm.data[name] then
		-- First check for a note written by ourselves (our primary character on the account).
		if(self.db.realm.data[name][self.db.realm.primaryChar]) then
			if(self.db.realm.data[name][self.db.realm.primaryChar].note~=nil and self.db.realm.data[name][self.db.realm.primaryChar].note~="") then
				return self.db.realm.data[name][self.db.realm.primaryChar].note
			end
		end
		-- Next, fall back to comments by "trusted authors" (if any exist). Format them differently, as "Name says: ...".
		if(useTrustedAuthors) then
			for _,author in ipairs(self.db.profile.trustedCommentAuthors) do
				if(self.db.realm.data[name][author] and self.db.realm.data[name][author].note~=nil and self.db.realm.data[name][author].note~="") then
					return author.." says: \""..self.db.realm.data[name][author].note.."\""
				end
			end
		end
	end
	return nil
end
function DoIKnowYou:getRepColor(rep)
	if(rep>=1) then return GREEN_FONT_COLOR_CODE end
	if(rep<=-1) then return RED_FONT_COLOR_CODE end
	return NORMAL_FONT_COLOR_CODE
end

function DoIKnowYou:updateTotalRep(name)
	local index; local value; local total = 0; local tcount = 0
	for index,value in pairs(self.db.realm.data[name]) do
		if(type(value)=="table") then
			total = total + value.rep; tcount = tcount + 1
		end
	end
	self.db.realm.data[name].total = total
	if(activeQuery==name) then
		local pretext = ""
		if(total>0) then pretext="+" end
		DoIKnowYouFrame_SharedDataStatus:SetText(self:getRepColor(total) .. pretext .. tostring(total))
		DoIKnowYouFrame_SharedDataInfo:SetText(format(L["Data generated from %s sources."], tostring(tcount)))
	end
end
function DoIKnowYou:countRepSources(name)
	local i; local v; local c;
	for i,v in pairs(self.db.realm.data[name]) do
		if(type(v)=="table") then
			c=c+1
		end
	end
	return c
end

function DoIKnowYou:addDataLine(text)
	if(text~=nil) then
		local ct = DoIKnowYouFrame_DataScrollFrame_DataEditBox:GetText()
		DoIKnowYouFrame_DataScrollFrame_DataEditBox:SetText(ct .. text .. "\n")
	end
end
function DoIKnowYou:addConsoleLine(text)
	if(text~=nil) then
		local ct = DoIKnowYouConsole_ConsoleScrollFrame_ConsoleEditBox:GetText()
		DoIKnowYouConsole_ConsoleScrollFrame_ConsoleEditBox:SetText(ct .. text .. "\n")
	end
end
function DoIKnowYou:clearDataText()
	DoIKnowYouFrame_DataScrollFrame_DataEditBox:SetText("")
end
function DoIKnowYou:clearConsoleText()
	DoIKnowYouConsole_ConsoleScrollFrame_ConsoleEditBox:SetText("")
end

function DoIKnowYou:displayStatus(rep)
	if(rep == 1) then
		DoIKnowYouFrame_QueryStatus:SetText(L["Positive"])
		DoIKnowYouFrame_QueryStatus:SetTextColor(0, 1, 0)
	end
	if(rep == 0) then
		DoIKnowYouFrame_QueryStatus:SetText(L["Neutral"])
		DoIKnowYouFrame_QueryStatus:SetTextColor(0.8, 0.8, 0)
	end
	if(rep == -1) then
		DoIKnowYouFrame_QueryStatus:SetText(L["Negative"])
		DoIKnowYouFrame_QueryStatus:SetTextColor(1, 0, 0)
	end
end

function DoIKnowYou:QueryFromDataview(name)
 viewingQuery = name
 self:runQueryOn(name)
 DoIKnowYouFrame:Show()
end
function DoIKnowYou:runQueryOn(name)
	name = strupper(name)	
	self:consoleOut(format(L["running query on %s"], name))
	activeQuery = name
	DoIKnowYouFrame_TargetEditBox:SetText(strproper(name))
	self:sendRequestData(name)
	DoIKnowYouFrame_QueryHeader:SetText(format(L["Query on: %s"], name))
	if not self.db.realm.data[name] then
		self.db.realm.data[name] = {total=0, sources=0, notes=0}
	end
	if not self.db.realm.data[name][self.db.realm.primaryChar] then
		self.db.realm.data[name][self.db.realm.primaryChar] = {rep=0, note=""}
	end
	self:consoleOut("Query on: " .. name);
	self:displayStatus(self.db.realm.data[name][self.db.realm.primaryChar].rep)
	if(self.db.realm.data[name][self.db.realm.primaryChar].note~="") then
		DoIKnowYouFrame_CommentEditBox:SetText(self.db.realm.data[name][self.db.realm.primaryChar].note or "")
	else
		DoIKnowYouFrame_CommentEditBox:SetText("")
	end
	DoIKnowYouFrame_repUpButton:Show()
	DoIKnowYouFrame_repDownButton:Show()
	DoIKnowYouFrame_CommentEditBox:Show()
	DoIKnowYouFrame_CommentBoxText:Show()
	DoIKnowYouFrame_SharedDataText:Show()
	self:updateSharedDataDisplay()
end

function DoIKnowYou:updateSharedDataDisplay()
	self:updateTotalRep(activeQuery)
	self:updateSharedNotes()
end
function DoIKnowYou:updateSharedNotes()
	local dText = ""
	local index; local value; local tcount = 0;
	for index, value in pairs(self.db.realm.data[activeQuery]) do
		if(type(value)=="table") then
			if(value.note~="" and index~=self.db.realm.primaryChar) then
				dText = dText .. index .. ": " .. self:getRepColor(value.rep) .. "\"" .. value.note .. "\"" .. "|r\n"
				tcount = tcount + 1;
			end
		end
	end
	if tcount==0 then
		dText = L["No notes received from shared data sources."]
	end
	self.db.realm.data[activeQuery].notes = tcount
	DoIKnowYouFrame_DataScrollFrame_DataEditBox:SetText(dText)
end
function DoIKnowYou:countSources(name)
	local index; local value; local scount = 0; local ncount = 0;
	for index, value in pairs(self.db.realm.data[name]) do
		if(type(value)=="table") then
			if(self.db.realm.data[name][index].rep~=0 or self.db.realm.data[name][index].note~="") then
				scount = scount + 1
			end
			if(self.db.realm.data[name][index].note~="") then
				ncount = ncount + 1
			end
		end
	end
	self.db.realm.data[name].sources = scount
	self.db.realm.data[name].notes = ncount
end

function DoIKnowYou:saveComment()
	local note = DoIKnowYouFrame_CommentEditBox:GetText()
	self.db.realm.data[activeQuery][self.db.realm.primaryChar].note = note
	self:consoleOut(format(L["Note for %s saved as %s"], activeQuery, note))
	self:updateSharedNotes()
	self:countSources(activeQuery)
	self:updateTotalRep(activeQuery)
	self:sendMyData(activeQuery)
end

function DoIKnowYou:saveCommentAbs(name, note)
	self:debugOut("Saving note for " .. tostring(name) .. " as " .. tostring(note) .. " (" .. tostring(self.db.realm.primaryChar) .. ")")
	if(not self.db.realm.data[name]) then self.db.realm.data[name] = {total=0, sources=0, notes=0}	end
	if(not self.db.realm.data[name][self.db.realm.primaryChar]) then self.db.realm.data[name][self.db.realm.primaryChar] = {rep=0, note=""} end
	self.db.realm.data[name][self.db.realm.primaryChar].note = note
	self:countSources(name)
	self:updateTotalRep(name)
	self:sendMyData(name)
end

function DoIKnowYou:repUp()
	local rep = self.db.realm.data[activeQuery][self.db.realm.primaryChar].rep
	if(rep < 1) then
		rep = rep + 1
	end
	self.db.realm.data[activeQuery][self.db.realm.primaryChar].rep = rep
	self:updateTotalRep(activeQuery)
	self:consoleOut(format(L["Rep changed for %s to %d"], activeQuery, rep))
	self:displayStatus(rep)
	self:sendMyData(activeQuery)
end
function DoIKnowYou:repDown()
	local rep = self.db.realm.data[activeQuery][self.db.realm.primaryChar].rep
	if(rep > -1) then
		rep = rep - 1
	end
	self.db.realm.data[activeQuery][self.db.realm.primaryChar].rep = rep
	self:updateTotalRep(activeQuery)
	self:consoleOut(format(L["Rep changed for %s to %d"], activeQuery, rep))
	self:displayStatus(rep)
	self:sendMyData(activeQuery)
end

function DoIKnowYou:purgePlayerData(name)
	for i1,v1 in pairs(self.db.realm.data) do
		if self.db.realm.data[i1][name] then self.db.realm.data[i1][name]=nil end
	end
	self:chatOut("Purged data by " .. name)
end

function DoIKnowYou:handleAddonMsg(prefix, message, distribution, sender)
	if(prefix=="DoIKnowYou" and sender~=playername) then
		self:debugOut("Recv: " .. message .. " - " .. sender)
		local version, method, data = string.match(message, "([^:]+)%:([^:]+)%:(.+)")
		if(tonumber(version)==VERSION_COMM or version=="*")then
			self[method](self, sender, data, distribution)
		end
	end
end

function DoIKnowYou:sendRequestData(name)
	if((name=="" or name==nil) and activeQuery~=nil) then name=activeQuery; end
	addonMsgSend("RequestData:" .. strupper(name))
end
function DoIKnowYou:RequestData(sender, data, source)
	data = strupper(data)
	if(data=="*ALL") then
		for index, value in pairs(self.db.realm.data) do
			for index2, value2 in pairs(value) do
				if(index2~=sender and type(value2)=="table") then
					if(index2==self.db.realm.primaryChar or (source=="GUILD" and value2.source==DIKY_SOURCE[source] and value2.guild==playerguild)) then
						self:sendMyData(index, index2)
					end
				end
			end
		end
	else
		if self.db.realm.data[data] then
			for index2, value2 in pairs(self.db.realm.data[data]) do
				if(index2~=sender and type(value2)=="table") then
					if(index2==self.db.realm.primaryChar or (source=="GUILD" and value2.source==DIKY_SOURCE[source] and value2.guild==playerguild)) then
						self:sendMyData(data, index2)
					end
				end
			end
		end
	end
end
function DoIKnowYou:sendMyData(data, datasource)
	if(datasource==nil or datasource=="") then datasource = self.db.realm.primaryChar; end
	if self.db.realm.data[data] then
		local mydata = {}
		if self.db.realm.data[data][datasource] then
			local mydata = self.db.realm.data[data][datasource]
			if(datasource==self.db.realm.primaryChar) then mydata.creation = time() end
			local datastring = "ReceiveData:" .. data .. ":" .. datasource .. ":" .. tostring(mydata.creation) .. ":" .. tostring((mydata.rep or 0)) .. ":" .. (mydata.note or "")
			addonMsgSend(datastring)
		end
	end
end
function DoIKnowYou:ReceiveData(sender, data, source)
	local d = {}
	d.subject, d.from, d.creation, d.rep, d.note = string.match(data, "([^:]*)%:([^:]*)%:([^:]*)%:([^:]*)%:(.*)")
	if(d.note ~= nil and d.from~=self.db.realm.primaryChar) then -- got all parts and not mine
		if not self.db.realm.data[d.subject] then self.db.realm.data[d.subject] = {total=0, sources=0, notes=0}; end
		if(not self.db.realm.data[d.subject][d.from] or tonumber(d.creation) > self.db.realm.data[d.subject][d.from].creation) then
			self.db.realm.data[d.subject][d.from] = {rep=tonumber(d.rep), note=(d.note or ""), creation=tonumber(d.creation), ttl=time()+dataTTL}
			self.db.realm.data[d.subject][d.from].source = DIKY_SOURCE[source]
			if(source=="GUILD") then
				self.db.realm.data[d.subject][d.from].guild = playerguild
			end
			self:updateTotalRep(d.subject)
			self:countSources(d.subject)
			if(d.subject==activeQuery) then
				self:updateSharedNotes()
			end
		end
	end
end

function updateSummaryPageInfo()
	local pi = ""; local maxViewed = nil;
	if(tViewing.shown>0) then
		if(tViewing.shown>(summaryPage * summaryPerPage)) then maxViewed = summaryPage * summaryPerPage end
		pi = format(L["Now viewing %d to %d of %d (Page %d of %d)"],
					((summaryPage - 1) * summaryPerPage) + 1,
					maxViewed or tViewing.shown,
					tViewing.shown,
					summaryPage,
					ceil(tViewing.shown/summaryPerPage))
	else
		pi = L["No data shown. Use the filters below to view data."]
	end
	DoIKnowYouDataview_PageInfo:SetText(pi)
end
function DoIKnowYou:summaryPageUp()
	local maxPages = ceil(tViewing.shown / summaryPerPage)
	if(summaryPage<maxPages) then
		summaryPage = summaryPage + 1
	end
	self:updateSummaryDisplay(tViewing)
end
function DoIKnowYou:summaryPageDown()
	if(summaryPage>1) then
		summaryPage = summaryPage - 1
	end
	self:updateSummaryDisplay(tViewing)
end

function DoIKnowYou:updateSummaryDisplay(t)
	if(t==nil) then t = tSummaryData end
	local shown = 0
	self:debugOut("Display summary")
	local ic = 0, i;
	for ic=1, 12 do
		self:SetDataRow(ic, nil)
	end
	ic = -1
	for i, v in ipairs(t) do
		if(not (v.hide or (v.sources==0 and not v.fromQuery))) then -- either hidden by filter, or useless data not to be shown outside of summary
			ic = ic + 1
			if(ic>=((summaryPage - 1) * summaryPerPage) and ic<(summaryPage*summaryPerPage)) then
				self:SetDataRow(mod(ic, summaryPerPage)+1, v)
			end
			shown = shown + 1
		end
	end
	tViewing = t
	tViewing.shown = shown
	
	local maxPages = ceil(tViewing.shown / summaryPerPage)
	if(summaryPage==maxPages or maxPages==0) then
		DoIKnowYouDataview_NextPage:Disable()
	else
		DoIKnowYouDataview_NextPage:Enable()
	end
	if(summaryPage==1) then
		DoIKnowYouDataview_PrevPage:Disable()
	else
		DoIKnowYouDataview_PrevPage:Enable()
	end
	updateSummaryPageInfo()
	--<OnClick>removeSummary(strupper(getglobal(self.GetParent().GetName() .. "_name"):GetText()))</OnClick>
end

function DoIKnowYou:removeSummary(name)
	local i; local v;
	for i,v in ipairs(tSummaryData) do
		if(v.name==name) then
			tremove(tSummaryData, i)
		end
	end
	self:updateSummaryDisplay(tSummaryData)
end

function DoIKnowYou:addSummary(name)
	if(name==nil) then return; end
	self:countSources(name)
	local i, v
	for i, v in ipairs(tSummaryData) do -- remove duplicate data before adding newer data for same char.
		if(v.name==name) then
			tremove(tSummaryData, i)
		end
	end
	tinsert(tSummaryData, {
		name = name,
		rep = self.db.realm.data[name][self.db.realm.primaryChar].rep,
		total = self.db.realm.data[name].total,
		sources = self.db.realm.data[name].sources,
		note = self.db.realm.data[name][self.db.realm.primaryChar].note,
		notes = self.db.realm.data[name].notes,
		fromQuery = true,
		})
	self:updateSummaryDisplay(tSummaryData)
	-- This data has been added by a scheduled query, so alert the user if in one of the auto-query situations!
	if(self.db.profile.useAutoQuery and self.db.profile.autoAnnounceChat) then
		local rep = self.db.realm.data[name].total
		if(not(rep==0 and  not self.db.profile.autoQueryReportNeutral)) then
			local report, queryType = false, ""
			if(self.db.profile.autoQueryGroup) then
				for i=1, 4 do
					if(GetPartyMember(i)) then
						local pname, prealm = UnitName("party" .. tostring(i))
						if(strupper(pname) == name) then -- Player added to summary is in party
							report = true
							queryType = "Group change"
						end
					end
				end
			end
			if(self.db.profile.autoQueryTrade) then
				for i,v in ipairs(tTrades) do
					if(v==name) then
						report = true
						queryType = "Trade"
						tTrades[i] = nil
						break
					end
				end
			end
			if(self.db.profile.autoQueryWhisper) then
				for i,v in ipairs(tWhispers) do
					if(v==name) then
						report = true
						queryType = "Whisper"
						tWhispers[i] = nil
						break
					end
				end
			end
			if(self.db.profile.autoQueryMouse) then
				-- I really don't want to do this :/
			end
			if(report==true) then
				local f_name = strproper(name); local note
				if(self.db.realm.data[name][self.db.realm.primaryChar] and self.db.realm.data[name][self.db.realm.primaryChar].note and self.db.realm.data[name][self.db.realm.primaryChar].note~="") then
					note = " \""..self.db.realm.data[name][self.db.realm.primaryChar].note.."\""
				else
					note = ""
				end
				if(rep>0) then
					self:chatOut(format(L["Auto-Query (%s): %s has returned positive!"], queryType, self:getRepColor(rep) .. f_name) .. note)
				end
				if(rep==0) then
					self:chatOut(format(L["Auto-Query (%s): %s has returned neutral."], queryType, self:getRepColor(rep) .. f_name) .. note)
				end
				if(rep<0) then
					self:chatOut(format(L["Auto-Query (%s): %s has returned negative!"], queryType, self:getRepColor(rep) .. f_name) .. note)
				end
			end
		end
	end
end

function DoIKnowYou:SetDataRow(row, args)
	row = tostring(row)
	if(args) then
		local pretext = ""
		local f_name = strproper(args.name)
		getglobal("DoIKnowYouDataview_DataRow" .. row .. "_NameText"):SetText(self:getRepColor(args.rep or 0) .. (f_name or ""))
		local trimnote = ""
		if(strlen(args.note)>summaryNoteLen) then trimnote = strsub(args.note, 1, summaryNoteLen) .. ".." else trimnote = args.note end
		getglobal("DoIKnowYouDataview_DataRow" .. row .. "_NoteText"):SetText(self:getRepColor(args.rep or 0) .. (trimnote or ""))
		if(args.rep>0) then pretext="+" else pretext="" end
		getglobal("DoIKnowYouDataview_DataRow" .. row .. "_RepData"):SetText(self:getRepColor(args.rep or 0) .. pretext ..  tostring(args.rep or ""))
		if(args.total>0) then pretext="+" else pretext="" end
		getglobal("DoIKnowYouDataview_DataRow" .. row .. "_TotalData"):SetText(self:getRepColor(args.total or 0) .. pretext .. tostring(args.total or ""))
		getglobal("DoIKnowYouDataview_DataRow" .. row .. "_SourceData"):SetText(tostring(args.sources or ""))
		getglobal("DoIKnowYouDataview_DataRow" .. row .. "_NoteData"):SetText(tostring(args.notes or ""))
		if(args.fromQuery) then
			getglobal("DoIKnowYouDataview_DataRow" .. row .. "_DeleteButton"):Show()
		else
			getglobal("DoIKnowYouDataview_DataRow" .. row .. "_DeleteButton"):Hide()
		end
		getglobal("DoIKnowYouDataview_DataRow" .. row):Show()
	else
		getglobal("DoIKnowYouDataview_DataRow" .. row):Hide()
	end
end

function DoIKnowYou:filterData()
	local t, vt = {}, {}
	if(DoIKnowYouDataview_FilterMode:GetChecked()) then
		-- Run data filter on ALL data, create summary table on all, then filter
		for i, v in pairs(self.db.realm.data) do
			vt = {}
			self:countSources(i)
			vt.name = i;
			if(v[self.db.realm.primaryChar]) then
				vt.rep = v[self.db.realm.primaryChar].rep
				vt.note = v[self.db.realm.primaryChar].note
			else
				vt.rep = 0
				vt.note = ""
			end
			vt.total = v.total
			vt.sources = v.sources
			vt.notes = v.notes
			t[#t+1] = vt
		end
		sort(t, function(a,b)
				local i = 0;
				do
					i = i + 1;
					local av, bv = strbyte(a.name, i), strbyte(b.name, i);
					if(av~=bv) then
						if(av<bv) then return true else return false end;
					end
					if(i==strlen(b.name)) then return false end;
				end
			end)
	else
		-- Run data filter on only displayed summary data. Copy existing summary data so we don't fuck with it.
		for i, v in pairs(tSummaryData) do
			t[#t+1] = v
		end
	end
	
	local match;
	for i, v in ipairs(t) do
		match = true; t[i].hide = false
		local name_match = DoIKnowYouDataview_NameFilter:GetText() or ""
		if(name_match~="" and strfind(v.name, strupper(name_match))==nil) then
			match = false
		else
			local note_match = DoIKnowYouDataview_NoteFilter:GetText() or ""
			if(note_match~="" and strfind(strupper(v.note), strupper(note_match))==nil) then
				match = false
			else
				local repfilter = {
					positive = DoIKnowYouDataview_PositiveRepFilter:GetChecked() or false,
					negative = DoIKnowYouDataview_NegativeRepFilter:GetChecked() or false,
					neutral = DoIKnowYouDataview_NeutralRepFilter:GetChecked() or false,
					}
				if(repfilter.positive==false and v.total>0) then match = false end
				if(repfilter.neutral==false and v.total==0) then match = false end
				if(repfilter.negative==false and v.total<0) then match = false end
			end
		end
		if(match==false) then
			t[i].hide = true
		end
	end
	
	summaryPage = 1
	self:updateSummaryDisplay(t)
end

function DoIKnowYou:sendConsoleOut(args)
	self:consoleOut(args)
end

function DoIKnowYou:stopVersionCheck()
	versionRequest = false
end
function DoIKnowYou:RequestVersion(sender, data)
	addonMsgSend("ReceiveVersion:" .. VERSION)
	self:debugOut("Version request from " .. sender .. ": Sent " .. VERSION)
end
function DoIKnowYou:ReceiveVersion(sender, data)
	if(versionRequest==true) then
		self:chatOut(sender .. " - " .. data)
	end
end
function DoIKnowYou:runVersionCheck()
	addonMsgSend("RequestVersion::")
	self:scheduleEvent(5, "stopVersionCheck", "")
	versionRequest = true
end

function DoIKnowYou:checkEvent( k, e )
	if(GetTime()>e.time) then
		self:debugOut("Acting on event: " .. e.method .. ":" .. e.args)
		DoIKnowYou[e.method](self, e.args)
		tremove(tEvents, k)
	end
end

function DoIKnowYou:scheduleEvent(offset, method, args)
	self:debugOut("Scheduling event: " .. method .. ":" .. args)
	tinsert(tEvents, {time=GetTime()+offset, method=method, args=args})
end

local function frameUpdate( ... )
	local i, v
	for i,v in pairs(tEvents) do
		DoIKnowYou:checkEvent(i,v)
	end
end

function DoIKnowYou:summaryQuery(name)
	self:debugOut("Summary query for " .. name)
	self:sendRequestData(name)
	if not self.db.realm.data[name] then
		self.db.realm.data[name] = {total=0, sources=0, notes=0}
		if not self.db.realm.data[name][self.db.realm.primaryChar] then
			self.db.realm.data[name][self.db.realm.primaryChar]={rep=0, note=""}
		end
	end
	self:updateTotalRep(name)
	self:scheduleEvent(5, "addSummary", name) -- 5 second delay on adding summary data, for receiving data
	tQuery[name] = {ttl=GetTime()+queryTTL}
end

local function eventHandler( ... )
	if(DoIKnowYou.db.profile.useAutoQuery) then
		local q_exit = false; local t = GetTime()
		if (event=="PARTY_MEMBERS_CHANGED" and DoIKnowYou.db.profile.autoQueryGroup) then
			local n; local p_realm; local p_name; 
			for n = 1, 4, 1 do
				if(GetPartyMember(n)) then
					q_exit = false;
					p_name, p_realm = UnitName("party" .. tostring(n))
					p_name = strupper(p_name)
					if(tQuery[p_name]) then
						if(t > tQuery[p_name].ttl) then
							tQuery[p_name] = nil
						else
							q_exit = true
						end
					end
					if not q_exit then
						DoIKnowYou:debugOut("Party change, query needed.")
						DoIKnowYou:summaryQuery(p_name)
					end
				end
			end
		end
		if(event=="CHAT_MSG_WHISPER" and DoIKnowYou.db.profile.autoQueryWhisper) then
			local p_name = strupper(arg2)
			if(tQuery[p_name]) then
				if(t > tQuery[p_name].ttl) then
					tQuery[p_name] = nil
				else
					q_exit = true
				end
			end
			if not q_exit then
				DoIKnowYou:debugOut("Whisper, query needed")
				DoIKnowYou:summaryQuery(p_name)
				tinsert(tWhispers, p_name)
			end
		end
		if(event=="TRADE_SHOW" and DoIKnowYou.db.profile.autoQueryTrade) then
			local p_name, p_realm = UnitName("npc")
			if(p_name) then
				p_name = strupper(p_name)
				if(tQuery[p_name]) then
					if(t > tQuery[p_name].ttl) then
						tQuery[p_name] = nil
					else
						q_exit = true
					end
				end
				if not q_exit then
					DoIKnowYou:debugOut("Trade, query needed")
					DoIKnowYou:summaryQuery(p_name)
					tinsert(tTrades, p_name)
				end
			end
		end
		if(event=="CHAT_MSG_ADDON" and DoIKnowYou.db.profile.recvComms) then
			DoIKnowYou:handleAddonMsg(arg1, arg2, arg3, arg4)
		end
		if(event=="PLAYER_GUILD_UPDATE") then
			DoIKnowYou:updateSavedGuilds()
			--Check if player is in a guild, if not, purge data from guild source!
			if( not IsInGuild()) then
				for i1, v1 in pairs(DoIKnowYou.db.realm.data) do
					local updateNeeded = false
					for i2, v2 in pairs(v1) do
						if(type(v2)=="table") then
							if(i2~=DoIKnowYou.db.realm.primaryChar) then
								if(v2.source==DIKY_SOURCE["GUILD"] and #DoIKnowYou.db.realm.guilds[v2.guild]<=0 and DoIKnowYou.db.profile.purgeGuildData) then
									DoIKnowYou:chatOut(format(L["You have left %s, no characters left in guild - purging data."], playerguild))
									updateNeeded = true
									DoIKnowYou.db.realm.data[i1][i2] = nil
								end
							end
						end
					end
					if(updateNeeded) then
						DoIKnowYou:countSources(i1)
						DoIKnowYou:updateTotalRep(i1)
					end
				end	
			end
			if( IsInGuild() and not playerguild ) then
				playerguild, _, _ = GetGuildInfo("player")
			end
		end
	end
end

function DoIKnowYou.dropDownQuery()
	DoIKnowYouFrame_TargetEditBox:SetText(_G[UIDROPDOWNMENU_INIT_MENU].name)
	DoIKnowYou:runQueryOn(_G[UIDROPDOWNMENU_INIT_MENU].name)
	DoIKnowYouFrame:Show()
end

UnitPopupButtons["DOIKNOWYOU"] = {
	text = L["Do I Know You?"],
	dist = 0,
	func = DoIKnowYou.dropDownQuery
}

function DoIKnowYou:UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData, ...)
	for i=1, UIDROPDOWNMENU_MAXBUTTONS do
		local button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i];
		if button.value == "DOIKNOWYOU" then
		    button.func = DoIKnowYou.dropDownQuery
		end
	end
end

function DoIKnowYou:updateRegisterDropdown(v)
	local types = {"SELF", "PLAYER", "FRIEND", "PARTY"}
	local j, i
	if(v==true) then
		tinsert(UnitPopupMenus["PLAYER"], 	#UnitPopupMenus["PLAYER"] - 1,	"DOIKNOWYOU")
		tinsert(UnitPopupMenus["FRIEND"],	#UnitPopupMenus["FRIEND"] - 1,	"DOIKNOWYOU")
		tinsert(UnitPopupMenus["PARTY"], 	#UnitPopupMenus["PARTY"] - 1,	"DOIKNOWYOU")
		self:SecureHook("UnitPopup_ShowMenu")
	else
		for j = 1, #types do
			local t = types[j]
			for i = 1, #UnitPopupMenus[t] do
				if UnitPopupMenus[t][i] == "DOIKNOWYOU" then
					tremove(UnitPopupMenus[t], i)
					break
				end
			end
		end
		self:Unhook("UnitPopup_ShowMenu")
	end
end

local function formatTooltip(tooltip, ...)
	local name, unitid = tooltip:GetUnit()
	if name then
		name = strupper(name)
		if UnitExists(unitid) and UnitIsPlayer(unitid) then
		
			if(DoIKnowYou.db.profile.showRepTooltip) then
		
				local rep = DoIKnowYou:getRepStatus(unitid)
				if(not (DoIKnowYou.db.profile.hideRepNeutral and rep==0)) then
					local tstring = "";
					if(DoIKnowYou.db.profile.showRepPrefix) then tstring = DoIKnowYou.db.profile.showRepPrefixText end
					if(DoIKnowYou.db.profile.colourRep) then tstring = tstring .. DoIKnowYou:getRepColor(rep) end
					tstring = tstring .. DoIKnowYou:getRepStatusText(unitid) .. "|r"
					GameTooltip:AddLine(tstring, 1, 1, 1, 1)
				end
			
			end
			if(DoIKnowYou.db.profile.showCommentTooltip) then
			
				-- NOTE: We only show ONE comment, even if multiple trusted notes
				-- exist. That's because the WoW tooltip has a VERY restrictive
				-- line-count limit which could easily break if we add too many lines.
				local rep = DoIKnowYou:getRepStatus(unitid)
				local note = DoIKnowYou:getPlayerNote(unitid, true) -- true = Allow fallback notes by trusted authors.
				if(note~=nil and not (DoIKnowYou.db.profile.hideCommentNeutral and rep==0)) then
					local tstring = "";
					if(DoIKnowYou.db.profile.showCommentPrefix) then tstring = DoIKnowYou.db.profile.showCommentPrefixText end
					if(DoIKnowYou.db.profile.colourComment) then tstring = tstring .. DoIKnowYou:getRepColor(rep) end
					tstring = tstring .. note .. "|r"
					GameTooltip:AddLine(tstring, 1, 1, 1, 1)
				end
			
			end
		end
	end
	return origGameTooltip(tooltip, ...)
end

function DoIKnowYou:FriendsList_Update()

	local friendOffset = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame);
	local friendIndex;
	for i=1, FRIENDS_TO_DISPLAY, 1 do
	
		friendIndex = friendOffset + i;
		local name, level, class, area, connected, status, note = GetFriendInfo(friendIndex);
		local noteText = getglobal("FriendsFrameFriendButton"..i.."ButtonTextNoteText");
		
		if(name) then
		
			name = strupper(name)
			
			if(self.db.realm.data[name]) then
				if(self.db.realm.data[name][self.db.realm.primaryChar] and self.db.realm.data[name][self.db.realm.primaryChar].note~="") then
					local note = self.db.realm.data[name][self.db.realm.primaryChar].note
					if(strlen(note)>40) then
						note = strsub(note, 1, 40) .. ".."
					end
					noteText:SetText(self:getRepColor(self.db.realm.data[name].total) .. "\"" .. note .. "\"")
				else
					noteText:SetText("")
				end
			end
			
		end
	end
end
function DoIKnowYou:IgnoreList_Update()

	local ignoreOffset = FauxScrollFrame_GetOffset(FriendsFrameIgnoreScrollFrame);
	local ignoreIndex;
	for i=1, IGNORES_TO_DISPLAY, 1 do
	
		ignoreIndex = ignoreOffset + i;
		local name = GetIgnoreName(ignoreIndex);
		local noteText = getglobal("FriendsFrameIgnoreButton"..i.."ButtonTextNoteText");
		
		if(name) then
		
			name = strupper(name)
			
			if(self.db.realm.data[name]) then
				if(self.db.realm.data[name][self.db.realm.primaryChar] and self.db.realm.data[name][self.db.realm.primaryChar].note~="") then
					local note = self.db.realm.data[name][self.db.realm.primaryChar].note
					if(strlen(note)>25) then
						note = strsub(note, 1, 25) .. ".."
					end
					noteText:SetText(self:getRepColor(self.db.realm.data[name].total) .. "\"" .. note .. "\"")
				else
					noteText:SetText("")
				end
			end
			
		end
	end
end

StaticPopupDialogs["DOIKNOWYOU_SET_FRIENDNOTE"] = {
	text = L["Set DoIKnowYou note for this player"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 48,
	hasWideEditBox = 1,
	OnAccept = function()
		local name, level, class, area, connected, status, note = GetFriendInfo(FriendsFrame.NotesID);
		name = strupper(name)
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		DoIKnowYou:saveCommentAbs(name, editBox:GetText());
		this:GetParent():Hide();
	end,
	OnShow = function()
		local name, level, class, area, connected, status, note = GetFriendInfo(FriendsFrame.NotesID);
		name = strupper(name)
		if(DoIKnowYou.db.realm.data[name]) then
			if(DoIKnowYou.db.realm.data[name][DoIKnowYou.db.realm.primaryChar]) then
				note = DoIKnowYou.db.realm.data[name][DoIKnowYou.db.realm.primaryChar].note
			else
				note = ""
			end
		end
		
		if ( note ) then
			getglobal(this:GetName().."WideEditBox"):SetText(note);
		else
			getglobal(this:GetName().."WideEditBox"):SetText("");
		end
		getglobal(this:GetName().."WideEditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
		ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."WideEditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local name, level, class, area, connected, status, note = GetFriendInfo(FriendsFrame.NotesID);
		name = strupper(name)
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		DoIKnowYou:saveCommentAbs(name, editBox:GetText());
		FriendsList_Update()
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["DOIKNOWYOU_SET_IGNORENOTE"] = {
	text = L["Set DoIKnowYou note for this player"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 48,
	hasWideEditBox = 1,
	OnAccept = function()
		local name = ignoreDialogName
		name = strupper(name)
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		DoIKnowYou:saveCommentAbs(name, editBox:GetText());
		this:GetParent():Hide();
	end,
	OnShow = function()
		local name = ignoreDialogName
		name = strupper(name)
		if(DoIKnowYou.db.realm.data[name]) then
			if(DoIKnowYou.db.realm.data[name][DoIKnowYou.db.realm.primaryChar]) then
				note = DoIKnowYou.db.realm.data[name][DoIKnowYou.db.realm.primaryChar].note
			else
				note = ""
			end
		end
		
		if ( note ) then
			getglobal(this:GetName().."WideEditBox"):SetText(note);
		else
			getglobal(this:GetName().."WideEditBox"):SetText("");
		end
		getglobal(this:GetName().."WideEditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
		ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."WideEditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local name = ignoreDialogName
		name = strupper(name)
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		DoIKnowYou:saveCommentAbs(name, editBox:GetText());
		IgnoreList_Update()
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

local OrigAddMessage = ChatFrame1.AddMessage

local function DoIKnowYouChatFrameAddMessage(self, text, ...)
	if(type(text) == "string") then
		if text == ""  or not DoIKnowYou.db.profile.showChatIndicator then
			return OrigAddMessage(self, text, ...)
		end

		local info = nil
		local _, _, name = text:find("|Hplayer:[^:]+:%d+|h%[(.-)%]|h")
		if name then
			local dInsert = ""
			if(DoIKnowYou.db.realm.data[strupper(name)]) then
				if not (DoIKnowYou.db.realm.data[strupper(name)].total==0 and DoIKnowYou.db.profile.hideChatIndicatorNeutral) then
					dInsert = ":" .. DoIKnowYou:getRepColor(DoIKnowYou.db.realm.data[strupper(name)].total) .. DoIKnowYou.db.profile.chatIndicatorText .. "|r"
				end
			end
			text = text:gsub("|Hplayer:([^:]+):(%d+)|h%[.-%]|h", "|Hplayer:%1:%2|h["..name..dInsert.."]|h")
		end
	end

	return OrigAddMessage(self, text, ...)
end
for i=1, NUM_CHAT_WINDOWS do
	local cf = getglobal("ChatFrame"..i)
	if(i~=2) then
		cf.AddMessage = DoIKnowYouChatFrameAddMessage
	end
end

function DoIKnowYou:LFMButton_OnEnter()
	local tipText = GameTooltip:GetName() .. "TextLeft"
	for i = 2, getglobal(GameTooltip:GetName()):NumLines() do
		local lineText = getglobal(tipText .. i):GetText()
		local name, details = strmatch(lineText, "([^%s%p]+)(%s%-%s.+)")
		if(name) then
			if(self.db.realm.data[strupper(name)]) then
				getglobal(tipText..i):SetText(self:getRepColor(self.db.realm.data[strupper(name)].total) .. name .. "|r" .. details)
			end
		end
	end
end
function DoIKnowYou:LFMFrame_Update()
	local name, level, zone, class, criteria1, criteria2, criteria3, comment, numPartyMembers, isLFM;
	local scrollOffset = FauxScrollFrame_GetOffset(LFMListScrollFrame);
	local selectedLFMType = UIDropDownMenu_GetSelectedID(LFMFrameTypeDropDown);
	local selectedLFMName = UIDropDownMenu_GetSelectedID(LFMFrameNameDropDown);
	local numResults, totalCount = GetNumLFGResults(selectedLFMType, selectedLFMName);
	local resultIndex;
	local button
	for i=1, LFGS_TO_DISPLAY, 1 do
		resultIndex = scrollOffset + i;
		if ( resultIndex <= numResults ) then
			name, level, zone, class, criteria1, criteria2, criteria3, comment, numPartyMembers, isLFM, classFileName = GetLFGResults(selectedLFMType, selectedLFMName, resultIndex);
			if(name) then
				if(self.db.realm.data[strupper(name)]) then
					getglobal("LFMFrameButton"..i.."Name"):SetText(self:getRepColor(self.db.realm.data[strupper(name)].total) .. name)
				end
			end
		end
	end
end

function DoIKnowYou:updateSavedGuilds()
	
	if(IsInGuild()) then playerguild, _, _ = GetGuildInfo("player") else playerguild = nil end
	
	--Check guild list for guilds our characters are in, and remove as appropriate.
	for i,v in pairs(self.db.realm.guilds) do
		if(v[playername]) then
			if(IsInGuild() and playerguild==i) then
				-- All is well
			else
				-- We shouldn't be in this list
				v[playername] = nil
			end
		end
	end
	
	if(IsInGuild() and playerguild) then
		if not self.db.realm.guilds[playerguild] then
			self.db.realm.guilds[playerguild] = {}
		end
		if not self.db.realm.guilds[playerguild][playername] then
			self.db.realm.guilds[playerguild][playername] = true
			self:debugOut(format("Adding %s to guild: %s", playername, playerguild))
		end
	end
	
end

function DoIKnowYou:OnInitialize()

	playername = UnitName("player")
	
	self.db = LibStub("AceDB-3.0"):New("DoIKnowYouDB", defaultData, "Default")
	if not self.db.realm.primaryChar then
		if self.db.global.primaryChar then self.db.realm.primaryChar = self.db.global.primaryChar
		else self.db.realm.primaryChar = playername end
	end	
	
	self.events = self.events or LibStub("CallbackHandler-1.0"):New(DoIKnowYou)
	
	if LibStub:GetLibrary("LibDogTag-3.0", true) then
		LibStub("LibDogTag-3.0"):AddTag('Unit', 'DoIKnowYou', {
			code = function(unit)
				return self:getRepStatus(unit)
			end,
			arg = { 'unit', 'string;undef', 'player' },
			ret = 'string;nil',
			doc = 'Return the DoIKnowYou status of unit',
			example = ('[DoIKnowYou] => %q'):format('+6'),
			category = 'DoIKnowYou',
		})
		LibStub("LibDogTag-3.0"):AddTag('Unit', 'DoIKnowYouText', {
			code = function(unit)
				return self:getRepStatusText(unit)
			end,
			arg = { 'unit', 'string;undef', 'player' },
			ret = 'string;nil',
			doc = 'Return the DoIKnowYou status of unit, as a text string',
			example = ('[DoIKnowYou] => %q'):format('Positive'),
			category = 'DoIKnowYou',
		})
		LibStub("LibDogTag-3.0"):AddTag('Unit', 'DoIKnowYouColor', {
			code = function(value, unit)
				local rep = self:getRepStatus(unit)
				local cols = self:getRepColor(rep)
				return cols .. value
			end,
			arg = { 'value', 'string;undef', '@undef',
					'unit', 'string;undef', 'player' },
			ret = 'string;nil',
			doc = 'Return the color assosicated with the DoIKnowYou status of unit',
			example = ('[DoIKnowYouText:DoIKnowYouColor] => %q'):format('|cff00ff00Positive|r'),
			category = 'DoIKnowYou',
		})
		LibStub("LibDogTag-3.0"):AddTag('Unit', 'DoIKnowYouNote', {
			code = function(unit)
				return self:getPlayerNote(unit)
			end,
			arg = { 'unit', 'string;undef', 'player' },
			ret = 'string;nil',
			doc = 'Return the DoIKnowYou note of the unit, as set by the player',
			example = ('[DoIKnowYouNote] => %q'):format('Great player'),
			category = 'DoIKnowYou',
		})
		
		self:chatOut(L["DogTag-3.0 tags registered"]);
		
	end
				
	origGameTooltip = GameTooltip:GetScript("OnTooltipSetUnit")
	GameTooltip:SetScript("OnTooltipSetUnit", formatTooltip)
	
	vFrame = CreateFrame("Frame", "DoIKnowYouVirtualFrame")
	vFrame:SetScript("OnEvent", eventHandler)
		
	-- OnUpdate hook for timer based events!
	vFrame:SetScript("OnUpdate", frameUpdate)

	--Register guild change event, to check for purging data on leaving guild. Cross guild contamination omgwtf!
	vFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
	
	--Register party changed event, maybe others. These are for auto-query.
	vFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	vFrame:RegisterEvent("TRADE_SHOW")
	vFrame:RegisterEvent("CHAT_MSG_WHISPER")
	
	--Register communications event
	vFrame:RegisterEvent("CHAT_MSG_ADDON")
	
	if(self.db.profile.useDropDown) then
		tinsert(UnitPopupMenus["PLAYER"], 	#UnitPopupMenus["PLAYER"] - 1,	"DOIKNOWYOU")
		tinsert(UnitPopupMenus["FRIEND"],	#UnitPopupMenus["FRIEND"] - 1,	"DOIKNOWYOU")
		tinsert(UnitPopupMenus["PARTY"], 	#UnitPopupMenus["PARTY"] - 1,	"DOIKNOWYOU")
		self:SecureHook("UnitPopup_ShowMenu")
	end
	
	--Hook friends list update, to insert own notes! Also replace script to set note on frame.
	self:SecureHook("FriendsList_Update")
	for i=1, FRIENDS_TO_DISPLAY, 1 do
		getglobal("FriendsFrameFriendButton"..i.."ButtonTextNote"):SetScript("OnClick", function()
			FriendsFrame.NotesID = this:GetParent():GetParent():GetID();
			local dialog = StaticPopup_Show("DOIKNOWYOU_SET_FRIENDNOTE", GetFriendInfo(FriendsFrame.NotesID));
			PlaySound("igCharacterInfoClose");
		end);
	end
	
	self:SecureHook("IgnoreList_Update")
	for i=1,20 do
		getglobal("FriendsFrameIgnoreButton" ..i.. "ButtonText"):CreateFontString("FriendsFrameIgnoreButton" ..i.. "ButtonTextNoteText")
		getglobal("FriendsFrameIgnoreButton" ..i.. "ButtonTextNoteText"):SetFontObject("GameFontNormal")
		getglobal("FriendsFrameIgnoreButton" ..i.. "ButtonTextNoteText"):SetPoint("TOPLEFT", 120, -3)
		local ignoreNote = CreateFrame("Button", "FriendsFrameIgnoreButton" ..i.. "ButtonTextNote", getglobal("FriendsFrameIgnoreButton" .. i .. "ButtonText"))
		ignoreNote:SetWidth(7); ignoreNote:SetHeight(8);
		ignoreNote:SetPoint("LEFT", "FriendsFrameIgnoreButton"..i.."ButtonText", 0, 0)
		local ignoreNoteIcon = ignoreNote:CreateTexture("FriendsFrameIgnoreButton"..i.."ButtonTextNoteIcon", "BACKGROUND")
		ignoreNoteIcon:SetTexture("Interface/FriendsFrame/UI-FriendsFrame-Note")
		ignoreNoteIcon:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		ignoreNoteIcon:SetAllPoints(ignoreNote)
		ignoreNote:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight", "ADD")
		ignoreNote:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		ignoreNote:SetScript("OnClick", function()
			ignoreDialogName = getglobal(this:GetParent():GetName() .. "Name"):GetText()
			local dialog = StaticPopup_Show("DOIKNOWYOU_SET_IGNORENOTE", ignoreDialogName);
			PlaySound("igCharacterInfoClose");
		end)
	end	
	
	--Hook LFM Frame OnEnter, to change tooltip, and LFMFrame OnUpdate, to change frame itself!
	self:SecureHook("LFMButton_OnEnter")
	self:SecureHook("LFMFrame_Update")
	
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DoIKnowYou", optionsTable)
	optFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DoIKnowYou", "DoIKnowYou")
	optionsTable.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	optionsTable.args.profile.order = 300
		
	self:initFrameTexts()
	
	self:chatOut(format(L["r%d loaded. use /diky or /doiknowyou to access."], VERSION))
	
end

function DoIKnowYou:OnEnable()

	addonEnabled = true
	-- Flush chatOut buffer
	if(#chatOutBuffer>0) then
		for i,v in ipairs(chatOutBuffer) do
			self:chatOut(v)
			chatOutBuffer[i] = nil
		end
	end
	
	if(IsInGuild()) then playerguild, _, _ = GetGuildInfo("player") else playerguild = nil end
	self:updateSavedGuilds()

	-- Upgrade DB if necessary
	if(not self.db.global.version or self.db.global.version < VERSION_DB) then
		self.db.global.version = VERSION_DB
	end
	-- Ensure all data has creation & ttl
	-- Update 19/5/08 - add source info (default source = guild)
	for i1, v1 in pairs(self.db.realm.data) do
		for i2, v2 in pairs(v1) do
			if(type(v2)=="table") then
				if(not v2.creation) then
					v2.creation = 0
				end
				if(not v2.ttl) then
					v2.ttl = time() + dataTTL
				end
				if(i2~=self.db.realm.primaryChar) then
					if(not v2.source) then
						v2.source = DIKY_SOURCE["GUILD"]
					end
					if(not v2.guild and IsInGuild()) then
						v2.guild = playerguild
					end
				end
			end
		end
	end
	-- Cleanup expired data from other chars
	for i1, v1 in pairs(self.db.realm.data) do
		for i2, v2 in pairs(v1) do
			if(type(v2)=="table") then
				if(i2 ~= self.db.realm.primaryChar and time() > v2.ttl) then
					self.db.realm.data[i1][i2] = nil -- TTL passed, clear.
				end
			end
		end
	end
	-- Cleanup of 0 rep with no note.
	local n; local nc = false;
	for i1,v1 in pairs(self.db.realm.data) do
		nc=false;
		for i2, v2 in pairs(self.db.realm.data[i1]) do
			if(type(v2)=="table") then
				if(self.db.realm.data[i1][i2].rep == 0) then
					if(self.db.realm.data[i1][i2].note~="") then
						nc = true -- No rep, but has note. Valid.
					else
						self.db.realm.data[i1][i2] = nil -- remove redundant entries by char.
					end
				else
					nc=true; -- Has rep, regardless of note. Valid.
				end
			end
		end
		if(nc==false) then -- No validation, delete all.
			self.db.realm.data[i1] = nil
		end
	end
	-- Delete redundant tables.
	self.db.realm.rep = nil
	self.db.realm.note = nil
	self.db.realm.total = nil
	
end

_G.SlashCmdList.DOIKNOWYOU = function(input)
	if DoIKnowYouFrame:IsVisible() == true and input == "" then
		DoIKnowYouFrame:Hide()
	else
		if(input==L["console"]) then
			DoIKnowYouConsole:Show()
			return
		end
		if(input==L["options"]) then
			LibStub("AceConfigDialog-3.0"):Open("DoIKnowYou")
			return
		end
		if(input==L["dataview"] or input==L["data"] or input==L["summary"]) then
			DoIKnowYouDataview:Show()
			return
		end
		if(input==L["version"]) then
			DoIKnowYou:chatOut(format(L["version is %d"], VERSION))
			return
		end
		if(input==L["versioncheck"]) then
			DoIKnowYou:runVersionCheck()
			return
		end
		if(input==L["purge"]) then
			DoIKnowYou.db.realm.data = nil
			DoIKnowYou:chatOut(L["Realm saved data purged."])
			return
		end
		if(input=="debug") then
			DoIKnowYou.db.profile.debugMode = not DoIKnowYou.db.profile.debugMode
			if(DoIKnowYou.db.profile.debugMode) then
				DoIKnowYou:chatOut("Debug enabled.")
			else
				DoIKnowYou:chatOut("Debug disabled.")
			end
			return
		end
		if(input~="") then
			DoIKnowYouFrame_TargetEditBox:SetText(input)
			DoIKnowYouFrame:Show()
			activeQuery = input
			DoIKnowYou:runQueryOn(input)
			return
		end
		if(UnitName("target")~=nil) then
			if(UnitIsPlayer("target")) then
				DoIKnowYouFrame_TargetEditBox:SetText(UnitName("target"))
				activeQuery = input
				DoIKnowYou:runQueryOn(UnitName("target"))
				DoIKnowYouFrame:Show()
				return
			else
				DoIKnowYou:chatOut(L[" error: Target must be a player character."])
				return
			end
		end
		DoIKnowYouFrame:Show()
	end
end

_G.SLASH_DOIKNOWYOU1 = L["/doiknowyou"]
_G.SLASH_DOIKNOWYOU2 = L["/diky"]
