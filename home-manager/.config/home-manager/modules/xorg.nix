{ config, pkgs, lib, ... }:

with lib;

{
  options.xorg = {
    enable = mkEnableOption "Xorg desktop environment configuration";
  };

  config = mkIf config.xorg.enable {
    home.packages = with pkgs; [
      # X11 specific packages
      i3
      i3status
      i3blocks
      i3lock
      
      # X11 utilities
      xorg.xrandr
      xorg.xmodmap
      xorg.setxkbmap
      xorg.xset
      xorg.xev
      xorg.xprop
      xorg.xwininfo
      xautolock
      xdotool
      scrot
      nitrogen
      autocutsel
      
      # Xorg-specific menu and applications
      rofi
      rofi-pass
      rofi-file-browser
      dmenu
      dmenufm
      
      # X11 clipboard management
      clipmenu
      
      # X11 notifications
      dunst
      
      # X11 compositing and effects
      picom
      compton
      
      # X11 system tray and applets
      networkmanagerapplet
      blueman
      pasystray
      
      # X11 desktop utilities
      conky
      screenkey
      
      # X11 session management
      dockd
    ];

    # X11-specific services
    services = {
      dunst = {
        enable = true;
        settings = {
          global = {
            monitor = 0;
            follow = "mouse";
            geometry = "320x5-30+20";
            indicate_hidden = "yes";
            shrink = "no";
            transparency = 0;
            notification_height = 0;
            separator_height = 2;
            padding = 8;
            horizontal_padding = 8;
            frame_width = 2;
            frame_color = "#aaaaaa";
            separator_color = "frame";
            sort = "yes";
            idle_threshold = 120;
            font = "Monospace 10";
            line_height = 0;
            markup = "full";
            format = "<b>%s</b>\n%b";
            alignment = "left";
            show_age_threshold = 60;
            word_wrap = "yes";
            ellipsize = "middle";
            ignore_newline = "no";
            stack_duplicates = true;
            hide_duplicate_count = false;
            show_indicators = "yes";
            icon_position = "left";
            max_icon_size = 32;
            sticky_history = "yes";
            history_length = 20;
            browser = "firefox";
            always_run_script = true;
            title = "Dunst";
            class = "Dunst";
            startup_notification = false;
            verbosity = "mesg";
            corner_radius = 0;
            mouse_left_click = "close_current";
            mouse_middle_click = "do_action";
            mouse_right_click = "close_all";
          };
          
          urgency_low = {
            background = "#222222";
            foreground = "#888888";
            timeout = 10;
          };
          
          urgency_normal = {
            background = "#285577";
            foreground = "#ffffff";
            timeout = 10;
          };
          
          urgency_critical = {
            background = "#900000";
            foreground = "#ffffff";
            frame_color = "#ff0000";
            timeout = 0;
          };
        };
      };

      picom = {
        enable = true;
        fade = true;
        fadeDelta = 5;
        fadeSteps = [ 0.03 0.03 ];
        shadow = true;
        shadowOpacity = 0.75;
        shadowOffsets = [ (-7) (-7) ];
        shadowExclude = [
          "name = 'Notification'"
          "class_g = 'Conky'"
          "class_g ?= 'Notify-osd'"
          "class_g = 'Cairo-clock'"
          "_GTK_FRAME_EXTENTS@:c"
        ];
        activeOpacity = 1.0;
        inactiveOpacity = 1.0;
        menuOpacity = 1.0;
        opacityRules = [
          "80:class_g = 'URxvt'"
          "80:class_g = 'UXTerm'"
          "80:class_g = 'XTerm'"
        ];
        backend = "glx";
        vSync = true;
        settings = {
          corner-radius = 10;
          detect-rounded-corners = true;
          detect-client-opacity = true;
          refresh-rate = 0;
          vsync-use-glfinish = true;
          dbe = false;
          unredir-if-possible = true;
          focus-exclude = [ "class_g = 'Cairo-clock'" ];
          detect-transient = true;
          detect-client-leader = true;
          invert-color-include = [ ];
          glx-copy-from-front = false;
          glx-swap-method = "undefined";
          wintypes = {
            tooltip = { fade = true; shadow = true; opacity = 0.75; focus = true; };
            dock = { shadow = false; };
            dnd = { shadow = false; };
            popup_menu = { opacity = 0.8; };
            dropdown_menu = { opacity = 0.8; };
          };
        };
      };

      redshift = {
        enable = true;
        latitude = 37.9755;
        longitude = 23.7348;
        temperature = {
          day = 5500;
          night = 3500;
        };
      };

      screen-locker = {
        enable = true;
        inactiveInterval = 30;
        lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
      };
    };

    # X11-specific systemd services
    systemd.user.services = {
      clipmenud = {
        Unit = {
          Description = "Clipmenu daemon";
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.clipmenu}/bin/clipmenud";
          Restart = "on-failure";
          Environment = [
            "DISPLAY=:0"
          ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      nitrogen = {
        Unit = {
          Description = "Nitrogen wallpaper setter";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.nitrogen}/bin/nitrogen --restore";
          Environment = [
            "DISPLAY=:0"
          ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      autocutsel = {
        Unit = {
          Description = "AutoCutSel clipboard synchronization";
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.autocutsel}/bin/autocutsel -fork";
          ExecStartPost = "${pkgs.autocutsel}/bin/autocutsel -selection PRIMARY -fork";
          Restart = "on-failure";
          Environment = [
            "DISPLAY=:0"
          ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      nm-applet = {
        Unit = {
          Description = "Network Manager Applet";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
          Restart = "on-failure";
          Environment = [
            "DISPLAY=:0"
          ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      pasystray = {
        Unit = {
          Description = "PulseAudio system tray";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.pasystray}/bin/pasystray";
          Restart = "on-failure";
          Environment = [
            "DISPLAY=:0"
          ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };

    # X11 session configuration
    xsession = {
      enable = true;
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        config = null; # Use stowed configuration
      };
    };

    # X11-specific home files
    home.file = {
      ".xinitrc".text = ''
        #!/bin/sh
        # Keyboard layout
        setxkbmap -model pc105 -layout us,gr -option grp:alt_shift_toggle -option ctrl:nocaps
        
        # Start window manager
        exec i3
      '';

      ".Xresources".text = ''
        ! X11 resources
        *background: #000000
        *foreground: #ffffff
        
        ! URxvt settings
        URxvt*scrollBar: false
        URxvt*font: xft:Inconsolata:size=12
        URxvt*background: rgba:0000/0000/0000/c800
      '';
    };
  };
}