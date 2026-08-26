# home-manager module for the mpd-hykr podcast progress watcher.
#
# Runs mpd-hykr-watch as a user service so playback position is recorded even
# when the picker is never reopened, which is what makes "Resume" work.
#
# Kept in sync with nix/watcher.nix in
# ~/workspace/src/github.com/iocanel/mpd-hykr, which is the upstream copy.
# mpd-hykr itself is installed with "just install" rather than by nix, so this
# module owns only the unit, not the script.
{ config, lib, pkgs, ... }:

let
  cfg = config.services.mpd-hykr-watch;
in
{
  options.services.mpd-hykr-watch = {
    enable = lib.mkEnableOption "mpd-hykr podcast progress watcher";

    command = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/bin/mpd-hykr-watch";
      description = ''
        Path to the mpd-hykr-watch executable. Defaults to where
        "just install" puts it.
      '';
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.stateHome}/mpd-hykr";
      description = "Where per-feed playback progress is written.";
    };

    saveInterval = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = ''
        Seconds between checkpoints while playing. Pause and track changes are
        recorded immediately regardless, so this only bounds how much is lost
        if the machine stops without a clean pause.
      '';
    };

    minElapsed = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = ''
        Episodes stopped before this many seconds are treated as unstarted and
        not offered for resume.
      '';
    };

    doneRatio = lib.mkOption {
      type = lib.types.float;
      default = 0.98;
      description = ''
        Fraction of an episode past which it counts as finished and is
        forgotten rather than offered again.
      '';
    };

    mpd = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
        description = "MPD host to follow.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 6600;
        description = "MPD port to follow.";
      };
    };

    target = lib.mkOption {
      type = lib.types.str;
      default = "hyprland-session.target";
      description = ''
        Unit the watcher is bound to. Home-manager relinks units during login
        activation, after default.target has already been reached, so binding
        to the compositor's session target is what makes it start reliably on
        every login rather than sitting enabled-but-not-started.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.mpd-hykr-watch = {
      Unit = {
        Description = "mpd-hykr podcast progress watcher";
        After = [ "mpd.service" cfg.target ];
        PartOf = [ cfg.target ];
      };

      Service = {
        Type = "simple";
        ExecStart = cfg.command;
        Environment = [
          "PODCAST_STATE_DIR=${cfg.stateDir}"
          "PODCAST_SAVE_INTERVAL=${toString cfg.saveInterval}"
          "PODCAST_MIN_ELAPSED=${toString cfg.minElapsed}"
          "PODCAST_DONE_RATIO=${toString cfg.doneRatio}"
          "MPD_HOST=${cfg.mpd.host}"
          "MPD_PORT=${toString cfg.mpd.port}"
        ];
        # The watcher reconnects on its own, so a restart here is only for the
        # cases it cannot recover from.
        Restart = "always";
        RestartSec = 5;
      };

      Install.WantedBy = [ cfg.target ];
    };

    # python3 is what the watcher runs on, and a compositor-launched unit does
    # not get the login shell's PATH.
    home.packages = [ pkgs.python3 ];
  };
}
