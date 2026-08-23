--- WC (Window Cluster)
---
--- 複数窓の FF11 を、キーひとつで切り替える。
--- キーを押した窓が全窓に「#N を前に出せ」と IPC で投げ、
--- 自分が #N の窓だけが take_focus() する。
--- 押した窓 = 今フォーカスされている窓なので、「次の窓」も自分で計算できる。

_addon.author = 'Yoya'
_addon.version = '1.0.0'
_addon.commands = {'windowcluster', 'wc'}

require('chat')  -- string:color (色の定義は addons/libs/chat/colors.lua)
local config = require 'config'
local focus = require 'focus'

-- IPC は全窓の全アドオンに届くので、自分のものだけ拾う
local SIGNATURE = "WC"
local FOCUS_PREFIX = SIGNATURE..".focus."
local FOCUS_PATTERN = "^"..SIGNATURE.."%.focus%.(%d+)$"

local COLOR_INFO = 6  -- エメラルド
local COLOR_WARN = 2  -- 赤紫

local defaults = {
    AccountList = { },
}
local settings = config.load(defaults)

-- 直接 add_to_chat / send_command すると日本語が化けるので shift_jis に通す
local function say(color, text)
    windower.add_to_chat(17, windower.to_shift_jis(text:color(color)))
end

local function send_command(command)
    windower.send_command(windower.to_shift_jis(command))
end

local name_to_index, indexes, build_errors = focus.build(settings.AccountList)

local valid_index = {}
for _, index in ipairs(indexes) do
    valid_index[index] = true
end

-- 自分がどの窓か。AccountList に無いキャラなら nil
local my_index = nil

local function init_binds()
    for _, index in ipairs(indexes) do
	send_command('bind @'..index..' wc focus '..index)   -- Win+<番号>
	send_command('bind ~%'..index..' wc focus '..index)  -- Alt+<番号>
    end
    -- Alt+Tab は乗っ取れなかったので、Ctrl+Tab を「次の窓」にする
    send_command('bind ^tab wc focus next')
    send_command('bind ^DIK_TAB wc focus next')
    -- FF11 の邪魔になる Windows のショートカットを潰す
    send_command('bind @l wc print Win+L are disabled')  -- 画面ロック
    send_command('bind @m wc print Win+M are disabled')  -- 全ウィンドウ最小化
end

local function clear_binds()
    for _, index in ipairs(indexes) do
	send_command('unbind @'..index)
	send_command('unbind ~%'..index)
    end
    send_command('unbind ^tab')
    send_command('unbind ^DIK_TAB')
    send_command('unbind @l')
    send_command('unbind @m')
end

--- 自分の窓番号を決め直す。
--- load 直後は未ログインで player が取れないので、login でも呼ぶ。
local function update_my_index(event)
    local player = windower.ffxi.get_player()
    if player == nil or player.name == nil then
	my_index = nil  -- まだ分からない。login で取り直す
	return
    end
    my_index = name_to_index[player.name]
    if my_index == nil then
	say(COLOR_WARN, ("[%s] %s は AccountList にありません。この窓は切り替え先になりません")
		:format(event, player.name))
    else
	say(COLOR_INFO, ("[%s] window #%d %s"):format(event, my_index, player.name))
    end
end

--- wc focus <番号>|next
local function cmd_focus(arg)
    if #indexes == 0 then
	say(COLOR_WARN, "AccountList が空です。data/settings.xml を書いてください")
	return
    end
    local index
    if arg == nil then
	say(COLOR_WARN, "wc focus <番号>|next")
	return
    elseif arg == 'next' then
	index = focus.next_index(indexes, my_index)
    else
	index = tonumber(arg)
    end
    if index == nil then
	say(COLOR_WARN, "wc focus <番号>|next")
	return
    end
    if not valid_index[index] then
	say(COLOR_WARN, "window #"..index.." は AccountList にありません")
	return
    end
    if index == my_index then
	return  -- 自分が既にフォーカスされている
    end
    windower.send_ipc_message(FOCUS_PREFIX..tostring(index))
end

local function cmd_show()
    local player = windower.ffxi.get_player()
    say(COLOR_INFO, ("me: %s  window: %s"):format(
	    (player ~= nil and player.name or "(未ログイン)"), tostring(my_index)))
    for _, index in ipairs(indexes) do
	local names = {}
	for name, i in pairs(name_to_index) do
	    if i == index then
		table.insert(names, name)
	    end
	end
	table.sort(names)
	say(COLOR_INFO, ("  #%d  %s"):format(index, table.concat(names, ", ")))
    end
end

local function cmd_help()
    say(COLOR_INFO, "wc focus <番号>  - その窓を前に出す (Win+<番号> / Alt+<番号>)")
    say(COLOR_INFO, "wc focus next    - 次の窓を前に出す (Ctrl+Tab)")
    say(COLOR_INFO, "wc show          - 窓番号とキャラ名の対応を出す")
    say(COLOR_INFO, "wc reload        - WC を読み直す")
    say(COLOR_INFO, "wc help          - このヘルプ")
end

windower.register_event('addon command', function(...)
    local subcommand = select(1, ...)
    subcommand = subcommand and subcommand:lower() or 'help'
    if subcommand == 'focus' then
	cmd_focus(select(2, ...))
    elseif subcommand == 'print' then
	-- bind から呼ばれる。押されたキーを潰すのが目的で、出力はおまけ
	say(COLOR_INFO, table.concat({select(2, ...)}, " "))
    elseif subcommand == 'show' then
	cmd_show()
    elseif subcommand == 'reload' then
	send_command('lua reload WC')
    elseif subcommand == 'help' then
	cmd_help()
    else
	say(COLOR_WARN, "See wc help")
    end
end)

windower.register_event('ipc message', function(message)
    local index = tonumber(message:match(FOCUS_PATTERN))
    if index == nil then
	return  -- 他のアドオンの IPC
    end
    if index == my_index then
	windower.take_focus()
    end
end)

windower.register_event('load', function()
    for _, message in ipairs(build_errors) do
	say(COLOR_WARN, message)
    end
    if #indexes == 0 then
	say(COLOR_WARN, "AccountList が空です。data/settings.xml を書いてください")
    end
    init_binds()
    update_my_index("load")
end)

windower.register_event('login', function()
    update_my_index("login")
end)

windower.register_event('logout', function()
    my_index = nil  -- 前のキャラの窓番号を次のログインに持ち越さない
end)

windower.register_event('unload', function()
    clear_binds()  -- 居なくなった WC を呼ぶ bind を残さない
end)
