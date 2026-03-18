# Wayland Dotfiles

This directory contains Wayland compositor configurations with support for both Sway and Hyprland as drop-in replacements for each other.

## Directory Structure

```
wayland/
├── common/           # Shared components (compositor-agnostic)
│   ├── bin/         # Generic scripts
│   ├── kanshi/      # Monitor hotplug management
│   ├── monitor-mgmt-wlr/  # Monitor management scripts
│   ├── swaylock/    # Screen lock scripts
│   ├── swaync/      # Notification daemon config
│   ├── waybar/      # Waybar shared scripts and styles
│   ├── way-displays/  # Display configuration
│   └── wofi/        # Application launcher
│
├── sway/            # Sway-specific configuration
│   ├── .config/sway/  # Sway config files
│   ├── .config/waybar/  # Sway waybar config (uses sway/workspaces)
│   ├── bin/         # Sway-specific scripts
│   └── swayr/       # Sway workspace/window manager
│
└── hyprland/        # Hyprland-specific configuration
    ├── .config/hypr/  # Hyprland config files
    ├── .config/waybar/  # Hyprland waybar config (uses hyprland/workspaces)
    └── bin/         # Hyprland-specific scripts
```

## Feature Parity

Both Sway and Hyprland configurations provide identical functionality:

### Keybindings
All keybindings are identical between Sway and Hyprland:
- `$mod` = Super/Windows key
- `$mod+Return` - Terminal (kitty)
- `$mod+U` - Editor terminal (bottom 25%)
- `$mod+B` - Browser (qutebrowser)
- `$mod+D` / `$mod+;` - Application launcher (wofi)
- `$mod+W` - Window switcher
- `$mod+Shift+Q` / `$mod+Shift+Y` - Kill window
- `$mod+1-0` - Switch to workspace
- `$mod+Shift+1-0` - Move window to workspace
- `$mod+Ctrl+Left/Right` - Move workspace to monitor
- `$mod+R` - Resize mode
- `$mod+H/V` - Split horizontal/vertical
- `$mod+Shift+F` - Fullscreen
- `$mod+Shift+Space` - Toggle floating
- And many more...

### Workspaces
Same workspace setup for both:
1. 1:  - Terminal
2. 2:  - Email (Personal)
3. 3:  - Email (Work)
4. 4:  - Calendar
5. 5:  - Chat (Slack/Zulip)
6. 6:  - AI (ChatGPT)
7. 7:  - Editor (Emacs)
8. 8-10 - General purpose

### Visual Theme
Both use Catppuccin color schemes:
- Catppuccin Mocha (dark) - default
- Catppuccin Latte (light)

Theme switching:
- Sway: `theme-use-dark-sway` / `theme-use-light-sway`
- Hyprland: `theme-use-dark-hyprland` / `theme-use-light-hyprland`

### Common Features
- **Gaps**: Inner 20px, Outer 20px
- **Border**: 4px width
- **Rounded corners**: 10px
- **Shadows**: Enabled with blur
- **Smart borders**: On
- **Input**: US/GR keyboard layout with Alt+Shift toggle
- **Middle-click paste**: Enabled globally

### Waybar
Both configurations use Waybar with identical modules:
- Workspaces (compositor-specific module)
- Mode/Submap indicator
- Custom modules: Gmail, GitHub, Notifications
- Clock with org-agenda integration
- Screen lock toggle
- System tray

### Screenshots
- Sway: Uses grim + slurp
  - `sway-screenshot-region`
  - `sway-screenshot-full`
  - `sway-screenshot-output`
- Hyprland: Uses grim + slurp
  - `hyprland-screenshot-region`
  - `hyprland-screenshot-full`
  - `hyprland-screenshot-output`
- Both: Flameshot GUI available via `$mod+Shift+P`

### Window Management
- Sway: Uses swayr for window switching
- Hyprland: Uses custom wofi-based window switcher

### Idle Management
- Sway: Uses swayidle (systemd service)
- Hyprland: Uses hypridle (systemd service)
- Both: Lock after 180s, DPMS off after 600s

### Screen Lock
- Both use the same scripts in `common/swaylock/bin/`:
  - `screenlock-now`
  - `screenlock-enable`
  - `screenlock-disable`
  - `screenlock-toggle`

### Notifications
- Both use swaync (Sway Notification Center)
- Toggle via `Ctrl+\`` or waybar

## Configuration Files

### Sway
- Main config: `sway/.config/sway/config`
- Theme: `sway/.config/sway/catppuccin-mocha-theme.conf`
- Waybar: `sway/.config/waybar/config.json`

### Hyprland
- Main config: `hyprland/.config/hypr/hyprland.conf`
- Theme: `hyprland/.config/hypr/catppuccin-mocha-theme.conf`
- Waybar: `hyprland/.config/waybar/config.json`

### Common
- Waybar styles: `common/waybar/.config/waybar/style.css`
- Catppuccin themes: `common/waybar/.config/waybar/catppuccin-{mocha,latte}.css`
- Wofi config: `common/wofi/.config/wofi/config`
- Swaync: `common/swaync/.config/swaync/config.json`

## Startup Applications

Both configurations launch the same set of applications:
- MainTerminal (workspace 1)
- Emacs "Workspace Emacs" (workspace 7)
- ChatGPT web (workspace 6)
- Gmail personal (workspace 2)
- Outlook work email (workspace 3)
- Outlook work calendar (workspace 4)

## Portability

All symlinks use **relative paths**, so the dotfiles directory can be moved to any location without breaking links.

## Switching Between Compositors

