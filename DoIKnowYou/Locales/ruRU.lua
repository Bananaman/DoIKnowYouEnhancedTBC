-- DoIKnowYou
-- enUS & enGB localisation.
local L = LibStub("AceLocale-3.0"):NewLocale("DoIKnowYou", "ruRU")
if not L then return end

L["DoIKnowYou"] = "АЯТебяЗнаю"

-- Options texts

L["Options for DoIKnowYou!"] = "Опции АЯТебяЗнаю!"
L["Tooltip"] = "Подсказка"
L["Options for DoIKnowYou's additions to the game tooltip"] = "Настройки добавлений АЯТебяЗнаю к всплывающей подсказке"
L["Show reputation tooltip"] = "Показать репутацию в подсказке"
L["Hide reputation tooltip when neutral"] = "Спрятать репутацию в подсказке, когда она нейтральна"
L["Show prefix"] = "Показать префикс"
L["Prefix text:"] = "Текст префикса:"
L["Colour reputation text by reputation"] = "Подцвечивать текст репутации соответственно ей"
L["Show comment tooltip"] = "Показать комментарии в подсказке"
L["Hide comment tooltip when neutral"] = "Спрятать комментарии в подсказке, когда репутация нейтральна"
L["Show prefix:"] = "Показать префикс:"
L["Prefix text:"] = "Текст префикса:"
L["Colour comment text by reputation"] = "Подцвечивать текст комментариев соответственно репутации"

L["Auto Query"] = "Автозапрос"
L["Options for automatic queries"] = "Настройки автоматических запросов"
L["Use Auto Query"] = "Использовать автозапрос"
L["... when group members change"] = "... когда меняется состав группы"
L["This event includes pretty much everything to do with a group, such as joining a new group, a new member joining an existing group, or someone leaving the group."] = "Эта опция перекрывает все операции с группой - присоединение к новой, добавление игрока в существующую, или выход кого-либо из группы."
L["... when whispering another player"] = "... когда шепчете другому игроку"
L["This option enable auto-query when whispering another player, with data output to the summary frame."] = "Данная опция разрешает автозапрос, когда вы шепчете другому игроку, с отсылкой данных в окно обобщения."
L["... when trading with another player"] = "... когда торгуете с другим игроком"
L["This option works like the others, on trade."] = "Та же опция, что и другие, но для торговли."
L["... when you move your mouse over another player"] = "... когда наводите мышку на другого игрока"
L["This option creates a lot of queries, which you really won't need most of the time. You can already see your own data on tooltips, this simply broadcasts a request for data too, and adds info to the summary frame."] = "Данная опция создаёт кучу запросов, которые вам как правило ни к чему. Вы можете даже увидеть собственные данные, т.к. этот запрос так же посылается, и добавляет данные в окно обобщения."
L["Announce status in chat window"] = "Объявлять статус в окне чата"
L["Announce the result of an auto-query in the chat window. This message will only be visible to yourself, not to other players."] = "Обхявляет результат автозапроса в окне чата. Это будет видно только вам, но не другим игрокам."
L["Report when auto-query returns neutral"] = "Рапортовать, когда автозапрос выдал нейтральность"
L["When this option is disabled, you will only see reports on players with positive or negative ratings announced in your chat window."] = "Если выключено, вы увидите только рапорты об игроках с позитивными или негативными рейтингами в своём окне чата."

L["Other"] = "Прочее"
L["Other options"] = "Прочие настройки"
L["Use right-click drop down \"Do I Know You?\""] = "Используйте выпадающее по правому щелчку меню \"А Я Тебя Знаю?\""
L["When enabled, the option \"Do I Know You?\" will be added to the right-click menu on players, allowing you to query them by that menu easily from chat channels, unit frames, etc.."] = "Если включено, опция \"А Я Тебя Знаю?\" будет добавлена к выпадающему по правому щелчку меню на игроках, позволяя вам запросить данные на них - в каналах чата, рамках объектов и т.п..."

