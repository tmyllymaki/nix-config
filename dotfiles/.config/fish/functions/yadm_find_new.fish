function yadm_find_new --description "Stages all changes within tracked subdirectories"
    echo "Searching for tracked directories to update..."
    set tracked_dirs (yadm ls-files | xargs -n1 dirname | sort -u)

    for dir in $tracked_dirs
        if test "$dir" = "."
            echo "-> Skipping root directory (.). Add files in ~ manually with 'yadm add <file>'."
        else
            echo "-> Staging all changes in '$dir'..."
            yadm add $dir
        end
    end

    echo ""
    echo "✅ Update complete. Review staged changes with 'yadm status'."
end
