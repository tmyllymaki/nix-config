# Toggle the focused window's column between its width and the full
# display, like niri's maximize-column. dinky's own fullscreen ends when
# focus moves; a resized column keeps its width.
#
# State: one file per window holding "<original width> <maximized width>".
# A window counts as maximized only while it still has the maximized width,
# so a manual resize afterwards starts a fresh toggle.

state_dir="${TMPDIR:-/tmp}/dinky-maximize"
mkdir -p "$state_dir"

# Width of the focused window's planned frame: [x, y, width, height].
width() {
  dinky debug-state | jq -r '
    .focused as $id
    | .trees[] | .expected[$id | tostring] // empty | .[2]'
}

id=$(dinky debug-state | jq -r '.focused')
current=$(width)
[ -n "$current" ] || exit 0 # floating or no window

state="$state_dir/$id"
if [ -f "$state" ]; then
  read -r original maximized < "$state"
  rm -f "$state"
  if [ "$current" -eq "$maximized" ]; then
    dinky resize width "-$((current - original))"
    exit 0
  fi
fi

# dinky caps the width at the display, so overshoot.
dinky resize width +10000
new=$(width)
# Already full width: nothing to restore later.
[ "$new" -gt "$current" ] && echo "$current $new" > "$state"
exit 0
