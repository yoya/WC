-- テストランナー
--
--   $ cd tests && lua run.lua
--
-- windower に触るコード (WC.lua) はここでは動かせない。
-- 走らせられるのは focus.lua だけ。

package.path = package.path .. ";../?.lua"

local tests = {
    "focus_test.lua",
}

local ok_count, ng_count = 0, 0
local failed = {}

for _, name in ipairs(tests) do
    print(("[RUN ] %s"):format(name))
    local ok, err = pcall(dofile, name)
    if ok then
	print(("[ OK ] %s"):format(name))
	ok_count = ok_count + 1
    else
	print(("[FAIL] %s: %s"):format(name, tostring(err)))
	ng_count = ng_count + 1
	table.insert(failed, name)
    end
end

print(("=== %d ok / %d failed"):format(ok_count, ng_count))
for _, name in ipairs(failed) do
    print("  failed: " .. name)
end
os.exit(ng_count == 0 and 0 or 1)
