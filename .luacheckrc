-- luacheck 設定 (Windower4 addon "WC")
--
--   $ luacheck .
--
-- Windower4 は Lua 5.1 (LuaJIT) 相当。

std = "lua51+windower"

stds.windower = {
    read_globals = {
	windower = { other_fields = true },
	_libs    = { other_fields = true },
	-- Windower の libs が標準ライブラリに生やす拡張メソッド
	string    = { fields = { "color" } },
	coroutine = { fields = { "sleep", "schedule" } },
    },
}

globals = {
    "_addon",  -- addon メタ情報 (WC.lua)
}

-- グローバル関数は定義しない。ここに名前を足さないこと
max_line_length = false

files["tests/"] = {
    std = "lua51",
    allow_defined_top = true,
}
