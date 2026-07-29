{
  # NOTE: fish uses individual file symlinks instead of a directory symlink
  # because fisher (plugin manager) writes to functions/, completions/, and
  # conf.d/ at runtime. A directory symlink would point to the read-only nix
  # store, breaking fisher.
  flake.hjemModules.fish = {
    config,
    lib,
    pkgs,
    ...
  }: let
    fishDir = ../../dotfiles/.config/fish;
    mkSource = path: {
      clobber = true;
      source = fishDir + "/${path}";
    };
  in {
    options.custom.home.fish.enable = lib.mkEnableOption "home.fish";

    config = lib.mkIf config.custom.home.fish.enable {
      packages = with pkgs; [
        fish
        fzf
        zoxide
      ];

      xdg.config.files = {
        "fish/config.fish" = mkSource "config.fish";
        "fish/fish_plugins" = mkSource "fish_plugins";
        "fish/docker-stop-port.sh" = mkSource "docker-stop-port.sh";
        "fish/functions/_ls.fish" = mkSource "functions/_ls.fish";
        "fish/functions/capture.fish" = mkSource "functions/capture.fish";
        "fish/functions/clip.fish" = mkSource "functions/clip.fish";
        "fish/functions/envsource.fish" = mkSource "functions/envsource.fish";
        "fish/functions/fisher.fish" = mkSource "functions/fisher.fish";
        "fish/functions/fv.fish" = mkSource "functions/fv.fish";
        "fish/functions/fzf-file-widget-wrapped.fish" = mkSource "functions/fzf-file-widget-wrapped.fish";
        "fish/functions/fzf-history-widget-wrapped.fish" = mkSource "functions/fzf-history-widget-wrapped.fish";
        "fish/functions/fzf-project-widget.fish" = mkSource "functions/fzf-project-widget.fish";
        "fish/functions/fzf-vim-widget.fish" = mkSource "functions/fzf-vim-widget.fish";
        "fish/functions/groot.fish" = mkSource "functions/groot.fish";
        "fish/functions/l.fish" = mkSource "functions/l.fish";
        "fish/functions/la.fish" = mkSource "functions/la.fish";
        "fish/functions/ll.fish" = mkSource "functions/ll.fish";
        "fish/functions/llm.fish" = mkSource "functions/llm.fish";
        "fish/functions/login.fish" = mkSource "functions/login.fish";
        "fish/functions/ls.fish" = mkSource "functions/ls.fish";
        "fish/functions/lt.fish" = mkSource "functions/lt.fish";
        "fish/functions/lx.fish" = mkSource "functions/lx.fish";
        "fish/functions/nix-clean.fish" = mkSource "functions/nix-clean.fish";
        "fish/functions/nix-shell.fish" = mkSource "functions/nix-shell.fish";
        "fish/functions/nsearch.fish" = mkSource "functions/nsearch.fish";
        "fish/functions/nvk.fish" = mkSource "functions/nvk.fish";
        "fish/functions/pr.fish" = mkSource "functions/pr.fish";
        "fish/functions/refresh-shell-cache.fish" = mkSource "functions/refresh-shell-cache.fish";
        "fish/functions/rfv.fish" = mkSource "functions/rfv.fish";
        "fish/functions/stop.fish" = mkSource "functions/stop.fish";
        "fish/functions/tasks.fish" = mkSource "functions/tasks.fish";
        "fish/functions/today.fish" = mkSource "functions/today.fish";
        "fish/functions/tree.fish" = mkSource "functions/tree.fish";
        "fish/functions/tree-me.fish" = mkSource "functions/tree-me.fish";
        "fish/functions/w.fish" = mkSource "functions/w.fish";
        "fish/functions/yadm_find_new.fish" = mkSource "functions/yadm_find_new.fish";
        "fish/functions/zs.fish" = mkSource "functions/zs.fish";
        "fish/conf.d/fish-eza.fish" = mkSource "conf.d/fish-eza.fish";
        "fish/conf.d/fish_frozen_key_bindings.fish" = mkSource "conf.d/fish_frozen_key_bindings.fish";
        "fish/conf.d/fish_frozen_theme.fish" = mkSource "conf.d/fish_frozen_theme.fish";
        "fish/conf.d/fnm.fish" = mkSource "conf.d/fnm.fish";
        "fish/conf.d/rustup.fish" = mkSource "conf.d/rustup.fish";
        "fish/conf.d/uv.env.fish" = mkSource "conf.d/uv.env.fish";
        "fish/conf.d/zmx-wezterm.fish" = mkSource "conf.d/zmx-wezterm.fish";
        "fish/completions/azd.fish" = mkSource "completions/azd.fish";
        "fish/completions/docker.fish" = mkSource "completions/docker.fish";
        "fish/completions/fisher.fish" = mkSource "completions/fisher.fish";
        "fish/completions/kubectl.fish" = mkSource "completions/kubectl.fish";
        "fish/completions/orbctl.fish" = mkSource "completions/orbctl.fish";
        "fish/completions/tree-me.fish" = mkSource "completions/tree-me.fish";
        "fish/completions/w.fish" = mkSource "completions/w.fish";
        "fish/themes/carbonfox.fish" = mkSource "themes/carbonfox.fish";
        "fish/themes/dayfox.fish" = mkSource "themes/dayfox.fish";
        "fish/themes/modus_operandi.fish" = mkSource "themes/modus_operandi.fish";
        "fish/themes/modus_vivendi.fish" = mkSource "themes/modus_vivendi.fish";
        "fish/themes/tokyonight_moon.fish" = mkSource "themes/tokyonight_moon.fish";
      };

      files = {
        ".config/fish/scripts/tree-me".source = fishDir + "/scripts/tree-me";
      };
    };
  };
}
