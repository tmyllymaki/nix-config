# rfv - ripgrep + fzf interactive search
# Opens results in nvim (using vim alias from config)
#
# Usage: rfv [initial-query]

function rfv
    set -l reload 'reload:rg --column --color=always --smart-case {q} || :'
    set -l opener 'bash -c "if [[ \$FZF_SELECT_COUNT -eq 0 ]]; then nvim {1} +{2}; else nvim +cw -q {+f}; fi"'

    fzf --disabled --ansi --multi \
        --bind "start:$reload" --bind "change:$reload" \
        --bind "enter:become:$opener" \
        --bind "ctrl-o:execute:$opener" \
        --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
        --delimiter : \
        --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
        --preview-window '~4,+{2}+4/3,<80(up)' \
        --query "$argv"
end
