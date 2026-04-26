{
  flake.hjemModules.base = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.base.enable = lib.mkEnableOption "home.base";

    config = lib.mkIf config.custom.home.base.enable {
      packages = with pkgs; [
        bat
        eza
        fd
        fish
        fzf
        jujutsu
        neovim
        ripgrep
        starship
        yazi
        zoxide
      ];

      environment.sessionVariables = {
        BROWSER = "zen-browser";
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      files.".ssh/config".text = ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
    };
  };
}
