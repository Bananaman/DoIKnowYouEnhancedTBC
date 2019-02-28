-- DoIKnowYou
-- zhTW localisation.

local L = LibStub("AceLocale-3.0"):NewLocale("DoIKnowYou", "zhTW", false)
if not L then return end

L["DoIKnowYou"] 													= "何許人?"

-- Options texts

L["Options for DoIKnowYou!"] 										= "何許人?的設定"
L["Tooltip"] 														= "提示框"
L["Options for DoIKnowYou's additions to the game tooltip"] 		= "將何許人?附加在提示框顯示的選項"
L["Show reputation tooltip"] 										= "提示框顯示信譽值"
L["Hide reputation tooltip when neutral"] 							= "當目標的信譽是中性時隱藏提示框的信譽值"
L["Show prefix"] 													= "顯示標題"
L["Prefix text:"] 													= "標題文字"
L["Colour reputation text by reputation"] 							= "信譽顏色以相應的信譽值著色"
L["Show comment tooltip"] 											= "在提示框顯示評論"
L["Hide comment tooltip when neutral"] 								= "隱藏提示框的中性評論"
L["Show prefix:"] 													= "顯示標題"
L["Prefix text:"] 													= "標題文字"
L["Colour comment text by reputation"] 								= "評論顏色以相應的信譽值著色"
L["Trusted tooltip comment authors to check when no personal comment exists (separated by commas):"] = true

L["Auto Query"] 													= "自動查詢"
L["Options for automatic queries"] 									= "自動查詢設定"
L["Use Auto Query"] 												= "使用自動查詢"
L["... when group members change"] 									= "....當隊員變更時"
L["This event includes pretty much everything to do with a group, such as joining a new group, a new member joining an existing group, or someone leaving the group."] = "這事件涉及相當多的組隊過程，如加入一個新的隊伍，一個新隊員加入現有的隊伍，或者是有人離開隊伍"
L["... when whispering another player"] 							= "....當向另一玩家密語"
L["This option enable auto-query when whispering another player, with data output to the summary frame."] = "這個選項是在當你向另一玩家密語時啟用自動查詢, 及把查詢的數據輸出在總結框"
L["... when trading with another player"] 							= "....當向另一玩家交易"
L["This option works like the others, on trade."] 					= "這個選項和其它差不多, 在交易時"
L["... when you move your mouse over another player"] 				= "....當你把鼠標放在另一玩家"
L["This option creates a lot of queries, which you really won't need most of the time. You can already see your own data on tooltips, this simply broadcasts a request for data too, and adds info to the summary frame."] = "此選項會作出許多查詢, 大部份時間你不需要使用這選項. 您已經可以看到自己的數據在提示框上, 這只是廣播一個要求數據的查詢, 把信息加在總結框裡"
L["Announce status in chat window"] 								= "在聊天窗口顯示結果"
L["Announce the result of an auto-query in the chat window. This message will only be visible to yourself, not to other players."] = "在聊天窗口顯示自動查詢的結果. 只有你自己會看見這個訊息，其他玩家或隊友不會看到."
L["Report when auto-query returns neutral"] 						= "如自動查詢是中性評論時報告"
L["When this option is disabled, you will only see reports on players with positive or negative ratings announced in your chat window."] = "當此選項停用的話，你只會看到玩家正面或負面的評級顯示在您的聊天窗口"

L["Other"] 															= "其它"
L["Other options"] 													= "其它選項"
L["Use right-click drop down \"Do I Know You?\""] 					= "將\"何許人?\"加右擊玩家頭像的選單內 "
L["When enabled, the option \"Do I Know You?\" will be added to the right-click menu on players, allowing you to query them by that menu easily from chat channels, unit frames, etc.."] = "當啟用這選項時, \"何許人?\" 會被加進右擊玩家框的選單裡, 讓您可以很容易從聊天頻道右擊的選單或在玩家頭像框的選單來查詢他們"

