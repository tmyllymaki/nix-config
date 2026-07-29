{
  flake.hjemModules.base = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs.stdenv) isLinux isDarwin;
  in {
    options.custom.home.base.enable = lib.mkEnableOption "home.base";

    config = lib.mkIf config.custom.home.base.enable {
      packages = with pkgs;
        [
          atuin
          eza
          fd
          fish
          fzf
          jujutsu
          neovim
          tree-sitter
          ripgrep
          yazi
          zoxide
          gh
          glow
          lsd
          gcc
          bun
          nodejs
          zathura
          bat
          jq
          direnv
          starship
        ]
        ++ lib.optionals isLinux [xclip];

      environment.sessionVariables = {
        BROWSER = "zen-browser";
        EDITOR = "nvim";
        VISUAL = "nvim";
        DOTNET_CLI_TELEMETRY_OPTOUT = "1";
        CARGO_NET_GIT_FETCH_WITH_CLI = "true";
        GIT_MERGE_AUTOEDIT = "no";
        NEXT_TELEMETRY_DISABLED = "1";
        NPM_CONFIG_PREFIX = "$HOME/.npm-packages";
        NPM_CONFIG_CACHE = "$HOME/.cache/npm";
        PATH = "$HOME/.npm-packages/bin:$PATH";
      };

      files = {
        ".npmrc".text = ''
          prefix=''${HOME}/.npm-packages
          cache=''${HOME}/.cache/npm
        '';
        ".ssh/config".text = ''
          Host *
            IdentityAgent ~/.1password/agent.sock
        '';
      };
    };
  };
}
