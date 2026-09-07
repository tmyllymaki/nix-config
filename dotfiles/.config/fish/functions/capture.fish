function capture --description "Append a task to Obsidian Tasks.md"
    if test (count $argv) -eq 0
        echo "Usage: capture \"task description\""
        return 1
    end
    set -l text (string join " " $argv)
    echo "- [ ] $text" >> $OBSIDIAN_VAULT/Tasks.md
    echo "Captured: $text"
end
