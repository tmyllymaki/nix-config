{
  flake.hjemModules.llm-agents = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: let
    llmPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    options.custom.home.llm-agents.enable = lib.mkEnableOption "home.llm-agents";

    config = lib.mkIf config.custom.home.llm-agents.enable {
      packages = [
        llmPkgs.claude-code
        llmPkgs.opencode
        llmPkgs.pi
        llmPkgs.claude-code
      ];
    };
  };
}
