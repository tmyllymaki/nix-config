# Ensure /run/wrappers/bin (setuid wrappers for sudo, su, etc.) is always
# first in PATH, regardless of what other conf.d scripts or config.fish do.
# NixOS's /etc/set-environment puts it first, but fish's NIX_PROFILES
# handling, fish_add_path calls, and tooling like mise/fnm can reorder PATH.
if test -d /run/wrappers/bin
    if not string match -q "/run/wrappers/bin*" $PATH
        fish_add_path --prepend /run/wrappers/bin
    else if test (string split " " $PATH)[1] != /run/wrappers/bin
        # It's in PATH but not first — fix the ordering
        set -l cleaned
        for p in $PATH
            if test "$p" != /run/wrappers/bin
                set -a cleaned $p
            end
        end
        set -gx PATH /run/wrappers/bin $cleaned
    end
end
