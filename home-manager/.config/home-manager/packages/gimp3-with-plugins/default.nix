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
Run GIMP from this command so the correct Python & GI are on PATH.
EOF

    exec '${gimpPkg}/bin/gimp-3' "$@"
  '';

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
    ];
  };
in
  gimp3WithPluginsEnv
