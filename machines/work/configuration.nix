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
      "firefox"
      "google-chrome"
      "microsoft-teams"
      "logi-options+"
      "linear"
      "mikker/tap/dinky"
      "claude"
      "microsoft-excel"
      "kitty"
      "d12frosted/emacs-plus/emacs-plus-app"
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
