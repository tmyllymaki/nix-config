# Ensure nix paths are present regardless of terminal emulator.
# nix-darwin's fish foreign-env integration produces empty shellInit/loginShellInit
# files, so /etc/fish/config.fish never sources the nix set-environment script.
# This ensures packages from system, per-user, and user profiles are on PATH.
if not contains /run/current-system/sw/bin $fish_user_paths
    fish_add_path /run/current-system/sw/bin
end
if not contains /etc/profiles/per-user/$USER/bin $fish_user_paths
    fish_add_path /etc/profiles/per-user/$USER/bin
end
if test -d $HOME/.nix-profile/bin; and not contains $HOME/.nix-profile/bin $fish_user_paths
    fish_add_path $HOME/.nix-profile/bin
end
