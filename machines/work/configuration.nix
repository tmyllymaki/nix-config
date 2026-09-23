{
  flake.nixosMachineModules.work = {
    custom.user.name = "tmyllymaki";

    custom.system.homebrew.extraBrews = [
      "colima"
      "container"
      "container-compose"
      "docker"
      "docker-compose"
      "docker-credential-helper"
    ];

    custom.system.homebrew.extraCasks = [
      "google-chrome"
      "microsoft-teams"
      "logi-options+"
      "linear"
      "omniwm"
      "claude"
      "microsoft-excel"
    ];

    # Enable system modules
    custom.quickenable.system.modules = [
      "base"
      "homebrew"
      "defaults"
      "shell"
      "paneru"
    ];
  };
}
