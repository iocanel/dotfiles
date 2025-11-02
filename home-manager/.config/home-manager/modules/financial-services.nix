{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.financial-services;
  
  # Firefly configuration paths
  fireflyConfigDir = "${cfg.configPath}/firefly";
  fireflyServerEnvPath = "${fireflyConfigDir}/server.env";
  fireflyImporterEnvPath = "${fireflyConfigDir}/importer.env";
in
{
  options.services.financial-services = {
    enable = mkEnableOption "financial services";
    
    configPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config";
      description = "Base path for service configurations";
    };
    
    firefly = {
      enable = mkEnableOption "Firefly III personal finance manager";
      
      serverPort = mkOption {
        type = types.int;
        default = 8090;
        description = "Port for Firefly III web interface";
      };
      
      importerPort = mkOption {
        type = types.int;
        default = 8091;
        description = "Port for Firefly III data importer";
      };
      
      serverImage = mkOption {
        type = types.str;
        default = "fireflyiii/core:latest";
        description = "Docker image for Firefly III server";
      };
      
      importerImage = mkOption {
        type = types.str;
        default = "fireflyiii/data-importer:latest";
        description = "Docker image for Firefly III data importer";
      };
      
      siteOwner = mkOption {
        type = types.str;
        default = "admin@example.com";
        description = "Site owner email for Firefly III";
      };
      
      networkName = mkOption {
        type = types.str;
        default = "firefly-net";
        description = "Docker network name for Firefly services";
      };
    };
  };
  
  config = mkIf cfg.enable {
    systemd.user.targets.financial-services = {
      Unit = {
        Description = "Financial Services";
        Wants = mkIf cfg.firefly.enable [
          "firefly-docker-network.service"
          "firefly-env-init.service"
          "firefly-iii.service"
          "firefly-importer.service"
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    systemd.user.services = mkMerge [
      (mkIf cfg.firefly.enable {
        firefly-docker-network = {
          Unit = {
            Description = "Firefly III Docker Network";
            PartOf = [ "financial-services.target" ];
          };
          Install = {
            WantedBy = [ "financial-services.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network create ${cfg.firefly.networkName} || ${pkgs.docker}/bin/docker network inspect ${cfg.firefly.networkName} >/dev/null'";
            ExecStop = "${pkgs.docker}/bin/docker network rm ${cfg.firefly.networkName}";
            RemainAfterExit = true;
          };
        };

        firefly-env-init = {
          Unit = {
            Description = "Generate Firefly III .env file if missing";
            ConditionPathExists = "!${fireflyServerEnvPath}";
            PartOf = [ "financial-services.target" ];
          };
          Install = {
            WantedBy = [ "financial-services.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "init-firefly-env" ''
              ${pkgs.coreutils}/bin/mkdir -p ${fireflyConfigDir}
              
              # Create server.env
              ${pkgs.coreutils}/bin/rm -f ${fireflyServerEnvPath}
              APP_KEY="base64:$(${pkgs.coreutils}/bin/head -c 32 /dev/urandom | ${pkgs.coreutils}/bin/base64)"
              echo "APP_KEY=$APP_KEY" >> ${fireflyServerEnvPath}
              echo "TRUSTED_PROXIES=**" >> ${fireflyServerEnvPath}
              echo "SITE_OWNER=${cfg.firefly.siteOwner}" >> ${fireflyServerEnvPath}
              echo "APP_URL=http://firefly-iii:8080" >> ${fireflyServerEnvPath}

              echo "DB_CONNECTION=sqlite" >> ${fireflyServerEnvPath}
              echo "DB_DATABASE=/var/www/html/storage/database/database.sqlite" >> ${fireflyServerEnvPath}
              chmod 600 ${fireflyServerEnvPath}

              # Create importer.env
              rm -f ${fireflyImporterEnvPath}
              echo "TRUSTED_PROXIES=**" > ${fireflyImporterEnvPath}
              echo "APP_URL=http://localhost:${toString cfg.firefly.serverPort}" >> ${fireflyImporterEnvPath}
              chmod 600 ${fireflyImporterEnvPath}

              # Initialize database file if needed
              ${pkgs.coreutils}/bin/mkdir -p ${fireflyConfigDir}/db
              ${pkgs.coreutils}/bin/touch ${fireflyConfigDir}/db/database.sqlite
              chmod -R 775 ${fireflyConfigDir}/db
              chgrp -R www-data ${fireflyConfigDir}/db || true

              ${pkgs.coreutils}/bin/mkdir -p ${fireflyConfigDir}/export
              chmod -R 775 ${fireflyConfigDir}/export
              chgrp -R www-data ${fireflyConfigDir}/export || true

              ${pkgs.coreutils}/bin/mkdir -p ${fireflyConfigDir}/upload
              chmod -R 775 ${fireflyConfigDir}/upload
              chgrp -R www-data ${fireflyConfigDir}/upload || true
            '';
          };
        };

        firefly-iii = {
          Unit = {
            Description = "Firefly III Personal Finance Manager";
            After = [ "docker.service" "firefly-docker-network.service" "firefly-env-init.service" ];
            Requires = [ "firefly-docker-network.service" "firefly-env-init.service" ];
            PartOf = [ "financial-services.target" ];
          };
          Install = {
            WantedBy = [ "financial-services.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = ''
              ${pkgs.docker}/bin/docker run --rm --name firefly-iii \
                --env-file=${fireflyServerEnvPath} \
                --network ${cfg.firefly.networkName} \
                -p ${toString cfg.firefly.serverPort}:8080 \
                -v ${fireflyConfigDir}/export:/var/www/html/storage/export \
                -v ${fireflyConfigDir}/upload:/var/www/html/storage/upload \
                -v ${fireflyConfigDir}/db:/var/www/html/storage/database \
                ${cfg.firefly.serverImage}
            '';
            ExecStop = ''
              ${pkgs.docker}/bin/docker kill firefly-iii || true
              ${pkgs.docker}/bin/docker rm -f firefly-iii || true
            '';
            RemainAfterExit = true;
          };
        };

        firefly-importer = {
          Unit = {
            Description = "Firefly III Data Importer";
            After = [ "docker.service" "firefly-docker-network.service" "firefly-iii.service" ];
            PartOf = [ "financial-services.target" ];
          };
          Install = {
            WantedBy = [ "financial-services.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = ''
              ${pkgs.docker}/bin/docker run --rm --name firefly-importer \
                --env-file=${fireflyImporterEnvPath} \
                --network ${cfg.firefly.networkName} \
                -p ${toString cfg.firefly.importerPort}:8080 \
                ${cfg.firefly.importerImage}
            '';
            ExecStop = ''
              ${pkgs.docker}/bin/docker kill firefly-importer || true
              ${pkgs.docker}/bin/docker rm -f firefly-importer || true
            '';
            RemainAfterExit = true;
          };
        };
      })
    ];
  };
}