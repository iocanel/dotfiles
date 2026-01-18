{ config, pkgs, lib, ... }:

with lib;

{
#  options.hyprland = {
#    enable = mkEnableOption "Hyprland desktop environment configuration";
#};

#  config = mkIf config.hyprland.enable {
    # Enable common Wayland configuration
#    wayland.enable = true;

    # Hyprland session target
    # Note: Configuration is managed via dotfiles in ~/.dotfiles/wayland/hyprland/
    # Do NOT enable wayland.windowManager.hyprland as it will override stow configs
    # wayland.windowManager.hyprland.enable must be false to use dotfiles

    # Hyprland-specific packages
    home.packages = with pkgs; [
      xdg-desktop-portal-hyprland
      hyprland
      hyprpaper
      hyprlock
      hypridle
      hyprpicker
      hyprpanel  # Hyprland-specific bar
      hyprpwcenter  # Pipewire audio control
      hyprviz
    ];

    # XDG Portal configuration for Hyprland
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        hyprland = {
          default = "hyprland";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
          "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        };
      };
    };

    systemd.user.services = {
      hyprpanel = {
        Unit = {
          Description = "Hyprpanel status bar";
          Requires = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
          PartOf = [ "hyprland-session.target" ];
        };
        Install = {
          WantedBy = [ "hyprland-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.hyprpanel}/bin/hypridle -w -c ${config.home.homeDirectory}/.config/hyprpanel/config.json";
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
          Restart = "on-failure";
          RestartSec = "1";
        };
      };

      hypridle = {
        Unit = {
          Description = "Hypridle daemon";
          Requires = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
          PartOf = [ "hyprland-session.target" ];
        };
        Install = {
          WantedBy = [ "hyprland-session.target" ];
        };
        Service = {
          Type = "simple";

          ExecStart = "${pkgs.hypridle}/bin/hypridle -w -c ${config.home.homeDirectory}/.config/hypridle/hypridle.conf";
          Restart = "on-failure";
          RestartSec = "1";
        };
      };
    };
}
