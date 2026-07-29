function fv
    set -l file (fd --type file | fzf --preview 'bat --color=always {}')
    and nvim $file
end
