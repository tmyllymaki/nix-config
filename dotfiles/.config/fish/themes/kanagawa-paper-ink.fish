# kanagawa-paper-ink fish theme, derived from the terminal palette in
# dotfiles/wezterm/themes.lua. Palette upstream: https://github.com/thesimonho/kanagawa-paper.nvim
set -l foreground DCD7BA
set -l selection 363646
set -l comment aca9a4
set -l red c4746e
set -l orange d4c196
set -l yellow c4b28a
set -l green 699469
set -l purple a292a3
set -l cyan 8ea49e
set -l pink b4a7b5

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
