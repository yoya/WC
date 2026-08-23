--- AccountList から「キャラ名 → 窓番号」の対応を作る。
--- windower に触らないので、ここだけ単体テストできる。

local M = {}

local function trim(text)
    return (string.gsub(text, "^%s*(.-)%s*$", "%1"))
end

-- Windower の string.split は libs 依存なので自前で持つ
local function split(text, sep)
    local words = {}
    for word in string.gmatch(text, "([^"..sep.."]+)") do
	table.insert(words, word)
    end
    return words
end

--- settings.AccountList を表に変換する。
---   引数: { ["1"] = "Apuapu, Apuchan", ["2"] = "Upaupa" }
---   戻り: name_to_index, indexes (昇順の配列), errors (警告文の配列)
--- 不正な入力でも表は返す。errors は呼び出し側がチャットに出す。
function M.build(account_list)
    local name_to_index = {}
    local indexes = {}
    local errors = {}
    if type(account_list) ~= 'table' then
	table.insert(errors, "AccountList がありません")
	return name_to_index, indexes, errors
    end
    for key, chara_list in pairs(account_list) do
	local index = tonumber(key)
	if index == nil or index < 1 or index ~= math.floor(index) then
	    table.insert(errors, "AccountList のキーが窓番号になっていません: "..tostring(key))
	elseif type(chara_list) ~= 'string' then
	    table.insert(errors, "AccountList<"..tostring(key).."> がキャラ名の並びではありません")
	else
	    table.insert(indexes, index)
	    for _, name in ipairs(split(chara_list, ",")) do
		local trimmed = trim(name)
		if trimmed ~= "" then
		    -- pairs の順は不定なので、重複時にどちらが残るかは決まらない。
		    -- 黙って片方を捨てず、警告して気付けるようにする
		    if name_to_index[trimmed] ~= nil and name_to_index[trimmed] ~= index then
			table.insert(errors, trimmed.." が複数の窓に登録されています: #"
					 ..name_to_index[trimmed].." と #"..index)
		    end
		    name_to_index[trimmed] = index
		end
	    end
	end
    end
    table.sort(indexes)
    return name_to_index, indexes, errors
end

--- current の次の窓番号を返す。
--- current が一覧に無いとき (nil を含む) は先頭を返す。
function M.next_index(indexes, current)
    if #indexes == 0 then
	return nil
    end
    for i, index in ipairs(indexes) do
	if index == current then
	    return indexes[(i % #indexes) + 1]
	end
    end
    return indexes[1]
end

return M
