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

    # Sway window manager configuration
    wayland.windowManager.sway = {
      enable = false;          # don't generate it but use the stowed one
      package = pkgs.swayfx;   # ensure HM uses SwayFX too
      systemd = {
        enable = true;
      };
      checkConfig = false;     # <-- prevent sandbox validation (fixes build)
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
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
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
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${config.home.homeDirectory}/bin/screenlock-now' timeout 600 'swaymsg \"output * power off\"' resume 'swaymsg \"output * power on\"' before-sleep '${config.home.homeDirectory}/bin/screenlock-now'";
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
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.waypaper}/bin/waypaper --wallpaper ${config.home.homeDirectory}/Documents/photos/wallpapers/HD/default.jpg";
            Environment = [
              "XDG_CURRENT_DESKTOP=sway"
              "XDG_SESSION_TYPE=wayland"
            ];
          };
        };
      };

      targets = {
        "sway-session" = {
          Unit = {
            Description = "Sway Graphical Session";
            BindsTo = [ "graphical-session.target" ];
            Wants   = [ "graphical-session.target" ];
            After   = [ "graphical-session-pre.target" ];
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
      };
    };
  };
}