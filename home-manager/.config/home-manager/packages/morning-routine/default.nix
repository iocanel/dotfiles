{ pkgs
, lib ? pkgs.lib
, version ? "0.1.0"
, org-cli
, glab-mr-tracker
}:

let
  python = pkgs.python3.withPackages (ps: with ps; [
    requests
    beautifulsoup4
    pdfkit
    pypdf
  ]);

  templateDir = ./templates;

  dailyPlanner = pkgs.stdenv.mkDerivation {
    pname = "daily-planner";
    inherit version;

    src = ./scripts;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin $out/share/morning-routine
      cp ${templateDir}/daily-planner.html $out/share/morning-routine/

      cat > $out/bin/daily-planner << 'SCRIPT'
      #!${python}/bin/python3
      SCRIPT
      cat daily-planner.py >> $out/bin/daily-planner
      chmod +x $out/bin/daily-planner

      wrapProgram $out/bin/daily-planner \
        --set DAILY_PLANNER_TEMPLATE "$out/share/morning-routine/daily-planner.html" \
        --prefix PATH : ${lib.makeBinPath [ org-cli glab-mr-tracker pkgs.wkhtmltopdf ]}
    '';

    meta = with lib; {
      description = "Daily planner PDF generator for Supernote";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  kathimerini = pkgs.stdenv.mkDerivation {
    pname = "kathimerini";
    inherit version;

    src = ./scripts;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin

      cat > $out/bin/kathimerini << 'SCRIPT'
      #!${python}/bin/python3
      SCRIPT
      cat kathimerini.py >> $out/bin/kathimerini
      chmod +x $out/bin/kathimerini

      wrapProgram $out/bin/kathimerini \
        --set WKHTMLTOPDF_PATH "${pkgs.wkhtmltopdf}/bin/wkhtmltopdf" \
        --prefix PATH : ${lib.makeBinPath [ pkgs.wkhtmltopdf ]}
    '';

    meta = with lib; {
      description = "Kathimerini news fetcher";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  morningRoutine = pkgs.writeShellScriptBin "morning-routine" ''
    set -euo pipefail

    TODAY=$(date +%Y-%m-%d)
    DAILY_PDF="/tmp/daily-''${TODAY}.pdf"
    NEWS_PDF="/tmp/kathimerini-''${TODAY}.pdf"

    SUPERNOTE_DAILY_DIR="$HOME/.google/drive/Supernote/Document/Daily"
    SUPERNOTE_NEWS_DIR="$HOME/.google/drive/Supernote/Document/News"

    log() {
        echo "[$(date '+%H:%M:%S')] $*"
    }

    generate_daily_planner() {
        log "Generating daily planner..."
        if ${dailyPlanner}/bin/daily-planner run --output "$DAILY_PDF"; then
            log "Daily planner generated: $DAILY_PDF"
            return 0
        else
            log "ERROR: Failed to generate daily planner"
            return 1
        fi
    }

    fetch_news() {
        log "Fetching news from Kathimerini..."
        if ${kathimerini}/bin/kathimerini fetch --format pdf --output "$NEWS_PDF" --limit 10; then
            log "News PDF generated: $NEWS_PDF"
            return 0
        else
            log "ERROR: Failed to fetch news"
            return 1
        fi
    }

    upload_to_supernote() {
        log "Uploading files to Supernote..."

        mkdir -p "$SUPERNOTE_DAILY_DIR" "$SUPERNOTE_NEWS_DIR"

        if [[ -f "$DAILY_PDF" ]]; then
            cp "$DAILY_PDF" "$SUPERNOTE_DAILY_DIR/"
            log "Uploaded: $SUPERNOTE_DAILY_DIR/$(basename "$DAILY_PDF")"
        fi

        if [[ -f "$NEWS_PDF" ]]; then
            cp "$NEWS_PDF" "$SUPERNOTE_NEWS_DIR/"
            log "Uploaded: $SUPERNOTE_NEWS_DIR/$(basename "$NEWS_PDF")"
        fi
    }

    main() {
        log "=== Morning Routine Starting ==="

        local failed=0

        generate_daily_planner || failed=1
        fetch_news || failed=1

        if [[ $failed -eq 0 ]]; then
            upload_to_supernote
            log "=== Morning Routine Complete ==="
        else
            log "=== Morning Routine Completed with Errors ==="
            exit 1
        fi
    }

    main "$@"
  '';

in
pkgs.symlinkJoin {
  name = "morning-routine-${version}";
  paths = [ dailyPlanner kathimerini morningRoutine ];

  meta = with lib; {
    description = "Morning routine scripts: daily planner and news fetcher for Supernote";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "morning-routine";
  };
}
