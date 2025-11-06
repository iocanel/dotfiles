{ config, pkgs, lib, ... }:

with lib;

let
  cfg = {
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

  # Common environment variables for all services
  commonEnv = {
    PUID = toString cfg.userId;
    PGID = toString cfg.groupId;
    TZ = cfg.timezone;
  };
  
  # Common paths
  mediaPaths = {
    config = cfg.configPath;
    media = cfg.mediaPath;
    downloads = cfg.downloadsPath;
  };
in
{
  options.services.media-center = {
    enable = mkEnableOption "media center services";
    
    userId = mkOption {
      type = types.int;
      default = 1000;
      description = "User ID for containers";
    };
    
    groupId = mkOption {
      type = types.int;
      default = 100;
      description = "Group ID for containers";
    };
    
    timezone = mkOption {
      type = types.str;
      default = "Europe/Athens";
      description = "Timezone for containers";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config";
      description = "Base path for service configurations";
    };
    
    mediaPath = mkOption {
      type = types.str;
      default = "/mnt/media";
      description = "Path to media storage";
    };
    
    downloadsPath = mkOption {
      type = types.str;
      default = "/mnt/downloads";
      description = "Path to downloads storage";
    };
    
    emby = {
      enable = mkEnableOption "Emby media server";
      port = mkOption {
        type = types.int;
        default = 8096;
        description = "Port for Emby web interface";
      };
      httpsPort = mkOption {
        type = types.int;
        default = 8920;
        description = "Port for Emby HTTPS interface";
      };
      image = mkOption {
        type = types.str;
        default = "emby/embyserver:4.9.0.26";
        description = "Docker image for Emby";
      };
      cpus = mkOption {
        type = types.str;
        default = "2";
        description = "CPU limit for container";
      };
      memory = mkOption {
        type = types.str;
        default = "4g";
        description = "Memory limit for container";
      };
    };
    
    sonarr = {
      enable = mkEnableOption "Sonarr TV series management";
      port = mkOption {
        type = types.int;
        default = 8989;
        description = "Port for Sonarr web interface";
      };
      image = mkOption {
        type = types.str;
        default = "lscr.io/linuxserver/sonarr:3.0.10";
        description = "Docker image for Sonarr";
      };
    };
    
    radarr = {
      enable = mkEnableOption "Radarr movie management";
      port = mkOption {
        type = types.int;
        default = 7878;
        description = "Port for Radarr web interface";
      };
      image = mkOption {
        type = types.str;
        default = "lscr.io/linuxserver/radarr:4.3.2";
        description = "Docker image for Radarr";
      };
    };
    
    bazarr = {
      enable = mkEnableOption "Bazarr subtitle management";
      port = mkOption {
        type = types.int;
        default = 6767;
        description = "Port for Bazarr web interface";
      };
      image = mkOption {
        type = types.str;
        default = "lscr.io/linuxserver/bazarr:1.1.2";
        description = "Docker image for Bazarr";
      };
    };
    
    readarr = {
      enable = mkEnableOption "Readarr book management";
      port = mkOption {
        type = types.int;
        default = 8787;
        description = "Port for Readarr web interface";
      };
      image = mkOption {
        type = types.str;
        default = "lscr.io/linuxserver/readarr:develop";
        description = "Docker image for Readarr";
      };
    };
    
    jackett = {
      enable = mkEnableOption "Jackett torrent indexer";
      port = mkOption {
        type = types.int;
        default = 9117;
        description = "Port for Jackett web interface";
      };
      image = mkOption {
        type = types.str;
        default = "lscr.io/linuxserver/jackett:0.22.1289";
        description = "Docker image for Jackett";
      };
    };
  };
  
  config = mkIf cfg.enable {
    systemd.user.targets.media-center = {
      Unit = {
        Description = "Media Center Services";
        Wants = [
          "emby-server.service"
          "sonarr.service" 
          "radarr.service"
          "bazarr.service"
          "readarr.service"
          "jackett.service"
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    systemd.user.services = mkMerge [
      (mkIf cfg.emby.enable {
        emby-server = {
          Unit = {
            Description = "Emby Server";
            PartOf = [ "media-center.target" ];
          };
          Install = {
            WantedBy = [ "media-center.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = ''
              ${pkgs.docker}/bin/docker run --rm --name emby-server \
              -e UID=${toString cfg.userId} \
              -e GUID=${toString cfg.groupId} \
              -e GIDLIST=${toString cfg.groupId} \
              -p ${toString cfg.emby.port}:8096 \
              -p ${toString cfg.emby.httpsPort}:8920 \
              -v ${cfg.configPath}/emby/:/config \
              -v ${cfg.mediaPath}:${cfg.mediaPath} \
              --cpus=${cfg.emby.cpus} \
              --memory=${cfg.emby.memory} \
              ${cfg.emby.image}
            '';
            ExecStop = "${pkgs.docker}/bin/docker kill emby-server && ${pkgs.docker}/bin/docker rm -f emby-server";
            RemainAfterExit = true;
          };
        };
      })
      
      (mkIf cfg.sonarr.enable {
        sonarr = {
          Unit = {
            Description = "Sonarr Service";
            PartOf = [ "media-center.target" ];
          };
          Install = {
            WantedBy = [ "media-center.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = ''
              ${pkgs.docker}/bin/docker run --rm --name sonarr \
              -e PUID=${toString cfg.userId} \
              -e PGID=${toString cfg.groupId} \
              -e TZ=${cfg.timezone} \
              -p ${toString cfg.sonarr.port}:8989 \
              -v ${cfg.configPath}/sonarr:/config \
              -v ${cfg.mediaPath}:${cfg.mediaPath} \
              -v ${cfg.downloadsPath}:/downloads \
              ${cfg.sonarr.image}
            '';
            ExecStop = "${pkgs.docker}/bin/docker kill sonarr && ${pkgs.docker}/bin/docker rm -f sonarr";
            RemainAfterExit = true;
          };
        };
      })
      
      (mkIf cfg.radarr.enable {
        radarr = {
          Unit = {
            Description = "Radarr Service";
            PartOf = [ "media-center.target" ];
          };
          Install = {
            WantedBy = [ "media-center.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = ''
              ${pkgs.docker}/bin/docker run --rm --name radarr \
              -e PUID=${toString cfg.userId} \
              -e PGID=${toString cfg.groupId} \
              -e TZ=${cfg.timezone} \
              -p ${toString cfg.radarr.port}:7878 \
              -v ${cfg.configPath}/radarr:/config \
              -v ${cfg.mediaPath}:${cfg.mediaPath} \
              -v ${cfg.downloadsPath}:/downloads \
              ${cfg.radarr.image}
            '';
            ExecStop = "${pkgs.docker}/bin/docker kill radarr && ${pkgs.docker}/bin/docker rm -f radarr";
            RemainAfterExit = true;
          };
        };
      })
      
      (mkIf cfg.bazarr.enable {
        bazarr = {
          Unit = {
            Description = "Bazarr Service";
            PartOf = [ "media-center.target" ];
          };
          Install = {
            WantedBy = [ "media-center.target" ];
          };
          Service = {
            Type = "simple";
            ExecStartPre = "${pkgs.docker}/bin/docker rm -f bazarr || true";
            ExecStart = ''
              ${pkgs.docker}/bin/docker run --rm --name bazarr \
              -e PUID=${toString cfg.userId} \
              -e PGID=${toString cfg.groupId} \
              -e TZ=${cfg.timezone} \
              -p ${toString cfg.bazarr.port}:6767 \
              -v ${cfg.configPath}/bazarr:/config \
              -v ${cfg.mediaPath}:${cfg.mediaPath} \
              -v ${cfg.downloadsPath}:/downloads \
              ${cfg.bazarr.image}
            '';
            ExecStop = "${pkgs.docker}/bin/docker stop bazarr || true";
            ExecStopPost = "${pkgs.docker}/bin/docker rm -f bazarr || true";
            RemainAfterExit = true;
          };
        };
      })
      
      (mkIf cfg.readarr.enable {
        readarr = {
          Unit = {
            Description = "Readarr Service";
            PartOf = [ "media-center.target" ];
          };
          Install = {
            WantedBy = [ "media-center.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = ''
              ${pkgs.docker}/bin/docker run --rm --name readarr \
              -e PUID=${toString cfg.userId} \
              -e PGID=${toString cfg.groupId} \
              -e TZ=${cfg.timezone} \
              -p ${toString cfg.readarr.port}:8787 \
              -v ${cfg.configPath}/readarr:/config \
              -v ${cfg.mediaPath}:${cfg.mediaPath} \
              -v ${cfg.downloadsPath}:/downloads \
              ${cfg.readarr.image}
            '';
            ExecStop = "${pkgs.docker}/bin/docker kill readarr && ${pkgs.docker}/bin/docker rm -f readarr";
            RemainAfterExit = true;
          };
        };
      })
      
      (mkIf cfg.jackett.enable {
        jackett = {
          Unit = {
            Description = "Jackett Service";
            PartOf = [ "media-center.target" ];
          };
          Install = {
            WantedBy = [ "media-center.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = ''
              ${pkgs.docker}/bin/docker run --rm --name jackett \
              -e PUID=${toString cfg.userId} \
              -e PGID=${toString cfg.groupId} \
              -e TZ=${cfg.timezone} \
              -p ${toString cfg.jackett.port}:9117 \
              -v ${cfg.configPath}/jackett:/config \
              -v ${cfg.mediaPath}:${cfg.mediaPath} \
              -v ${cfg.downloadsPath}:/downloads \
              ${cfg.jackett.image}
            '';
            ExecStop = "${pkgs.docker}/bin/docker kill jackett && ${pkgs.docker}/bin/docker rm -f jackett";
            RemainAfterExit = true;
          };
        };
      })
    ];
  };
  home.file = {
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
  };
}