L["Show reputation indicator in chat"] 								= "在聊天窗口顯示信譽值指標"
L["When enabled, a colour-coded indicator will be added to your chat frame next to players names."] = "當啟用這選項時, 顏色顯示會被加進聊天窗口內玩家名稱的旁邊."
L["Hide chat indicator when neutral"] 								= "如是中性時隱藏聊天窗口顯示"
L["Chat indicator text:"] 											= "聊天窗口文字:"

L["Send addon messages"]											= "傳送插件訊息"
L["Parse incoming addon messages"]									= "解讀插件傳入的訊息"

L["Purge data from a guild when you no longer have any characters in it."] = "Purge data from a guild when you no longer have any characters in it."

-- Important!

L["Positive"] 			= "正面"
L["Negative"] 			= "負面"
L["Neutral"] 			= "中性"

-- Frame texts
--Main frame
L["Data generated from %s sources."] 								= "數據由 %s 來源所產生." -- number of data source
L["running query on %s"] 											= "向 %s 作查詢" -- player
L["Query on: %s"] 													= "查詢: %s" -- player name
L["No notes received from shared data sources."] 					= "沒有從共享數據源收到記事"
L["Note for %s saved as \"%s\""]									= "%s 的記事經已儲存為 \"%s\"" -- player name, note
L["Rep changed for %s to %d"] 										= "%s 的信譽值改為 %d" -- player name, rep (-1, 0 or 1)

L["Input the name of the player"] 									= "請輸入玩家的名稱"
L["Player comment:"] 												= "玩家評論:"
L["Shared data:"] 													= "共享的數據:"
L["Options"]														= "選項"
L["Console"]														= "操縱臺"
L["Data View"]														= "數據撿視"
L["From Target"]													= "從目標"
L["Sync Data"]														= "數據同步"
L["Global Sync"]													= "總體數據同步"

--Dataview
L["Search all saved data"]											= "搜索所有已儲存的資料"
L["Summary Data"] 													= "總結數據"
L["Reset"] 															= "重置"
L["Filter"] 														= "過濾"
L["Name"] 															= "名稱"
L["Note"] 															= "記事"
L["Rep"] 															= "信譽"
L["Total"] 															= "總數"
L["Sources"] 														= "來源"
L["Notes"] 															= "記事"

L["No data shown. Use the filters below to view data."] 			= "沒有數據顯示。使用以下過濾器來查看數據."
L["Now viewing %d to %d of %d (Page %d of %d)"] 					= "現正觀看 %d to %d of %d (Page %d of %d)" --don't know the meaning of the variables, can't translate 

--Auto-query
L["Auto-Query (%s): %s has returned positive!"] 					= "自動查詢 (%s): %s 結果為正面!"
L["Auto-Query (%s): %s has returned neutral."] 						= "自動查詢 (%s): %s 結果為中性."
L["Auto-Query (%s): %s has returned negative!"] 					= "自動查詢 (%s): %s 結果為負面!"

-- Other

L["Do I Know You?"] 												= "何許人?" -- Dropdown text
L["DogTag-3.0 tags registered"] 									= "DogTag-3.0 tags 已註冊"
L["r%d loaded. use /diky or /doiknowyou to access."] 				= "r%d 已運作. 請用 /diky 或 /doiknowyou 來使用選項." -- Loaded text
L["version is %d"] 													= "版本為 %d"
L["Realm saved data purged."] 										= "本服儲存數據已清除."
L[" error: Target must be a player character."] 					= " 錯誤: 目標必需是玩家."
L["You have left %s, no characters left in guild - purging data."]						= "You have left %s, no characters left in guild - purging data."

L["Set DoIKnowYou note for this player"]							= "為這玩家設置 DoIKnowYou 的記事"

-- Slash command options

L["console"] 				= "操縱臺"
L["options"] 				= "選項"
L["dataview"] 				= "數據撿視"
L["data"] 					= "數據"
L["summary"] 				= "總結"
L["version"] 				= "版本"
L["versioncheck"] 			= "版本撿查"
L["purge"] 					= "清除"

-- The slash commands!

L["/doiknowyou"] 			= "/doiknowyou"
L["/diky"]	 				= "/diky"
