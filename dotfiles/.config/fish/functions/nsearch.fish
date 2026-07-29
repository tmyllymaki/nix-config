function nsearch --description "Search Obsidian vault contents"
    if test (count $argv) -eq 0
        echo "Usage: nsearch \"query\""
        return 1
    end
    set -l query (string join " " $argv)
    rg --color=always -l "$query" ~/projects/Obsidian/Work/ --glob '*.md'
end
