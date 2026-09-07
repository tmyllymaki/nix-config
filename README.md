# nix-config

Nix configuration for my machines: one NixOS desktop and two Macs running
nix-darwin. A single flake builds all of them and shares as much as possible
between Linux and macOS.

| Machine   | System         | What it is                      |
|-----------|----------------|---------------------------------|
| `desktop` | x86_64-linux   | NixOS workstation (Plasma)      |
| `laptop`  | aarch64-darwin | Personal MacBook Air            |
| `work`    | aarch64-darwin | Work MacBook Pro                |

## Layout

```
flake.nix        inputs + auto-import of everything below
machines/        one directory per machine
modules/
  nixos/         NixOS system modules
  darwin/        nix-darwin system modules
  home/          user-level modules (hjem), shared by both OSes
  shell/         shell tools (git, ...)
  wm/            window manager settings
  helpers/       the quickenable toggle helper
packages/        custom packages not in nixpkgs
dotfiles/        plain config files installed by the home modules
lib/             small shared helpers
```

## How it works

**Everything is auto-imported.** The flake uses flake-parts and imports every
`.nix` file under `modules/`, `machines/` and `packages/`. Create a file and it
is picked up; no registration step. Files prefixed with `_` are ignored.

**Modules are opt-in.** Each module registers itself in one bucket and guards
its config behind an enable option:

| Bucket                      | Scope                    | Enable option                 |
|-----------------------------|--------------------------|-------------------------------|
| `flake.nixosModules.X`      | NixOS system             | `custom.system.X.enable`      |
| `flake.darwinModules.X`     | nix-darwin system        | `custom.system.X.enable`      |
| `flake.hjemModules.X`       | user files, both OSes    | `custom.home.X.enable`        |
| `flake.nixosMachineModules.X` | one machine's settings | (always applied to machine X) |

A machine turns modules on by listing their names:

```nix
custom.quickenable.system.modules = [ "base" "desktop" "gaming" ];
custom.quickenable.hjem.modules   = [ "git" "fish" "wezterm" ];
```

**User config uses hjem**, a lightweight alternative to home-manager. Home
modules install packages and write files under `~/.config`; there is no
`programs.*` layer. Because hjem runs on both NixOS and nix-darwin, the same
home modules serve every machine.

**Each machine is three files.** `machines/<name>/default.nix` wires the flake
output, `configuration.nix` holds system settings and the system module list,
and `home/user.nix` defines the user and the home module list.

## Usage

Everything is driven by [nh](https://github.com/nix-community/nh), which is
installed on every machine by the config itself.

```sh
# NixOS desktop
nh os switch -H desktop          # build and activate, make it the boot default
nh os test -H desktop            # build and activate without touching the bootloader
nh os build -H desktop           # build only

# Macs (run from the repo root; -H picks the machine)
nh darwin switch . -H work
nh darwin switch . -H laptop

nh clean all --keep 3            # garbage-collect old generations
```

`nh os` reads the flake from `NH_FLAKE`, which the NixOS base module sets to
`/etc/nixos`. On the Macs pass the flake path explicitly, or export `NH_FLAKE`
yourself.

New files must be `git add`ed before building; flakes only see tracked files.

## Adding things

- **System package on macOS:** `modules/darwin/shell.nix`. Homebrew casks: `modules/darwin/homebrew.nix`.
- **New module:** copy any file in `modules/nixos/`, `modules/darwin/` or `modules/home/`, keep the enable-option pattern, then add its name to the machine's quickenable list.
- **New machine:** copy a directory under `machines/`. Macs use `lib/mk-darwin.nix`; see `machines/desktop/default.nix` for the NixOS shape.

