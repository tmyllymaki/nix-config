# kanso-pearl fish theme, derived from the terminal palette in
# dotfiles/wezterm/themes.lua. Palette upstream: https://github.com/webhooked/kanso.nvim
set -l foreground 22262D
set -l selection E2E1DF
set -l comment 6d6f6e
set -l red c84053
set -l orange 836f4a
set -l yellow 77713f
set -l green 6f894e
set -l purple b35b79
set -l cyan 597b75
set -l pink 624c83

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
