# Ensure nix paths are present on nix-darwin (macOS).
# NixOS handles this correctly via /etc/set-environment and /run/wrappers/bin.
# On darwin, fish's foreign-env integration produces empty shellInit/loginShellInit
# files, so /etc/fish/config.fish never sources the nix set-environment script.
if test (uname) = Darwin
    if not contains /run/current-system/sw/bin $fish_user_paths
        fish_add_path /run/current-system/sw/bin
    end
    if not contains /etc/profiles/per-user/$USER/bin $fish_user_paths
        fish_add_path /etc/profiles/per-user/$USER/bin
    end
    if test -d $HOME/.nix-profile/bin; and not contains $HOME/.nix-profile/bin $fish_user_paths
        fish_add_path $HOME/.nix-profile/bin
    end
end
