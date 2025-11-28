{ pkgs ? import <nixpkgs> {} }:

let
  # Python runtime we want for GIMP plugins; NOT added to home.packages directly here.
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    pycairo
    pygobject3
    requests
    pillow
    certifi
    urllib3
    idna
  ]);

  gimpPkg = pkgs.gimp3-with-plugins;

  gimpPlugBase = "$HOME/.config/GIMP/3.0/plug-ins";
  gimpAiDir    = "${gimpPlugBase}/gimp-ai-plugin";

  # Wrapper that installs/refreshes the plugin and launches GIMP,
  # exporting env so the plugin sees the right Python + GI.
  gimpAiWrapper = pkgs.writeShellScriptBin "gimp-ai" ''
    set -euo pipefail

    # Make our Python env take precedence WITHOUT adding it to the profile (avoids collisions)
    export PATH='${pythonEnv}/bin':"$PATH"
    # If you prefer, also expose site-packages explicitly:
    # export PYTHONPATH='${pythonEnv}/lib/python3.12/site-packages':"$PYTHONPATH"

    export SSL_CERT_FILE='${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt'
    export GIMP_USER_PLUGIN_DIR="${gimpPlugBase}"
    export GI_TYPELIB_PATH='${gimpPkg}/lib/girepository-1.0:${pkgs.gtk3}/lib/girepository-1.0'

    echo "[gimp-ai] Plugin dir: ${gimpAiDir}"
    mkdir -p "${gimpAiDir}"

    # Check if plugins are already installed and up to date
    if [ -d "${gimpAiDir}" ] && [ "$(find "${gimpAiDir}" -name '*.py' | wc -l)" -gt 0 ]; then
      echo "[gimp-ai] Plugins already installed in ${gimpAiDir}"
      echo "[gimp-ai] Use --force or delete the directory to reinstall"
      
      # Check if user wants to force reinstall
      if [ "$${1:-}" != "--force" ] && [ "$${1:-}" != "-f" ]; then
        echo "[gimp-ai] Starting GIMP with existing plugins..."
        exec '${gimpPkg}/bin/gimp-3' "$@"
      else
        echo "[gimp-ai] Force reinstall requested, removing existing plugins..."
        rm -rf "${gimpAiDir}"/*.py 2>/dev/null || true
        shift # remove the --force flag from arguments
      fi
    fi

    tmpdir="$(mktemp -d -t gimp-ai-XXXXXX)"
    trap 'rm -rf "$tmpdir"' EXIT

    echo "[gimp-ai] Cloning lukaso/gimp-ai (SSH)…"
    if ! git clone --depth 1 git@github.com:lukaso/gimp-ai.git "$tmpdir/repo"; then
      echo "SSH clone failed. Try: ssh -T git@github.com" >&2
      exit 1
    fi

    cd "$tmpdir/repo"

    echo "[gimp-ai] Extracting .py file names from README…"
    pylist="$(grep -oE '\b[[:alnum:]_./-]+\.py\b' README* 2>/dev/null | sort -u || true)"
    if [ -z "$pylist" ]; then
      echo "No .py listed in README; falling back to top-level *.py"
      pylist="$(find . -maxdepth 1 -type f -name '*.py' -printf '%P\n' | sort -u || true)"
    fi
    [ -z "$pylist" ] && { echo "No .py files to install"; exit 1; }

    echo "[gimp-ai] Installing to ${gimpAiDir}:"
    echo "$pylist" | while read -r f; do
      [ -z "$f" ] && continue
      src="$tmpdir/repo/$f"
      [ -f "$src" ] || { echo "  (skip) $f"; continue; }
      dest="${gimpAiDir}/$(basename "$f")"
      echo "  -> $dest"
      install -m 0755 "$src" "$dest"
      sed -i '1s@^#!.*@#!/usr/bin/env python3@' "$dest" || true
      chmod +x "$dest" || true
    done

    # Optional: clean older stray files
    find "${gimpPlugBase}" -maxdepth 1 -type f -name 'gimp-ai-*.py' -delete 2>/dev/null || true

    cat <<'EOF'

✅ gimp-ai installed under: ~/.config/GIMP/3.0/plug-ins/gimp-ai-plugin/

🔧 Configuration Options:
• OpenAI: Use your OpenAI API key

Configure via: Filters → AI → Settings in GIMP
EOF

    exec '${gimpPkg}/bin/gimp-3' "$@"
  '';

  # Desktop entry for gimp-ai
  gimpAiDesktop = pkgs.writeTextFile {
    name = "gimp-ai.desktop";
    destination = "/share/applications/gimp-ai.desktop";
    text = ''
      [Desktop Entry]
      Name=GIMP with AI
      GenericName=AI-Enhanced Image Editor
      Comment=GNU Image Manipulation Program with AI plugins
      Exec=${gimpAiWrapper}/bin/gimp-ai %U
      Icon=gimp
      StartupNotify=true
      MimeType=image/bmp;image/g3fax;image/gif;image/x-fits;image/x-pcx;image/x-portable-anymap;image/x-portable-bitmap;image/x-portable-graymap;image/x-portable-pixmap;image/x-psd;image/x-sgi;image/x-tga;image/x-xbitmap;image/x-xwindowdump;image/x-xcf;image/x-compressed-xcf;image/x-gimp-gbr;image/x-gimp-pat;image/x-gimp-gih;image/x-sun-raster;image/tiff;image/jpeg;image/x-psp;image/png;image/x-icon;image/x-xpixmap;image/svg+xml;image/x-wmf;image/jp2;image/jpeg2000;image/jpx;image/x-xcursor;
      Terminal=false
      Type=Application
      Categories=Graphics;2DGraphics;RasterGraphics;GTK;
      X-GNOME-Bugzilla-Bugzilla=GNOME
      X-GNOME-Bugzilla-Product=GIMP
      X-GNOME-Bugzilla-Component=General
      X-GNOME-Bugzilla-Version=3.0
    '';
  };

  # IMPORTANT: do NOT include `pythonEnv` here — that caused the collision.
  gimp3WithPluginsEnv = pkgs.symlinkJoin {
    name = "gimp3-with-plugins-env";
    paths = [
      gimpPkg
      pkgs.git pkgs.openssh
      pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.findutils
      pkgs.gobject-introspection pkgs.gtk3
      pkgs.cacert
      gimpAiWrapper
      gimpAiDesktop
    ];
  };
in
  gimp3WithPluginsEnv
