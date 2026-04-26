{
  config,
  lib,
  pkgs,
  ...
}: let
  dotnet-combined =
    (with pkgs.dotnetCorePackages;
      combinePackages [
        sdk_8_0
        sdk_7_0
      ])
    .overrideAttrs (finalAttrs: previousAttrs: {
      # This is needed to install workload in $HOME
      # https://discourse.nixos.org/t/dotnet-maui-workload/20370/2

      postBuild =
        (previousAttrs.postBuild or '''')
        + ''

          for i in $out/sdk/*
          do
            i=$(basename $i)
            mkdir -p $out/metadata/workloads/''${i/-*}
            touch $out/metadata/workloads/''${i/-*}/userlocal
          done
        '';
    });
in {
  environment.sessionVariables = {
    DOTNET_ROOT = "${dotnet-combined}";
    LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${lib.makeLibraryPath [pkgs.icu]}";
    ASPNETCORE_ENVIRONMENT = "Development";
  };
  environment.systemPackages = [
    dotnet-combined
  ];
}
