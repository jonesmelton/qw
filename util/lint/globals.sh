#!/bin/bash
# List globals read by qw that it never assigns, excluding Lua std names.
# Needs a Lua built from the same crawl tag: LUA_DIR (default: qwe's build).
set -eo pipefail
lint=$(cd "$(dirname "$0")" && pwd)
qw=$(cd "$lint/../.." && pwd)
lua_dir=${LUA_DIR:-$HOME/code/qwe/build/lua-0.34.1}
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cd "$qw" && ./make-qw.sh -o "$tmp/qw.lua" >/dev/null
sed -e '1d' -e '$d' "$tmp/qw.lua" > "$tmp/body.lua"
"$lua_dir/luac" -l -l -p "$tmp/body.lua" > "$tmp/listing"
awk -f "$lint/envaccess.awk" "$tmp/listing" > "$tmp/access"
{ awk '$1=="set"{print $2}' "$tmp/access"; "$lua_dir/lua" "$lint/defs.lua" "$tmp/body.lua"; } | sort -u > "$tmp/sets"
awk '$1=="get"{print $2}' "$tmp/access" | sort -u > "$tmp/gets"
"$lua_dir/lua" -e 'for k in pairs(_G) do print(k) end' | sort -u > "$tmp/std"
grep -E '^: *[A-Z_]+ *=' qw.rc | sed -E 's/^: *([A-Z_]+).*/\1/' | sort -u > "$tmp/rcvars"
cat "$tmp/sets" "$tmp/std" "$tmp/rcvars" | sort -u | comm -23 "$tmp/gets" -
