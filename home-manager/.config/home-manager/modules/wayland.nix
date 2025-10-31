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
              "PATH=${config.home.homeDirectory}/bin:${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin"
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
            ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2' timeout 600 'swaymsg \"output * power off\"' resume 'swaymsg \"output * power on\"' before-sleep '${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2'";
            Restart = "on-failure";
            RestartSec = "1";
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