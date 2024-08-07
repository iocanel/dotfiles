{ config, pkgs, lib, ... }:

with lib;

let
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
    tor-browser
    qutebrowser
    # Media
    vocal
    newsflash
    obs-studio
    kdenlive
    ombi
    geeqie
    digikam
    # Sharing
    dropbox
    # Communication
    zulip
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
    #
    # CLI
    #
    kubectl
    openshift
    kind
    k9s
    resumed
    hugo
    jq
    yq
    yt-dlp
    #
    # Development
    #
    # C
    cmake
    libtool
    # Java
    maven
    gradle
    temurin-bin-21
    jbang
    quarkus
    openapi-generator-cli
    jetbrains.idea-community-bin

    # Javascript
    nodejs
    nodejs_18
    yarn-berry
    node2nix
    # Python
    python312
    poetry
    # Rust
	  rustup
    # Go
    go
    #
    # Productivity
    #
    obsidian
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
    #
    # Deamons and Services
    dunst
    # Requirement for home manager config scripts
    gettext
    hexdump
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
  export PATH=$HOME/bin:/run/wrappers/bin:/home/iocanel/.nix-profile/bin:/nix/profile/bin:/home/iocanel/.local/state/nix/profile/bin:/etc/profiles/per-user/iocanel/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin

  #
  # Recreate profile
  #
  echo "# .profile: generated, do not edit by hand." > $HOME/.profile
  echo "export OPENAI_API_KEY=$OPENAI_API_KEY" >> $HOME/.profile
  echo "export PATH=$PATH" >> $HOME/.profile
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
      };
      interactiveShellInit = ''
      # Let's load the .profile file
      if test -f ~/.profile
        source ~/.profile
      end
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
            Type = "simple";
            ExecStart = "${pkgs.isync}/bin/mbsync -a";
            Restart = "always";
          };
        
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
            OnCalendar = "minutely";
            Persistent = true;
            Unit = "sync-email.service";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };

      };
    };
  };
}
