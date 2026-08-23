-- focus.build / focus.next_index

package.path = package.path .. ";../?.lua"
local focus = require 'focus'

local function assert_equal(actual, expected, message)
    if actual ~= expected then
	error(("%s: expected %s, got %s"):format(
		  message, tostring(expected), tostring(actual)), 2)
    end
end

-- 素直な入力。キーは XML 由来なので文字列で来る
local name_to_index, indexes, errors = focus.build({
    ["1"] = "Apuapu, Apuchan",
    ["2"] = " Upaupa ",
})
assert_equal(name_to_index["Apuapu"], 1, "1 番目のキャラ")
assert_equal(name_to_index["Apuchan"], 1, "同じ窓の 2 キャラ目")
assert_equal(name_to_index["Upaupa"], 2, "前後の空白は落とす")
assert_equal(#indexes, 2, "窓の数")
assert_equal(indexes[1], 1, "窓番号は昇順")
assert_equal(indexes[2], 2, "窓番号は昇順")
assert_equal(#errors, 0, "警告なし")

-- キーが数値で来ても良い
local by_number = focus.build({ [3] = "Paupau" })
assert_equal(by_number["Paupau"], 3, "数値キー")

-- 窓番号になっていないキーは飛ばして警告する
local _, bad_indexes, bad_errors = focus.build({ ["x"] = "Nanashi" })
assert_equal(#bad_indexes, 0, "不正なキーの窓は作らない")
assert_equal(#bad_errors, 1, "不正なキーを警告する")

-- 同じ名前が 2 つの窓にあると、どちらが残るかは pairs 次第。必ず警告する
local _, _, dup_errors = focus.build({ ["1"] = "Apuapu", ["2"] = "Apuapu" })
assert_equal(#dup_errors, 1, "重複を警告する")

-- AccountList が無い
local _, none_indexes, none_errors = focus.build(nil)
assert_equal(#none_indexes, 0, "窓なし")
assert_equal(#none_errors, 1, "AccountList 無しを警告する")

-- next_index は一周する
local ring = { 1, 2, 4 }
assert_equal(focus.next_index(ring, 1), 2, "次の窓")
assert_equal(focus.next_index(ring, 2), 4, "番号が飛んでいても次")
assert_equal(focus.next_index(ring, 4), 1, "最後から先頭へ")
-- AccountList に無いキャラ (my_index == nil) は先頭へ
assert_equal(focus.next_index(ring, nil), 1, "自分の窓が不明なら先頭")
assert_equal(focus.next_index(ring, 9), 1, "一覧に無い番号なら先頭")
assert_equal(focus.next_index({}, nil), nil, "窓が無ければ nil")
assert_equal(focus.next_index({ 1 }, 1), 1, "1 窓だけなら自分")

print("focus_test: ok")
