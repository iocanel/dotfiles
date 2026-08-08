{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.realestate;

  runner = "${config.home.homeDirectory}/.claude/assistant/projects/realestate/daily-search.sh";
in
{
  options.services.realestate = {
    enable = mkEnableOption "daily Greek property opportunity search";

    config = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.claude/assistant/projects/realestate/searches.json";
      description = "Saved searches to run.";
    };

    onCalendar = mkOption {
      type = types.str;
      default = "*-*-* 08:00:00";
      description = "When to run the daily search.";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.realestate-daily = {
      Unit = {
        Description = "Daily Greek property opportunity search";
        After = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        # jq drives the config, curl is the transport plot.gr requires, and the
        # scrappers run from their build output under the workspace checkout.
        Environment = [
          "PATH=${lib.makeBinPath [ pkgs.bash pkgs.coreutils pkgs.jq pkgs.curl pkgs.nodejs_20 ]}"
        ];
        ExecStart = "${pkgs.bash}/bin/bash ${runner} ${cfg.config}";
      };
    };

    systemd.user.timers.realestate-daily = {
      Unit.Description = "Daily Greek property opportunity search";
      Timer = {
        OnCalendar = cfg.onCalendar;
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
