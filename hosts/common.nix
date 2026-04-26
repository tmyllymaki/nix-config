{pkgs, ...}: {
  imports = [
    # ../programs/zsh/zsh.nix
    # ../programs/git.nix
    # ../programs/emacs/emacs.nix
    # ../programs/vscode.nix
  ];

  nixpkgs = {
    # You can add overlays here
    #overlays = [ # Add overlays your own flake exports (from overlays and pkgs dir):
    #      outputs.overlays.additions

    # You can also add overlays exported from other flakes:
    # neovim-nightly-overlay.overlays.default

    # Or define it inline, for example:
    # (final: prev: {
    #   hi = final.hello.overrideAttrs (oldAttrs: {
    #     patches = [ ./change-hello-to-hi.patch ];
    #   });
    # })
    #];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    stateVersion = "23.11";
    packages = with pkgs; [
      alejandra
      gnumake
      htop
      jq
      ripgrep
      tree
      unzip
      vim
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {enable = true;};
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
