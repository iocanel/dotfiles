{ config, pkgs, lib, ... }:

with lib;

let
  lpass = pkgs.callPackage /home/iocanel/.config/home-manager/packages/lpass/1.6.0.nix { };

  zshPrompt = ''
    # Load vcs_info for git branch
    autoload -Uz vcs_info
    precmd() { vcs_info }
    zstyle ':vcs_info:git:*' formats '(%b)'

    # Define git_status function
    git_status() {
      if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        echo ''
      else
        echo '✔'
      fi
    }

    # Define the prompt
    PROMPT=" %F{yellow} ";
    PRPROMPT='%F{gray}$(git_status)%f'
  '';
in
{
  home.stateVersion = "24.05"; # Adjust this according to your Nixpkgs version
  home.username = "iocanel";
  home.homeDirectory = "/home/iocanel";

  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 64;
  };

  home.sessionVariables = {
    EDITOR="nvim";
  };

  home.file.".pam-gnupg".text = "A4C5FFF68C5194FF10230082F5AA74EB157D8E01";

  home.file.".unison/documents.prf".text = ''
    root = ${config.home.homeDirectory}/Documents
    root = ${config.home.homeDirectory}/.google/drive/Documents

    # Favor ${config.home.homeDirectory}/Documents in case of conflicts
    prefer = ${config.home.homeDirectory}/Documents

    # Ignore permission changes
    perms = 0
    # Additional options
    auto = true
    batch = true
    fastcheck = true
  '';

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];
  home.packages = with pkgs; [
    #
    # Apps
    #
    # Browser
    chromium
    firefox
    tor-browser
    qutebrowser
    # Media
    vocal
    newsflash
    obs-studio
    peek
    gifski
    asciinema
    asciinema-agg
    asciinema-scenario
    asciinema-automation
    kdenlive
    ombi
    geeqie
    digikam
    calibre
    # Media Downloaders
    jackett
    radarr
    sonarr
    
    # Sharing
    dropbox
    # Communication
    zulip
    zulip-term
    python312Packages.zulip

    slack
    discord
    remmina
    whatsapp-for-linux
    viber
    zoom-us
    teams-for-linux
    # Menu
    rofi-pass

    #
    # Text editing
    #
    emacs-lsp-booster
    tree-sitter
    pandoc
    plantuml
    ditaa
    # Emulation
    wine
    winetricks
    # Latex
    texliveFull
    # Office
    libreoffice
    xournal
    evince
    # Mail
    isync
    vdirsyncer
    offlineimap
    msmtp
    mu
    emacsPackages.mu4e
    emacsPackages.mu4e-alert
    emacsPackages.mu4e-column-faces
    emacsPackages.mu4e-conversation
    emacsPackages.mu4e-views
    emacsPackages.mu4e-overview
    emacsPackages.evil-mu4e
    #Music
    lilypond
    #
    # CLI
    #
    android-tools
    google-cloud-sdk
    kubectl
    openshift
    kind
    k9s
    argocd
    resumed
    hugo
    jq
    yq
    yt-dlp
    lpass # lastpass-cli
    gh
    #
    # Development
    #
    # AI tools
    codeium
    # C
    cmake
    libtool
    # Java
    gradle
    temurin-bin-21
    jbang
    openapi-generator-cli
    jetbrains.idea-community-bin
    vscode

    # Javascript
    nodejs
    nodejs_18
    yarn-berry
    nodePackages.gulp
    node2nix
    # Python
    python311
    poetry
    pipenv
    # Rust
	  rustup
    # Go
    go
    #
    # Productivity
    #
    obsidian
    #
    # Tray
    #
    pasystray

    #
    # Terminals
    #
    kitty
    #
    # TUI
    #
    fzf
    ripgrep
    bat
    eza
    dust
    htop
    tree
    #
    # Shell Extensions
    #
    # Zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    #
    # fish
    # (for setting up the prompt: $ tide configure)
    fishPlugins.tide
    #
    # Utils
    #
    xdotool
    scrot
    rsync
    rclone
    unison
    sutils
    zip
    #
    # Deamons and Services
    dunst
    # Requirement for home manager config scripts
    gettext
    hexdump

    #Virtual Machines
    virtualbox
  ];


  #
  # Activation scripts
  #

  # Password Store
  home.activation.pass  = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #/bin/sh

  #
  # Check if we are authenticated to the gpg agent
  # If not (when logging in) exit
  # Else (when we run home-manager switch) continue
  #
  AUTHENTICATED=$(${pkgs.pass}/bin/pass show authenticated)
  if [ "$AUTHENTICATED" != "true" ]; then
    exit 0
  fi
  export OPENAI_API_KEY=$(${pkgs.pass}/bin/pass show services/openai/iocanel/api-key)
  export GEMINI_PROJECT_ID=$(${pkgs.pass}/bin/pass show services/geminiai/project-id)
  export GEMINI_LOCATION=$(${pkgs.pass}/bin/pass show services/geminiai/location)

  export PATH=$HOME/bin:/run/wrappers/bin:/home/iocanel/.nix-profile/bin:/nix/profile/bin:/home/iocanel/.local/state/nix/profile/bin:/etc/profiles/per-user/iocanel/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin

  #
  # Recreate profile
  #
  echo "# .profile: generated, do not edit by hand." > $HOME/.profile
  echo "export OPENAI_API_KEY=$OPENAI_API_KEY" >> $HOME/.profile
  echo "export GEMINI_PROJECT_ID=$GEMINI_PROJECT_ID" >> $HOME/.profile
  echo "export GEMINI_LOCATION=$GEMINI_LOCATION" >> $HOME/.profile
  echo "export PATH=$PATH" >> $HOME/.profile

  # This is against NixOS philosophy but I do need it for demo etc
  echo "export LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}" >> $HOME/.profile
  echo "export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}" >> $HOME/.profile
  echo "export LIBCLANG_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}" >> $HOME/.profile
  echo "export NIX_LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}" >> $HOME/.profile
  '';

  # Rclone
  home.activation.rclone = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #/bin/sh
  mkdir -p $HOME/.config/rclone
  pass show config/rclone > $HOME/.config/rclone/rclone.conf
  '';

  # Wine
  home.activation.wine = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #/bin/sh
  mkdir -p $HOME/.wine/dosdevices
  if [ ! -e $HOME/.wine/dosdevices/d: ]; then
    ln -sf /mnt/cdrom $HOME/.wine/dosdevices/d:
  fi
  '';
  
  # Dokcer buildkit
  home.activation.docker = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #/bin/sh
  export DOCKER_BUILDKIT=1 >> $HOME/.profile
  '';

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    zsh = {
      enable = false;
      shellAliases = {
        vi="nvim";
        vim="nvim";
        ls="${pkgs.eza}/bin/eza";
        # Development aliases
        qs="java -jar /home/iocanel/workspace/src/github.com/quarkusio/quarkus/devtools/cli/target/quarkus-cli-999-SNAPSHOT-runner.jar";
        qds="java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=\\*:5005 -jar /home/iocanel/workspace/src/github.com/quarkusio/quarkus/devtools/cli/target/quarkus-cli-999-SNAPSHOT-runner.jar";
      };
      initExtra = ''
        ${zshPrompt}
      '';
    };
    fish = {
      enable = true;
      shellAliases = {
        vi="nvim";
        vim="nvim";
        ls="${pkgs.eza}/bin/eza";
        # Development aliases
        qs="java -jar /home/iocanel/workspace/src/github.com/quarkusio/quarkus/devtools/cli/target/quarkus-cli-999-SNAPSHOT-runner.jar";
        qds="java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=\\*:5005 -jar /home/iocanel/workspace/src/github.com/quarkusio/quarkus/devtools/cli/target/quarkus-cli-999-SNAPSHOT-runner.jar";
        argods="java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=\\*:5005 -jar /home/iocanel/workspace/src/github.com/quarkiverse/quarkus-argocd/cli/target/quarkus-argocd-cli-999-SNAPSHOT.jar";
        qbds="java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=\\*:5005 -jar /home/iocanel/workspace/src/github.com/quarkiverse/quarkus-backstage/cli/target/quarkus-backstage-cli-999-SNAPSHOT.jar";
      };
      interactiveShellInit = ''

      function fish_prompt_disabled
          set_color yellow
          echo -n " \$ "
          set_color normal
      end

      set fish_greeting ""
      # Let's load the .profile file
      if test -f ~/.profile
        source ~/.profile
      end
      # Other environment variables
      export QUARKUS_KUBERNETES_CLIENT_TRUST_CERTS=true

      # Enable(1) / Disable(0) autosuggestions
      set -U fish_autosuggestion_enabled 1
      '';
    };
    git = {
      enable = true;
      userName = "Ioannis Canellos";
      userEmail = "iocanel@gmail.com";
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  services = {
    emacs = {
      enable = false;
    };
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 604800;
      maxCacheTtl = 604800;
      enableSshSupport = true;
      extraConfig = ''
        allow-preset-passphrase
      '';
    };
    udiskie = {
      enable = true;
      automount = true;
      tray = "auto";
    };
  };

  systemd = {
    user = { 
      services = {
        emacs-daemon = {
          Unit = {
            Description = "Emacs Daemon Service";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.bash}/bin/bash -c  'exec ${pkgs.emacs}/bin/emacs --fg-daemon'";
            ExecStop = "${pkgs.emacs}/bin/emacsclient --eval '(kill-emacs)'"; # Optional, clean stop
            Restart = "on-failure";
            StandardOutput = "append:/home/iocanel/.emacs.d/emacs.log";
            StandardError = "append:/home/iocanel/.emacs.d/emacs.log";
          };
        };
        update-nixos-config = {
          Unit = {
            Description = "Update nixos configuration";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.rsync}/bin/rsync -a --delete /etc/nixos/ ${config.home.homeDirectory}/.nixos";
          };
        };
        mount-google-drive = {
          Unit = {
            Description = "Mount Google Drive";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.rclone}/bin/rclone mount \"Google Drive:\" ${config.home.homeDirectory}/.google/drive";
            ExecStop = "${pkgs.coreutils}/bin/fusermount -u $HOME/.google/drive";
            Restart = "always";
          };
        };
        sync-documents = {
          Unit = {
            Description = "Sync Documents";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.unison}/bin/unison documents";
            Restart = "always";
          };
        };
        sync-email = {
          Unit = {
            Description = "Sync Email";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.isync}/bin/mbsync -Va
            ExecStartPost=${pkgs.mu}/bin/mu index --muhome ${config.home.homeDirectory}/.cache/mu/";
            Restart = "on-failure";  # Only restart if it fails
            RestartSec = 30;         # Wait 30 seconds before restarting
            TimeoutStartSec = "300"; # Allow up to 5 minutes for the service to start
          };
        };
        sync-lpass = {
          Unit = {
            Description = "Sync lpass to pass";
          };
          Install = {
            wantedBy = [ "default.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${config.home.homeDirectory}/.config/home-manager/scripts/lpass-to-pass";
            Restart = "on-failure";
          };
          # Run service after the user session starts
        };
      };
      timers = {
        update-nixos-config = {
          Unit = {
            Description = "Timer for update-nixos-config";
          };
          Timer = {
            OnCalendar = "daily";
            Persistent = true;
            Unit = "update-nixos-config.service";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
        sync-documents = {
          Unit = {
            Description = "Timer for sync-documents";
          };
          Timer = {
            OnCalendar = "daily";
            Persistent = true;
            Unit = "sync-documents.service";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
        sync-email = {
          Unit = {
            Description = "Timer for sync-email";
          };
          Timer = {
            OnCalendar = "*:0/5"; # This will run the timer every 5 minutes
            Persistent = true;
            Unit = "sync-email.service";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
        sync-lpass = {
          Unit = {
            Description = "Timer for sync-lpass";
          };
          Timer = {
            OnCalendar = "daily";
            Persistent = true;
            Unit = "sync-lpass.service";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
      };
    };
  };

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
  };
}