### At Login (greetd/tuigreet)

After applying the NixOS configuration changes (see below), you can select between Sway and Hyprland at the login screen:

1. At the greetd login prompt, press `F2` to select session
2. Choose either "Sway" or "Hyprland"
3. Log in - tuigreet will remember your choice with `--remember`

### Manual Launch

You can also launch directly from a TTY:
- Sway: `sway-session` or `sway`
- Hyprland: `hyprland-session` or `Hyprland`

Both configurations provide an identical user experience with the same keybindings, workspaces, and visual appearance.

## NixOS & Home-Manager Configuration

The configuration has been split into modular files with **aligned naming** between NixOS and home-manager:

### Module Structure (Aligned)

**NixOS (`~/.nixos/modules/display/`)**:
- **`display-manager.nix`** - Top-level switcher (wayland vs xorg)
- **`wayland.nix`** - Imports sway + hyprland, enables both, configures greetd
  - **`wayland-common.nix`** - Common Wayland packages
  - **`sway.nix`** - Sway system configuration
  - **`hyprland.nix`** - Hyprland system configuration
- **`xorg.nix`** - X11 configuration

**Home-Manager (`~/.config/home-manager/modules/display/`)**:
- **`manager.nix`** - Top-level display manager selector
- **`wayland.nix`** - Imports wayland-common + sway + hyprland, enables both
  - **`wayland-common.nix`** - Common systemd services (waybar, cliphist, flameshot)
  - **`sway.nix`** - Sway user services (swayidle, waypaper)
  - **`hyprland.nix`** - Hyprland user services (hypridle, hyprpaper)
- **`xorg.nix`** - X11 user configuration

### What Each Module Does

#### NixOS Modules

**`wayland-common.nix`** (System):
- Common Wayland packages: waybar, wofi, wl-clipboard, grim, slurp, etc.
- XWayland support
- Environment variables (QT_QPA_PLATFORM, GDK_BACKEND, etc.)
- Disables X11 services

**`sway.nix`** (System):
- Sway packages: swayfx, swaybg, swayidle, swaylock-effects
- Enables `programs.sway`
- XDG portal configuration for wlr
- Session wrapper script (`/etc/sway-session`)
- Desktop entry (`/etc/wayland-sessions/sway.desktop`)
- PAM configuration for swaylock

**`hyprland.nix`** (System):
- Hyprland packages: hyprland, hyprpaper, hyprlock, hypridle
- Enables `programs.hyprland`
- XDG portal configuration for hyprland
- Session wrapper script (`/etc/hyprland-session`)
- Desktop entry (`/etc/wayland-sessions/hyprland.desktop`)
- PAM configuration for hyprlock

**`wayland.nix`** (System):
- Imports wayland-common + sway + hyprland
- Enables both compositors (both ready to use)
- Configures greetd with tuigreet for session selection
- PAM configuration for greetd

#### Home-Manager Modules

**`wayland-common.nix`** (User):
- Common systemd user services:
  - **waybar** - Status bar (binds to sessionTarget)
  - **cliphist-store** - Clipboard history (binds to sessionTarget)
  - **flameshot** - Screenshot daemon (binds to sessionTarget)
- Takes `sessionTarget` parameter (sway-session.target or hyprland-session.target)
- Services start only when the respective compositor is active

**`sway.nix`** (User):
- Sway-specific packages: swaylock-effects, swayidle, swayr, waypaper
- XDG portal configuration for user (wlr)
- Sway-specific systemd services:
  - **swayidle** - Idle management (lock, DPMS)
  - **waypaper** - Wallpaper management
- Sets sessionTarget to "sway-session.target"

**`hyprland.nix`** (User):
- Hyprland-specific packages: hyprland, hyprpaper, hyprlock, hypridle
- Enables `wayland.windowManager.hyprland` with systemd integration
- XDG portal configuration for user (hyprland)
- Hyprland-specific systemd services:
  - **hypridle** - Idle management (lock, DPMS)
  - **hyprpaper** - Wallpaper management
- Sets sessionTarget to "hyprland-session.target"

**`wayland.nix`** (User):
- Imports wayland-common + sway + hyprland
- Enables both compositors (both ready to use)
- No duplicate services - common services defined once in wayland-common.nix

### Key Benefits of Aligned Structure

1. **Consistent Naming**: Same module names in both NixOS and home-manager
2. **No Conflicts**: Common services (waybar, cliphist) defined once, bind to active compositor's target
3. **Both Ready**: Enabling `wayland` enables both Sway and Hyprland - switch at login without rebuilding
4. **Clear Separation**:
   - NixOS: System-level (packages, programs, session wrappers)
   - Home-Manager: User-level (systemd services, user portal config)
5. **Smart Service Activation**: Services start based on which compositor is running via systemd targets

### Changes Made

**`~/.nixos/configuration.nix`** - Removed all Wayland-specific configuration:
- Packages (swayfx, waybar, wofi, wl-clipboard, etc.)
- `programs.sway` and `programs.xwayland` sections
- `xdg.portal` configuration
- PAM swaylock configuration

**`~/.config/home-manager/home.nix`** - Keep `wayland.enable = true`:
- All compositor configuration now in modules
- Both Sway and Hyprland user services configured
- Services activate based on active compositor

### Applying Changes

```bash
# Copy the updated configuration to /etc/nixos
cd ~/.nixos
./apply

# Or manually:
sudo cp -r ~/.nixos/* /etc/nixos/
sudo nixos-rebuild switch
```

After rebuilding, both Sway and Hyprland will be available for selection at login.
