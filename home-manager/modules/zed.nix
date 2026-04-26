{pkgs, ...}: let
  zed-fhs = pkgs.buildFHSUserEnv {
    name = "zed";
    targetPkgs = pkgs:
      with pkgs; [
        zed-editor
        nixd
      ];
    runScript = "zed";
  };
in {
  home.packages = [
    zed-fhs
  ];
}
