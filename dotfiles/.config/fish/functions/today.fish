function today --description "Open today's daily note"
    set -l date_str (date +%Y-%m-%d)
    set -l note $OBSIDIAN_VAULT/Daily/$date_str.md
    if not test -f $note
        cp $OBSIDIAN_VAULT/Templates/Daily.md $note 2>/dev/null; or touch $note
    end
    $EDITOR $note
end
