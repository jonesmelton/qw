#!/bin/bash
# Map qw.lua line numbers, as crawl reports them in errors, to source file:line and show context.
qw=$(cd "$(dirname "$0")/../.." && pwd)
cd "$qw"
sizes=$( { echo source/variables.lua; find source -iname '*.lua' -not -name variables.lua | sort; } |
    while read f; do echo "$f $(wc -l < "$f")"; done )
for n in "$@"; do
    loc=$(echo "$sizes" | awk -v l=$((n - 1)) '{ if (l <= $2) { print $1 ":" l; exit } l -= $2 }')
    f=${loc%%:*}; l=${loc##*:}
    echo "== $loc"; sed -n "$((l - 3)),$((l + 2))p" "$f"
done
