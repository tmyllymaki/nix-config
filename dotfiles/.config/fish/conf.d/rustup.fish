# Binaries from `cargo install`. Nix's rustup does not write ~/.cargo/env.fish,
# so add the directory directly instead of sourcing that file.
if test -d "$HOME/.cargo/bin"
    fish_add_path "$HOME/.cargo/bin"
end
