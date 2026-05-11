# PenguinBurner on NixOS — Integration Notes

## What Works

- Package builds and installs successfully (`packages/penguin-burner.nix`)
- GUI launches, detects GPU (RTX 3080), reads V/F curves
- NVIDIA libraries accessible via `LD_LIBRARY_PATH` wrapper
- Polkit authentication agent works (lxqt-policykit-agent)

## What Doesn't Work

**Auto-UV scan** fails because the prebuilt Q2RTX binary cannot create an SDL Vulkan window in any headless mode.

## Root Cause

The Q2RTX binary bundled by PenguinBurner (from NVIDIA RTX Remix) has **SDL2 compiled with only `offscreen` and `kmsdrm` backends**. It lacks `x11` and `wayland` support.

```
$ strings q2rtx | grep -E '^(x11|wayland|offscreen|kmsdrm)$'
offscreen
kmsdrm
```

### Why Both Headless Paths Fail

| Path | Mechanism | Why It Breaks |
|------|-----------|---------------|
| `gamescope --backend headless` | Creates virtual Wayland/X11 compositor, spawns Q2RTX inside | Q2RTX's SDL2 has no Wayland backend → falls back to `offscreen` → no Vulkan window |
| Offscreen X11 fallback | `SDL_VIDEODRIVER=x11 DISPLAY=:0` (user's Xwayland) | Q2RTX's SDL2 has no X11 backend + `pkexec`-based user switching breaks X11 socket auth |

## Fixes Applied (to the Nix package)

### `packages/penguin-burner.nix`

1. **`SDL_DYNAMIC_API` override** — Q2RTX's statically-linked SDL2 uses SDL's dynamic API dispatch mechanism. Setting `SDL_DYNAMIC_API` env var to nixpkgs SDL2 (`sdl2-compat` → SDL3) replaces the entire dispatch table at runtime. nixpkgs SDL2 provides wayland/x11 backends (via SDL3) that the prebuilt binary lacks. Added via `makeWrapperArgs --set`.

2. **`LD_LIBRARY_PATH` forwarding** — `ui/commands.py` patched to include `LD_LIBRARY_PATH` in env vars forwarded through `pkexec`. Wrapper adds `/run/opengl-driver/lib` + Q2RTX runtime deps (libidn2, libpsl, vulkan-loader, openssl_1_1, libstdc++).

3. **`WAYLAND_DISPLAY` removal** — Removed from forwarded env vars because it conflicts with gamescope's internal display setup.

4. **`SDL_DYNAMIC_API` pkexec forwarding** — Added to forwarded env vars in `ui/commands.py` so the override survives any pkexec re-exec boundary.

### System config changes

- `modules/nixos/base.nix`: `programs.nix-ld.enable = true` — allows FHS binaries to find dynamic linker
- `modules/nixos/gaming.nix`: Added `extras.mypkgs.penguin-burner` to `environment.systemPackages`
- `modules/home/desktop.nix`: Added `lxqt.lxqt-policykit` for polkit auth agent
- `machines/desktop/home/files/niri/config.kdl`: Added `spawn-at-startup "lxqt-policykit-agent"`
- `flake.nix`: Added `openssl-1.1.1w` to `permittedInsecurePackages`

## Possible Solutions (untested)

### 1. Build Q2RTX from source with X11/Wayland SDL2
Package Q2RTX (RTX Remix Quake II) in Nix with SDL2 compiled with X11 backend. Then point PenguinBurner at the Nix-built version.

### 2. Provide an LD_PRELOAD shim
Use `libSDL2` from nixpkgs (which has X11 support) via `LD_PRELOAD` to override the statically-linked SDL symbols. Likely won't work with static linking.

### 3. Run the scan on the visible display
Patch PenguinBurner to skip headless rendering entirely and create a visible window on the user's desktop. The `hide_window` flag in Q2RTX stability config controls this.

### 4. Use a separate Xvfb display
Start Xvfb on a virtual display, set `DISPLAY`, and run Q2RTX directly (needs SDL X11 backend — same fundamental issue).

### 5. Q2RTX from LACT
LACT (a similar project) might have a Q2RTX build with broader SDL backend support. Check if compatible.

## Key Files

- `packages/penguin-burner.nix` — Nix package derivation with patches
- `modules/nixos/gaming.nix` — system-level integration (line 28)
- `modules/nixos/base.nix` — nix-ld enablement
- `modules/home/desktop.nix` — polkit agent package
- `flake.nix` — permittedInsecurePackages
