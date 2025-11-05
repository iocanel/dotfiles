{ config, pkgs, lib, ... }:

with lib;

let
  lpass = pkgs.callPackage ./packages/lpass/1.6.0.nix { };
  buildFishPlugin = pkgs.fishPlugins.buildFishPlugin;
  fisher = pkgs.callPackage ./packages/fisher/4.4.4.nix {
    inherit buildFishPlugin;
  };
  org-roam-mcp = pkgs.callPackage ./packages/org-roam-mcp/default.nix {
    orgDir = "$HOME/Documents/org/roam";
    # Pin to an exact commit you trust:
    fromSpec = "git+https://github.com/aserranoni/org-roam-mcp@main";
    # fromSpec = "git+https://github.com/aserranoni/org-roam-mcp@<commit-sha>";
    # dbPath = "$HOME/Documents/org/roam/org-roam.db";
    extraArgs = [ ];
    env = {
      # Optional:
      ORG_ROAM_DIR = "$HOME/Documents/org/roam";
      ORG_ROAM_DB_PATH = "$HOME/.emacs.d/org-roam.db";
      UV_CACHE_DIR = "$HOME/.cache/uv";
    };
  };
  whisperApi = pkgs.callPackage ./packages/whisper-api/default.nix { };
  gimp3WithPlugins = pkgs.callPackage ./packages/gimp3-with-plugins/default.nix { };

  # Wrapper that forces Teams to use system notifications + Wayland
  teams-for-linux-with-notifications = pkgs.writeShellScriptBin "teams-for-linux" ''
    exec ${pkgs.teams-for-linux}/bin/teams-for-linux \
      --use-system-notifications \
      --enable-features=UseOzonePlatform,WaylandWindowDecorations \
      --ozone-platform-hint=auto \
      "$@"
  '';

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
  imports = [
    ./modules/media-center.nix
    ./modules/financial-services.nix
    ./modules/wayland.nix
    ./modules/xorg.nix
  ];

  # Desktop environment selection
  # Enable either wayland or xorg, not both
  # Set wayland.enable = false and xorg.enable = true to use X11/i3
  wayland.enable = true;
  xorg.enable = false;

  home.stateVersion = "25.05"; # Adjust this according to your Nixpkgs version
  home.username = "iocanel";
  home.homeDirectory = "/home/iocanel";

  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.adwaita-icon-theme;
    size = 64;
  };

  home.sessionVariables = {
    EDITOR="nvim";
    # Force Chromium to use proper Wayland clipboard
    CHROMIUM_FLAGS="--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime";
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

  # Media Center Services
  services.media-center = {
    enable = true;
    userId = 1000;
    groupId = 100;
    timezone = "Europe/Athens";
    
    emby.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    bazarr.enable = true;
    readarr.enable = true;
    jackett.enable = true;
  };

  # Financial Services
  services.financial-services = {
    enable = true;
    firefly = {
      enable = true;
      siteOwner = "iocanel@gmail.com";
    };
  };
  home.packages = with pkgs; [
    #
    # Shells
    #
    bash
    fish
    zsh

    #
    # Portal services (base)
    #
    xdg-desktop-portal
    #
    # Apps
    #
    # Browser
    chromium
    firefox
    tor-browser
    qutebrowser
    # Media
    newsflash
    obs-studio
    peek
    gifski
    asciinema
    asciinema-agg
    asciinema-scenario
    asciinema-automation
    losslesscut-bin
    ombi
    geeqie
    digikam
    calibre
    mp4v2
    pulsemixer
    gimp3WithPlugins
    pulseaudio
    pavucontrol
    pwvucontrol
    ffmpeg
    v4l-utils
    guvcview
    mpv
    opencv
    audacity
    # Desktop (shared)
    arandr
    lxrandr
    
    # Sharing
    dropbox
    # Communication
    zulip
    slack
    discord
    dropbox
    remmina
    wget
    curl
    wireshark
    openvpn
    networkmanager-openvpn
    networkmanagerapplet
    openssl
    bluez

    slack
    discord
    remmina
    whatsapp-for-linux
    viber
    zoom-us
    teams-for-linux-with-notifications
    # Menu (shared)
    rofi-pass

    #
    # Text editing
    #
    neovim
    emacs
    ltex-ls
    emacs-lsp-booster
    tree-sitter
    pandoc
    plantuml
    graphviz
    ditaa
    mermaid-cli
    ispell
    # Emulation
    wine
    winetricks
    # Latex
    texliveFull
    # Office
    libreoffice
    evince
    qpdf
    xournalpp
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
    eask
    
    #Music
    lilypond
    #
    # CLI
    #
    android-tools
    android-udev-rules
    google-cloud-sdk
    kubectl
    openshift
    kind
    k9s
    argocd
    vault
    resumed
    hugo
    bc
    jq
    yq
    yt-dlp
    lpass # lastpass-cli
    gh
    inetutils
    
    # Goose CLI
    # dependencies
    dbus
    pkg-config
    xorg.libxcb
    #
    

    #
    # Cloud
    #
    ansible
    terraform

    #
    # Development
    #
    # AI tools
    ollama
    codeium
    claude-code
    opencode
    org-roam-mcp
    whisperApi
    chatgpt-cli

    # C
    cmake
    gdb
    lldb
    libtool
    clang-tools
    # Java
    gradle
    temurin-bin-21
    jbang
    openapi-generator-cli
    jetbrains.idea-community-bin
    vscode
    # codelldb
    vscode-extensions.vadimcn.vscode-lldb
    (pkgs.writeShellScriptBin "codelldb" ''
      EXT="${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb"
      export LD_LIBRARY_PATH="$EXT/lldb/lib"
      exec "$EXT/adapter/codelldb" --liblldb "$EXT/lldb/lib/liblldb.so" "$@"
    '')

    xml2

    # Javascript
    nodejs
    yarn-berry
    nodePackages.gulp
    nodePackages.ts-node
    node2nix
    typescript-language-server
    vue-language-server
    # Python
    (python312.withPackages (ps: with ps; [
      numpy
      pandas
      luarocks
      matplotlib
      jupyterlab
      scipy
      hatchling
      statsmodels
      scikitlearn
      requests
      rapidfuzz
      weaviate
      openai
      tiktoken
      weaviate-client
      zulip
      debugpy
    ]))
    uv
    poetry
    pipenv
    shiv # For building binaries

    # Rust
    rustc
    rustfmt
    cargo
    rust-analyzer
    
    # SQL    
    sqlitebrowser

    # Go
    go
    gopls
    delve # For debuging
    air # for auto-reload
    #
    # Productivity
    #
    obsidian
    #
    # Finance    
    #
    firefly-iii

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
    
    fd
    # fzf and deps
    fzf
    chafa
    viu
    ueberzugpp


    lynx
    ripgrep
    bat
    eza
    dust
    htop
    tree
    pcalc
    #
    # Shell Extensions
    #
    # Zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    #
    fish
    #nix-your-shell (breaks nix-shell -p xxx)
    # (for setting up the prompt: $ tide configure)
    fishPlugins.tide
    fisher
    #
    # Utils
    #
    xdotool
    imagemagick
    rsync
    rclone
    unison
    sutils
    zip
    ripgrep
    util-linux
    tesseract4
    #
    # Deamons and Services (shared)
    # Requirement for home manager config scripts
    gettext
    hexdump

    #Virtual Machines
    virtualbox
    expressvpn
    google-chrome

    # Ethereum
    go-ethereum
    
    # Gaming
    steam
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
  export ANTHROPIC_API_KEY=$(${pkgs.pass}/bin/pass show services/anthropic/iocanel/default-key)
  export OPENAI_API_KEY=$(${pkgs.pass}/bin/pass show services/openai/iocanel/api-key)
  export GEMINI_PROJECT_ID=$(${pkgs.pass}/bin/pass show services/geminiai/project-id)
  export GEMINI_LOCATION=$(${pkgs.pass}/bin/pass show services/geminiai/location)

  export TAVILY_API_KEY=$(${pkgs.pass}/bin/pass show services/tavily/api-key)
  export QUARKUS_BACKSTAGE_URL=http://localhost:7007
  export QUARKUS_BACKSTAGE_TOKEN=7KE4bWxxoSHIuOczpLhIy/4GbeMz0Bjc

  export PATH=$HOME/bin:/run/wrappers/bin:/home/iocanel/.nix-profile/bin:/nix/profile/bin:/home/iocanel/.local/state/nix/profile/bin:/etc/profiles/per-user/iocanel/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin

  #
  # Recreate profile
  #
  echo "# .profile: generated, do not edit by hand." > $HOME/.profile
  echo "export ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" >> $HOME/.profile
  echo "export OPENAI_API_KEY=$OPENAI_API_KEY" >> $HOME/.profile
  echo "export GEMINI_PROJECT_ID=$GEMINI_PROJECT_ID" >> $HOME/.profile
  echo "export GEMINI_LOCATION=$GEMINI_LOCATION" >> $HOME/.profile
  echo "export TAVILY_API_KEY=$TAVILY_API_KEY" >> $HOME/.profile
  echo "export PATH=$PATH" >> $HOME/.profile
  echo "export QUARKUS_BACKSTAGE_URL=$QUARKUS_BACKSTAGE_URL" >> $HOME/.profile
  echo "export QUARKUS_BACKSTAGE_TOKEN=$QUARKUS_BACKSTAGE_TOKEN" >> $HOME/.profile

  # This is against NixOS philosophy but I do need it for demo etc
  #echo "export LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}" >> $HOME/.profile
  #echo "export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}" >> $HOME/.profile
  #echo "export LIBCLANG_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}" >> $HOME/.profile
  #echo "export NIX_LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}" >> $HOME/.profile
  '';

  # Rclone
  home.activation.rclone = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #/bin/sh
  mkdir -p $HOME/.config/rclone
  ${pkgs.pass}/bin/pass show config/rclone > $HOME/.config/rclone/rclone.conf
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
    gpg = {
      enable = true;
    };
    home-manager = {
      enable = true;
    };
    zsh = {
      enable = false;
      shellAliases = {
        vi="nvim";
        vim="nvim";
        ls="${pkgs.eza}/bin/eza";
        cd="z";
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
      plugins = [
         {
           name = "fisher";
           src = fisher;
         }
      ];
      shellAliases = {
        vi="nvim";
        vim="nvim";
        ls="${pkgs.eza}/bin/eza";
        # Development aliases
        qs="java -jar /home/iocanel/workspace/src/github.com/quarkusio/quarkus/devtools/cli/target/quarkus-cli-999-SNAPSHOT-runner.jar";
        qds="java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=\\*:5005 -jar /home/iocanel/workspace/src/github.com/quarkusio/quarkus/devtools/cli/target/quarkus-cli-999-SNAPSHOT-runner.jar";
        argods="java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=\\*:5005 -jar /home/iocanel/workspace/src/github.com/quarkiverse/quarkus-argocd/cli/target/quarkus-argocd-cli-999-SNAPSHOT.jar";
        qbds="java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=\\*:5005 -jar /home/iocanel/workspace/src/github.com/quarkiverse/quarkus-backstage/cli/target/quarkus-backstage-cli-999-SNAPSHOT.jar";
        qtds="java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=\\*:5005 -jar /home/iocanel/workspace/src/github.com/quarkiverse/quarkus-tekton/cli/target/quarkus-tekton-cli-999-SNAPSHOT.jar";
      };
      interactiveShellInit = ''
      function fish_user_key_bindings
        bind --erase ctrl-space
        bind 'ctrl-space' _fish_ai_autocomplete_or_fix
        bind ctrl-f _fish_ai_autocomplete_or_fix
      end
      function fish_prompt_disabled
          set_color yellow
          echo -n " \$ "
          set_color normal
      end

      function check_shell_nix --on-variable PWD
          if set -q IN_NIX_SHELL
              return
          end
          if test -f shell.nix
              # Auto-enter when inside VS Code integrated terminal
              if test "$TERM_PROGRAM" = "vscode"
                  echo "⚡ Auto-entering nix-shell in (pwd)"
                  nix-shell
                  return
              end
              read -n1 -s -P "⚡ Detected shell.nix in $(pwd). Do you want to enter nix-shell? (y/n)" -l choice
              if test "$choice" = "y"
                  nix-shell
              end
          end
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
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
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
      pinentry = {
        package = pkgs.pinentry-qt;   # or pkgs.pinentry-gnome3 / pkgs.pinentry-gtk2
      };
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
            ExecStart = "${pkgs.bash}/bin/bash -c 'source ~/.profile && exec ${pkgs.emacs}/bin/emacs --fg-daemon'";
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
            ExecStart = "${pkgs.rsync}/bin/rsync -a --delete --exclude='.git/' --exclude='etc-pull' --exclude='etc-push' /etc/nixos/ ${config.home.homeDirectory}/.nixos";
          };
        };
        mount-google-drive = {
          Unit = {
            Description = "Mount Google Drive";
            After = [ "graphical-session.target" "network-online.target" ];
            Wants = [ "network-online.target" ];
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.rclone}/bin/rclone mount \"Google Drive:\" ${config.home.homeDirectory}/.google/drive --allow-other --log-file=${config.home.homeDirectory}/.local/state/rclone.log";
            ExecStop = "${pkgs.coreutils}/bin/fusermount -u $HOME/.google/drive";
            Restart = "always";
            Environment = [
              "PATH=/run/wrappers/bin:${config.home.homeDirectory}/bin:${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin"
              "HOME=${config.home.homeDirectory}"
              "XDG_CONFIG_HOME=${config.home.homeDirectory}/.config"
            ];
          };
        };
        sync-documents = {
          Unit = {
            Description = "Sync Documents";
            After = [ "mount-google-drive.service" ];
            BindsTo = [ "mount-google-drive.service" ];
            ConditionPathIsMountPoint = "${config.home.homeDirectory}/.google/drive";
          };
          Install = {
            # Don't auto-start, only run via timer when mount is active
            WantedBy = [ ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.unison}/bin/unison documents";
            Environment = [
              "PATH=${config.home.homeDirectory}/bin:${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin"
            ];
          };
        };
        sync-email = {
          Unit = {
            Description = "Sync Email";
            StartLimitIntervalSec = 600;  # 10 minutes window
            StartLimitBurst = 2;          # Max 2 restarts in that window
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
            Environment = [
              "PATH=${config.home.homeDirectory}/bin:${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin"
            ];
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
            ConditionPathIsMountPoint = "${config.home.homeDirectory}/.google/drive";
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
  

  #
  # Home Files
  #
  home.file = {
    ".pam-gnupg".text = "A4C5FFF68C5194FF10230082F5AA74EB157D8E01";

    ".unison/documents.prf".text = ''
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
    ".config/fish-ai.ini".text = ''
      [fish-ai]
      configuration = openai

      [openai]
      provider = openai
      api_key = ${builtins.getEnv "OPENAI_API_KEY"}
      model = gpt-4o
    '';
    #
    # Helper scripts
    #
    # Containers
    "bin/stop-named-container" = {
      text = ''
        #!/bin/sh
        CONTAINER_NAME="$1"
        # Stop the container if it's running
        if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
          echo "Stopping container: $CONTAINER_NAME"
          docker stop $CONTAINER_NAME
        fi
        # Keep trying to remove the container until it is gone
        while docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; do
          echo "Trying to remove container: $CONTAINER_NAME"
          docker rm -f $CONTAINER_NAME
          sleep 1  # Short delay before retrying
        done
        echo "Container $CONTAINER_NAME removed successfully!"
      '';
      executable = true;
    };
    "bin/start-named-container" = {
      text = ''
        #!/bin/sh
        CONTAINER_NAME="$1"
        shift
        DOCKER_ARGS="$@"
        echo "Starting container: $CONTAINER_NAME with arguments: $DOCKER_ARGS"
        stop-named-container  $CONTAINER_NAME
        echo "docker run -d --name $CONTAINER_NAME $DOCKER_ARGS"
        sh -c "docker run -d --name $CONTAINER_NAME $DOCKER_ARGS"
      '';
      executable = true;
    };
    # Media
    ".local/bin/check-media-mounts.sh" = {
      text = ''
        #!/bin/bash
        # Check if the media mount point is accessible
        if ${pkgs.util-linux}/bin/mountpoint -q /mnt/media/; then
            echo "Directory /mnt/media/ is mounted. Starting media services." >> /var/log/check-media-mounts.log
            systemctl --user start sonarr
            systemctl --user start radarr
            systemctl --user start bazarr
            systemctl --user start readarr
        else
            echo "Directory /mnt/media/ is not mounted. Stopping mdeia service." >> /var/log/check-media-mounts.log
            systemctl --user stop sonarr
            systemctl --user stop radarr
            systemctl --user stop bazarr
            systemctl --user stop readarr
        fi
      '';
      onChange = ''
        chmod 0755 ~/.local/bin/check-media-mounts.sh
      '';
    };
    # Downloads
    ".local/bin/check-donwload-mounts.sh" = {
        text = ''
        #!/bin/bash
        DOWNLOADS_PATH="/mnt/downloads"
    
        # Check if the downloads mount point is accessible
        if ${pkgs.util-linux}/bin/mountpoint -q /mnt/downloads; then
            echo Directory /mnt/downloads/ is mounted. Starting download services." >> /var/log/check-download-mounts.log
            systemctl start deluge
        else
            echo Directory /mnt/downloads is not mounted. Stopping download services." >> /var/log/check-download-mounts.log
            systemctl stop deluge
        fi
        '';
        onChange = ''
        chmod 0755 ~/.local/bin/check-donwload-mounts.sh
        '';
    };
    # Check mounts and turn on/off services
    ".local/bin/sonarr-on-download.sh" = {
        text = ''
        #!/bin/bash
        echo "Calling sonarr on download. Event type: $sonarr_evettype folder: $sonarr_episodefile_sourcefolder"
        if [ "$sonarr_eventtype" == "Test" ]; then
          echo "Sonarr event type is Test, exiting"
          exit 0
        fi
    
        pushd $sonarr_episodefile_sourcefolder
        rar_file=$(ls *.rar 2>/dev/null)
        if [ -z "$rar_file" ]; then
          echo "No rar file found in $sonarr_episodefile_sourcefolder"
          exit 1
        fi
        unrar x $rar_file
        popd
        '';
        onChange = ''
        chmod 0755 ~/.local/bin/sonarr-on-download.sh
        '';
    };
    # Jupyterlabs
    ".local/share/applications/jupyterlab-start.desktop" = {
      text = ''
        [Desktop Entry]
        Name=Start JupyterLab
        Comment=Start JupyterLab in Docker
        Exec=start-named-container jupyterlab -p 8888:8888 --user 1000:100 -v /home/iocanel/workspace/src/github.com/iocanel/jupyter-workspace:/home/jovyan/ jupyter/scipy-notebook start-notebook.sh --NotebookApp.token=""
        Icon=utilities-terminal
        Terminal=false
        Type=Application
        Categories=Development;
      '';
    };
    ".local/share/applications/jupyterlab-stop.desktop" = {
       text = ''
        [Desktop Entry]
        Name=Stop JupyterLab
        Comment=Stop JupyterLab in Docker
        Exec=stop-named-container jupyterlab
        Icon=utilities-terminal
        Terminal=false
        Type=Application
        Categories=Development;
      '';
    };
  };
}
