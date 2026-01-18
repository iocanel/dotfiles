{ config, pkgs, lib, ... }:

with lib;

{
  options.sway = {
    enable = mkEnableOption "Sway desktop environment configuration";
  };

  config = mkIf config.sway.enable {
    # Enable common Wayland configuration
    wayland.enable = true;

    # Sway-specific packages
    home.packages = with pkgs; [
      xdg-desktop-portal-wlr
      swaylock-effects
      swayidle
      swayr
      waypaper
    ];

    # XDG Portal configuration for Sway
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        sway = {
          default = "wlr";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
        };
      };
    };

    # Sway-specific systemd services
    systemd.user.services = {
      waybar = {
        Unit = {
          Description = "Waybar status bar";
          Requires = [ "sway-session.target" ];
          After = [ "sway-session.target" ];
          PartOf = [ "sway-session.target" ];
        };
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.waybar}/bin/waybar -c ${config.home.homeDirectory}/.config/waybar/config.json";
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
          Restart = "on-failure";
          RestartSec = "1";
        };
      };
      swayidle = {
        Unit = {
          Description = "Swayidle idle daemon";
          Requires = [ "sway-session.target" ];
          After = [ "sway-session.target" ];
          PartOf = [ "sway-session.target" ];
        };
        Install = {
          WantedBy = [ "sway-session.target" ];
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
        };
      };

      waypaper = {
        Unit = {
          Description = "Set wallpaper with waypaper";
          Requires = [ "sway-session.target" ];
          After = [ "sway-session.target" ];
          PartOf = [ "sway-session.target" ];
        };
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Service = {
          Type = "forking";
          ExecStart = "${pkgs.writeShellScript "start-waypaper" ''
            # Wait for Wayland display to be available
            until [ -n "$WAYLAND_DISPLAY" ] && [ -S "/run/user/$(id -u)/$WAYLAND_DISPLAY" ]; do
              sleep 1
            done
            # Kill any existing swaybg processes first
            pkill swaybg || true
            # Start waypaper which will launch swaybg in background
            ${pkgs.waypaper}/bin/waypaper --restore
          ''}";
          Restart = "on-failure";
          RestartSec = "5";
        };
      };
    };
  };
}
