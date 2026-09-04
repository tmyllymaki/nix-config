
  How the config works

  The entry point: flake.nix

  The flake uses flake-parts to avoid writing outputs by hand. The key mechanism is
  import-tree - it recursively finds every .nix file under modules/, machines/, and
  packages/, and imports them all as flake-parts modules. This means you never need to
  manually register a new file - just create it and it's picked up.

  imports = lib.flatten [
    (import-tree ./modules)
    (import-tree ./machines)
    (import-tree ./packages)
  ];

  Files prefixed with _ are ignored (useful for drafts or notes).

  mkExtras is a helper that bundles things not available through normal pkgs - like
  neovim-nightly from an overlay and your custom packages. It's passed to every module via
  specialArgs.

  Three module types

  Every module registers itself into one of three buckets:

  ┌─────────────────────────────┬───────────────────────────────────┬───────────────────────
  ────────────────────────────────────────────────────────────┐
  │           Bucket            │              Set by               │
                 Purpose                                      │
  ├─────────────────────────────┼───────────────────────────────────┼───────────────────────
  ────────────────────────────────────────────────────────────┤
  │ flake.darwinModules.X       │ darwin-specific system modules    │ Homebrew, macOS
  defaults, system packages, OmniWM daemon                          │
  ├─────────────────────────────┼───────────────────────────────────┼───────────────────────
  ────────────────────────────────────────────────────────────┤
  │ flake.hjemModules.X         │ user-level home config (portable) │ Git config, OmniWM
  settings - works on both darwin and NixOS                      │
  ├─────────────────────────────┼───────────────────────────────────┼───────────────────────
  ────────────────────────────────────────────────────────────┤
  │ flake.nixosMachineModules.X │ per-machine config                │ What makes your
  machine yours - nix settings, which modules to enable, user setup │
  └─────────────────────────────┴───────────────────────────────────┴───────────────────────
  ────────────────────────────────────────────────────────────┘

  modules/all.nix creates an aggregator for each bucket (darwinModules.all, hjemModules.all)
   that imports every module of that type. This way the machine's default.nix can pull in
  everything with one line.

  The enable pattern

  Each module guards its config behind an option like custom.system.shell.enable or
  custom.home.git.enable. Nothing activates until a machine explicitly enables it.

  The quickenable helper is syntactic sugar. Instead of:

  custom.system.homebrew.enable = true;
  custom.system.defaults.enable = true;
  custom.system.shell.enable = true;
  custom.system.omniwm.enable = true;

  You write:

  custom.quickenable.system.modules = [
    "homebrew" "defaults" "shell" "omniwm"
  ];

  Same for hjem modules: custom.quickenable.hjem.modules = ["git" "omniwm"];

  How a machine is assembled

  machines/personal/default.nix is where everything gets wired together:

  darwinSystem {
    modules = [
      darwinModules.all      # All system modules (gated by enable flags)
      hjemModules.all        # All hjem modules (also gated)
      nixosMachineModules.personal  # YOUR machine's config that flips those flags
      hjem.darwinModules.default    # hjem's own plumbing
      nix-homebrew.darwinModules.nix-homebrew  # nix-homebrew plumbing
    ];
  }

  The machine-specific config is split across two files that both contribute to
  nixosMachineModules.personal (they merge automatically):

  - configuration.nix - System-level: nix settings, TouchID, homebrew taps, which modules to
   enable
  - home/user.nix - User-level: creates the tm user, sets up hjem, picks which hjem modules
  to enable, user packages

  Hjem

  Hjem is a simpler alternative to home-manager. It manages user-level config files through
  xdg.config.files. For example, the git module writes ~/.config/git/config:

  xdg.config.files."git/config" = {
    generator = lib.generators.toGitINI;
    value = { user.name = "tmyllymaki"; ... };
  };

  The OmniWM hjem modules work the same way - each file (appearance.nix, binds.nix, etc.)
  adds keys to xdg.config.files."omniwm/settings.json".value, and they all merge into one
  JSON file. Hjem works on both darwin and NixOS, so these modules are portable.

  Adding something new

  - New system package: add it to the list in modules/darwin/shell.nix
  - New homebrew cask/brew: add it to modules/darwin/homebrew.nix
  - New darwin module: create modules/whatever/thing.nix, set flake.darwinModules.thing =
  ... with an enable option, then add "thing" to your machine's quickenable list
  - New hjem module: same pattern but flake.hjemModules.thing and custom.home.thing.enable
  - New NixOS machine: create machines/mybox/ following the same three-file pattern, using
  nixosSystem instead of darwinSystem, and import nixosModules.all instead of
  darwinModules.all

  Secrets and machine-local values

  This repo is public. Nothing in it may contain a credential, and client or employer
  identifiers stay out of it too. The conventions:

  - Runtime secrets (API tokens, database passwords) are read from 1Password at the moment
  they are needed, via `op read op://...`. See dotfiles/doom/config.el for the pattern.
  - Shell-level secrets live in ~/.config/fish/secrets.fish, which is sourced if present
  and is not tracked.
  - Per-machine wezterm values (issue-tracker hyperlink rules, per-project tab layouts)
  live in ~/.config/wezterm-local.lua, which wezterm.lua loads if present. The file returns
  a table; see the comment near the top of dotfiles/wezterm/wezterm.lua for its shape.
  - User login passwords are not in the config. users.mutableUsers is left at its default,
  so after a fresh install set the password once with `passwd <user>` (from the installer
  via `nixos-enter --root /mnt -c 'passwd tm'`, or as root on a console). It then persists
  across rebuilds.
  - If a system-level secret is ever needed at activation time, add agenix or sops-nix
  rather than committing the value.
