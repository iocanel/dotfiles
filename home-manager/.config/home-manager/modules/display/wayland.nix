{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./sway.nix
    ./hyprland.nix
  ];

  options.wayland = {
    enable = mkEnableOption "Wayland desktop environment configuration";
  };

  config = mkIf config.wayland.enable {
    # Enable both Sway and Hyprland when Wayland is enabled
    # This ensures both are ready to use without config changes

    home.packages = with pkgs; [
      # Portal services
      xdg-desktop-portal-gtk

      # Wayland desktop components
      waybar
      way-displays
      wdisplays
      wlr-randr
      wl-mirror

      # Wayland-specific menu and clipboard
      wofi
      cliphist
      wl-clipboard
      wl-clip-persist
      wtype

      # Wayland automation and utilities
      grim
      slurp

      # Wayland notifications
      swaynotificationcenter
    ];

    # Common Wayland systemd services
    # Services can bind to either sway-session.target or hyprland-session.target as needed
    # Only one compositor runs at a time, so only one set of services starts
    systemd.user.services = {

      cliphist-store = {
        Unit = {
          Description = "Store clipboard content in history";
          After = [ "sway-session.target" "hyprland-session.target" ];
          PartOf = [ "sway-session.target" "hyprland-session.target" ];
        };
        Install = {
          WantedBy = [ "sway-session.target" "hyprland-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.cache/cliphist";
          ExecStart = "${pkgs.writeShellScript "start-cliphist" ''
            # Wait for Wayland display to be available
            until [ -n "$WAYLAND_DISPLAY" ] && [ -S "/run/user/$(id -u)/$WAYLAND_DISPLAY" ]; do
              sleep 1
            done
            exec ${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store
          ''}";
          Restart = "on-failure";
          RestartSec = "1";
        };
      };

      flameshot = {
        Unit = {
          Description = "Flameshot screenshot tool daemon";
          After = [ "sway-session.target" "hyprland-session.target" ];
          PartOf = [ "sway-session.target" "hyprland-session.target" ];
        };
        Install = {
          WantedBy = [ "sway-session.target" "hyprland-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.writeShellScript "start-flameshot" ''
            # Wait for Wayland display to be available
            until [ -n "$WAYLAND_DISPLAY" ] && [ -S "/run/user/$(id -u)/$WAYLAND_DISPLAY" ]; do
              sleep 1
            done
            exec ${pkgs.flameshot}/bin/flameshot
          ''}";
          Restart = "on-failure";
          RestartSec = "1";
        };
      };
    };
  };
}
