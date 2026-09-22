# kanso-ink fish theme, derived from the terminal palette in
# dotfiles/wezterm/themes.lua. Palette upstream: https://github.com/webhooked/kanso.nvim
set -l foreground C5C9C7
set -l selection 393B44
set -l comment A4A7A4
set -l red C4746E
set -l orange E6C384
set -l yellow C4B28A
set -l green 8A9A7B
set -l purple A292A3
set -l cyan 8EA4A2
set -l pink 938AA9

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment
set -g fish_color_option $purple

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment
set -g fish_pager_color_selected_background --background=$selection