L["Show reputation indicator in chat"] = "Показывать индикатор репутации в чате"
L["When enabled, a colour-coded indicator will be added to your chat frame next to players names."] = "Когда включено, цветной индикатор будет добавляться в окно чата рядом с именами игроков."
L["Hide chat indicator when neutral"] = "Прятать чат-индикатор, когда репутация нейтральна"
L["Chat indicator text:"] = "Текст чат-индикатора:"

L["Send addon messages"] = "Посылать сообщения аддона"
L["Parse incoming addon messages"] = "Обрабатывать полученные сообщения аддона"

L["Purge data from a guild when you no longer have any characters in it."] = "Очищать данные, полученные от гильдии, \nкогда у вас не осталось в ней персонажей."

-- Important!

L["Positive"] = "Положительная"
L["Negative"] = "Отрицательная"
L["Neutral"] = "Нейтральная"

-- Frame texts
--Main frame
L["Data generated from %s sources."] = "Данные собраны с %s источников." -- number of data source
L["running query on %s"] = "обрабатывается запрос на %s" -- player
L["Query on: %s"] = "Запрос на: %s" -- player name
L["No notes received from shared data sources."] = "От разделяемых источников данных не получено никаких заметок."
L["Note for %s saved as %s"] = "Заметьте, что %s записан(а) как %s" -- player name, note
L["Rep changed for %s to %d"] = "Репутация %s изменилась на %d" -- player name, rep (-1, 0 or 1)

L["Input the name of the player"] = "Введите имя игрока"
L["Player comment:"] = "Комментарий игрока:"
L["Shared data:"] = "Разделяемые данные:"
L["Options"] = "Настройки"
L["Console"] = "Консоль"
L["Data View"] = "Просмотр"
L["From Target"] = "Взять с цели"
L["Sync Data"] = "Синхронизировать"
L["Global Sync"] = "Общая синхронизация"


--Dataview
L["Search all saved data"] = "Поиск по всем записям"
L["Summary Data"] = "Сводка"
L["Reset"] = "Сброс"
L["Filter"] = "Фильтр"
L["Name"] = "Имя"
L["Note"] = "Заметка"
L["Rep"] = "Репа"
L["Total"] = "Всего"
L["Sources"] = "Источников"
L["Notes"] = "Заметки"

L["No data shown. Use the filters below to view data."] = "Данные не показываются. Используйте фильтры внизу для просмотра данных."
L["Now viewing %d to %d of %d (Page %d of %d)"] = "Смотрим с %d до %d из %d (Стр. %d из %d)"

--Auto-query
L["Auto-Query (%s): %s has returned positive!"] = "Автозапрос (%s): %s выдал положительный результат!"
L["Auto-Query (%s): %s has returned neutral."] = "Автозапрос (%s): %s выдал нейтральный результат!"
L["Auto-Query (%s): %s has returned negative!"] = "Автозапрос (%s): %s выдал отрицательный результат!"

-- Other

L["Do I Know You?"] = "А Я Тебя Знаю?" -- Dropdown text
L["DogTag-3.0 tags registered"] = "Зарегистрированы метки DogTag-3.0"
L["r%d loaded. use /diky or /doiknowyou to access."] = "r%d загружен. Используйте /diky или /аятебязнаю для доступа." -- Loaded text
L["version is %d"] = "текущая версия %d"
L["Realm saved data purged."] = "Сохранённые данные игрового мира очищены."
L[" error: Target must be a player character."] = " ошибка: Цель должна быть игроком."
L["You have left %s, no characters left in guild - purging data."] = "Вы покинули гильдию %s и у вас не осталось в ней персонажей - произвожу чистку данных." --  Guild name

L["Set DoIKnowYou note for this player"] = "Установить заметку АЯТебяЗнаю для этого игрока"

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

L["/doiknowyou"] = "/аятебязнаю"
L["/diky"] = true

