# NixOS Configuration — Agent Guide

## Project Overview

flake-parts based NixOS + nix-darwin config using **hjem** for user-level management. Any `.nix` file under `modules/`, `machines/`, or `packages/` (not prefixed `_`) is auto-discovered via `lib.fileset` in `flake.nix`.

## CRITICAL: Git File Tracking

New files **must** be `git add`ed before building — Nix flakes only see git-tracked files in dirty trees. The file will exist on disk but be invisible to Nix.

```
git add modules/home/atuin.nix
git status          # verify staged
nh os switch -H desktop
```

## Repository Layout

```
modules/
  nixos/       system-level NixOS modules (base, desktop, gaming, synology)
  home/        user-level hjem modules (base, desktop, atuin)
  darwin/      darwin modules (defaults, homebrew, shell)
  helpers/     quickenable meta-toggle system
  shell/       shell tool modules (git)
  options/     flake option declarations
machines/
  desktop/     NixOS (x86_64-linux) machine
    configuration.nix   system config + quickenable list
    home/user.nix       user definition + hjem config
    default.nix         flake output wiring
  laptop/      nix-darwin (aarch64-darwin) machine
packages/      custom package definitions
lib/           shared variables
```

## Module Architecture — Two Tracks

| Track | Registration | Option Pattern | Enable Mechanism |
|-------|-------------|----------------|------------------|
| System (NixOS) | `flake.nixosModules.<name>` | `options.custom.system.<name>.enable` | `custom.quickenable.system.modules` in `configuration.nix` |
| System (darwin) | `flake.darwinModules.<name>` | same | same in darwin `configuration.nix` |
| User (hjem) | `flake.hjemModules.<name>` | `options.custom.home.<name>.enable` | `custom.quickenable.hjem.modules` in `home/user.nix` |

The `quickenable` helper (in `modules/helpers/quickenable.nix`) translates a list of module names into `enable = true` toggles. **Do not** import `quickenable.nix` directly in machine configs — it's auto-discovered.

## Creating a New hjem Module

Place in `modules/home/<name>.nix`:

```nix
{
  flake.hjemModules.<name> = { config, lib, pkgs, ... }: {
    options.custom.home.<name>.enable = lib.mkEnableOption "home.<name>";
    config = lib.mkIf config.custom.home.<name>.enable {
      packages = [ pkgs.<pkg> ];
      # xdg.config.files uses one of:
      #   text      — inline string content
      #   source    — path to file (with optional clobber = true)
      #   generator + value — struct -> file via formatter (lib.generators.toGitINI, pkgs.formats.json {})
    };
  };
}
```

Enable it in `machines/desktop/home/user.nix`:
```
custom.quickenable.hjem.modules = [ ... "<name>" ];
```

Remember: **git add** the new file. hjem does **not** use `programs.*` (that's home-manager). Use `packages`, `files`, `xdg.config.files`, and `environment.sessionVariables` instead.

## Creating a New NixOS Module

Place in `modules/nixos/<name>.nix`:

```nix
{
  flake.nixosModules.<name> = { config, inputs, lib, pkgs, extras, ... }: {
    options.custom.system.<name>.enable = lib.mkEnableOption "system.<name>";
    config = lib.mkIf config.custom.system.<name>.enable {
      # Standard NixOS options: nix.*, programs.*, services.*, hardware.*, etc.
    };
  };
}
```

Enable it in `machines/desktop/configuration.nix`:
```
custom.quickenable.system.modules = [ ... "<name>" ];
```

## Searching for Options

- **NixOS options:** `nixos-option programs.fish`, or browse `nixpkgs/nixos/modules/` on GitHub
- **hjem options:** `nix eval nixpkgs#hjem.packages.x86_64-linux.default` won't help — check `github:feel-co/hjem` source
- **Available packages:** `nix search nixpkgs <term>` or `search.nixos.org`
- **Nixpkgs generators:** `lib.generators` has `toGitINI`, `toJSON`, etc.

## Build & Switch Commands

| Command | Purpose |
|---------|---------|
| `nh os switch -H desktop` | Build and switch NixOS desktop |
| `sudo nixos-rebuild switch --flake .#desktop` | Direct rebuild |
| `nix build '.#nixosConfigurations.desktop.config.system.build.toplevel'` | Build only (no switch) |
| `nh darwin switch . -H work` | Build and switch a Mac (or `-H laptop`) |

## Common Pitfalls Checklist

- [ ] New file not `git add`ed
- [ ] Using `programs.*` in hjem (not available — use `packages` + `xdg.config.files`)
- [ ] Importing `quickenable.nix` directly in a machine config (it's auto-discovered)
- [ ] Setting `custom.home.*` at the NixOS level (only valid inside hjem modules)
- [ ] Forgetting `lib.mkIf` on config blocks
- [ ] Relative paths in `let` bindings — relative to the file, not the flake root

## Machine Config File Reference

| File | Purpose |
|------|---------|
| `machines/<name>/configuration.nix` | NixOS-level config + quickenable system modules |
| `machines/<name>/home/user.nix` | User definition + hjem config + quickenable hjem modules |
| `machines/<name>/default.nix` | Flake output wiring (`nixosSystem`, `hjem.extraModules`) |
| `machines/<name>/_hardware-configuration.nix` | Auto-generated hardware config (gitignored pattern) |
