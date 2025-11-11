{ config, pkgs, lib, ... }:

with lib;

{
  options.wayland = {
    enable = mkEnableOption "Wayland desktop environment configuration";
  };

  config = mkIf config.wayland.enable {
    home.packages = with pkgs; [
      # Portal services
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk

      # Wayland desktop components
      waybar
      swaylock-effects
      swayidle
      swayr
      way-displays
      wdisplays
      wlr-randr
      wl-mirror
      waypaper

      # Wayland-specific menu and clipboard
      wofi
      cliphist
      wl-clipboard
      wl-clip-persist
      wtype

      # Wayland automation and utilities
      ydotool
      grim
      slurp

      # Wayland notifications
      swaynotificationcenter
    ];

    # XDG Portal configuration for screen sharing
    xdg.portal = {
      enable = true;
      extraPortals = [ 
        pkgs.xdg-desktop-portal-wlr 
        pkgs.xdg-desktop-portal-gtk 
      ];
      config = {
        common = {
          default = "wlr";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
        };
      };
    };


    # Wayland-specific systemd services
    systemd.user = {
      services = {
        ydotoold = {
          Unit = {
            Description = "ydotool daemon";
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.ydotool}/bin/ydotoold";
            Restart = "on-failure";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };

        waybar = {
          Unit = {
            Description = "Waybar status bar";
            After = [ "default.target" ];
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.waybar}/bin/waybar -c ${config.home.homeDirectory}/.config/waybar/config.json";
            ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
            Restart = "on-failure";
            RestartSec = "1";
            Environment = [
              "XDG_CURRENT_DESKTOP=sway"
              "XDG_SESSION_TYPE=wayland"
              "HOME=${config.home.homeDirectory}" 
              "PATH=/run/wrappers/bin:${config.home.homeDirectory}/bin:${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin"
            ];
          };
        };

        swayidle = {
          Unit = {
            Description = "Swayidle idle daemon";
            After = [ "default.target" ];
            Requisite = [ "default.target" ];
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.writeShellScript "start-swayidle" ''
              # Wait for Sway to be fully ready
              until [ -n "$WAYLAND_DISPLAY" ] && ${pkgs.sway}/bin/swaymsg -t get_version >/dev/null 2>&1; do 
                sleep 1
              done
              exec ${pkgs.swayidle}/bin/swayidle -w \
                timeout 180 '${config.home.homeDirectory}/bin/screenlock-now' \
                timeout 600 'swaymsg "output * power off"' \
                resume 'swaymsg "output * power on"' \
                before-sleep '${config.home.homeDirectory}/bin/screenlock-now'
            ''}";
            Restart = "on-failure";
            RestartSec = "1";
            Environment = [
              "XDG_CURRENT_DESKTOP=sway"
              "XDG_SESSION_TYPE=wayland"
              "WAYLAND_DISPLAY=wayland-1"
              "PATH=/run/wrappers/bin:${config.home.homeDirectory}/bin:${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin"
            ];
          };
        };

        waypaper = {
          Unit = {
            Description = "Set wallpaper with waypaper";
            After = [ "default.target" ];
            Requisite = [ "default.target" ];
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            Type = "forking";
            ExecStart = "${pkgs.writeShellScript "start-waypaper" ''
              # Wait for Wayland display to be available
              until [ -n "$WAYLAND_DISPLAY" ] && [ -S "/run/user/$(id -u)/wayland-1" ]; do
                sleep 1
              done
              # Kill any existing swaybg processes first
              pkill swaybg || true
              # Start waypaper which will launch swaybg in background
              ${pkgs.waypaper}/bin/waypaper --restore
            ''}";
            Restart = "on-failure";
            RestartSec = "5";
            Environment = [
              "XDG_CURRENT_DESKTOP=sway"
              "XDG_SESSION_TYPE=wayland"
              "WAYLAND_DISPLAY=wayland-1"
              "DISPLAY=:0"
              "PATH=/run/wrappers/bin:${config.home.homeDirectory}/bin:${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin"
            ];
          };
        };

        # Simple clipboard management - editor-centric approach
        cliphist-store = {
          Unit = {
            Description = "Store clipboard content in history (regular clipboard only)";
            After = [ "default.target" ];
            Requisite = [ "default.target" ];
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            Type = "simple";
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.cache/cliphist";
            ExecStart = "${pkgs.writeShellScript "start-cliphist" ''
              # Wait for Wayland display to be available
              until [ -n "$WAYLAND_DISPLAY" ] && [ -S "/run/user/$(id -u)/wayland-1" ]; do
                sleep 1
              done
              exec ${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store
            ''}";
            Restart = "on-failure";
            RestartSec = "1";
            Environment = [
              "XDG_CURRENT_DESKTOP=sway"
              "XDG_SESSION_TYPE=wayland"
              "WAYLAND_DISPLAY=wayland-1"
              "PATH=/run/wrappers/bin:${config.home.homeDirectory}/bin:${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin"
            ];
          };
        };
      };

      targets = {
        # Remove custom sway-session target - home-manager creates one automatically
      };
    };
  };
}