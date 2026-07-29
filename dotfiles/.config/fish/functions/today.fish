function today --description "Open today's daily note"
    set -l date_str (date +%Y-%m-%d)
    set -l note ~/projects/Obsidian/Work/Daily/$date_str.md
    if not test -f $note
        cp ~/projects/Obsidian/Work/Templates/Daily.md $note
    end
    $EDITOR $note
end
