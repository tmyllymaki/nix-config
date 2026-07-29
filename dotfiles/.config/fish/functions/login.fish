function login --description "Select a 1Password item via fzf and open it in browser"
    set -l selected (op item list --categories login --format json | jq -r '.[].title' | fzf --height 40% --layout reverse | xargs op item get --format=json | jq -r '.id, .urls[0].href')
    if test -z "$selected"
        commandline -f repaint
        return
    end
    set -l id $selected[1]
    set -l url $selected[2]
    if string match -e -- '\?' "$url"
        set -f fill_session_url "$url&$id=$id"
    else
        set -f fill_session_url "$url?$id=$id"
    end
    if test (uname) = Darwin
        open "$fill_session_url"
    else
        xdg-open "$fill_session_url"
    end
end
