# kanagawa-paper-canvas fish theme, derived from the terminal palette in
# dotfiles/wezterm/themes.lua. Palette upstream: https://github.com/thesimonho/kanagawa-paper.nvim
set -l foreground 73787d
set -l selection d4cdd4
set -l comment 99958a
set -l red c27672
set -l orange b29f71
set -l yellow a7956a
set -l green 7b958e
set -l purple 9e7e98
set -l cyan 7e8faf
set -l pink a989a3

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
