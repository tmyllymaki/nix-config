# github-light fish theme, derived from the terminal palette in
# dotfiles/wezterm/themes.lua. Palette upstream: https://github.com/projekt0n/github-nvim-theme
set -l foreground 1F2328
set -l selection bbdfff
set -l comment 57606a
set -l red cf222e
set -l orange 633c01
set -l yellow 4d2d00
set -l green 116329
set -l purple 8250df
set -l cyan 1b7c83
set -l pink a475f9

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
