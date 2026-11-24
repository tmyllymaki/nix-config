# mitchell fish theme (Dracula-derived), from the fish_config theme gallery.
# The gallery publishes themes in the pre-4.3 format using `set -U` (universal)
# variables. Fish 4.3 moved theme variables to global scope, and the globals in
# conf.d/fish_frozen_theme.fish shadow universal ones, so that format no longer
# has any effect. Converted to `set -g` to match the other themes here.
set -l foreground F8F8F2
set -l selection 44475A
set -l comment 6272A4
set -l red FF5555
set -l yellow F1FA8C
set -l green 50FA7B
set -l purple BD93F9
set -l cyan 8BE9FD
set -l pink FF79C6

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $foreground
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $cyan
set -g fish_color_end $green
set -g fish_color_error $red
set -g fish_color_param 5FFFFF
set -g fish_color_option 5FFFFF
set -g fish_color_comment $comment
set -g fish_color_selection white --bold --background=$selection
set -g fish_color_search_match bryellow --background=$selection
set -g fish_color_operator 00a6b2
set -g fish_color_escape 00a6b2
set -g fish_color_autosuggestion $purple
set -g fish_color_cwd green
set -g fish_color_cwd_root red
set -g fish_color_valid_path --underline
set -g fish_color_user brgreen
set -g fish_color_host normal

# Completion Pager Colors
set -g fish_pager_color_progress brwhite --background=cyan
set -g fish_pager_color_prefix white --bold --underline
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description B3A06D yellow
set -g fish_pager_color_selected_background --background=$selection
