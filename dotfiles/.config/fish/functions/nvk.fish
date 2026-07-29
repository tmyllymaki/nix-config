# nvk - pick running nvim sessions by working directory and kill them
#
# Tab: toggle selection  |  Enter: kill selected  |  Esc: cancel

function nvk --description "Pick and kill running nvim sessions"
    set -l pids (pgrep -x nvim)
    if test -z "$pids"
        echo "No nvim processes running."
        return 0
    end

    set -l tab (printf '\t')

    # Collect "pid<TAB>cwd" for each nvim process
    set -l lines
    for pid in $pids
        set -l cwd (lsof -p $pid 2>/dev/null | awk '$4=="cwd" {print $NF; exit}')
        test -n "$cwd"; and set lines $lines "$pid$tab$cwd"
    end

    if test -z "$lines"
        echo "Could not determine cwd for any nvim process."
        return 1
    end

    # Group PIDs that share the same cwd into one row (nvim spawns a child)
    set -l grouped (
        printf "%s\n" $lines \
        | awk -F'\t' '{
            if ($2 in g) g[$2] = g[$2] "," $1; else g[$2] = $1
          } END {
            for (cwd in g) printf "%s\t%s\n", g[cwd], cwd
          }' \
        | sort -k2
    )

    set -l picked (
        printf "%s\n" $grouped \
        | fzf --multi \
              --delimiter=\t \
              --with-nth=2.. \
              --prompt="kill nvim> " \
              --header="Tab: select  Enter: kill  Esc: cancel"
    )
    or return 130

    test -z "$picked"; and return 130

    for line in $picked
        set -l parts (string split -m1 $tab -- $line)
        set -l pidlist $parts[1]
        set -l cwd $parts[2]
        for pid in (string split , -- $pidlist)
            if kill $pid 2>/dev/null
                echo "Killed PID $pid ($cwd)"
            end
        end
    end
end
