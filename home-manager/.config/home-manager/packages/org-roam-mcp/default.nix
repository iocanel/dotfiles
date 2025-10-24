{ pkgs
, commandName ? "org-roam-mcp"
, orgDir ? "$HOME/Documents/org/roam"
, dbPath ? null
, extraArgs ? [ ]
, env ? {}
, fromSpec ? "git+https://github.com/iocanel/org-roam-mcp@main"
}:

let
  lib = pkgs.lib;

  exportEnv =
    lib.concatStringsSep "\n"
      (lib.mapAttrsToList (n: v: ''export ${n}="${v}"'') env);

  extraArgsStr = lib.concatStringsSep " " (map lib.escapeShellArg extraArgs);
  dbFlag = if dbPath == null then "" else "--db " + lib.escapeShellArg (toString dbPath);
in
pkgs.stdenv.mkDerivation {
  pname = commandName;
  version = "wrapper-git";

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p "$out/bin"
    cat > "$out/bin/${commandName}" <<'EOF'
    #!${pkgs.bash}/bin/bash
    set -eo pipefail

    # Optional env from Nix:
    ${exportEnv}

    # Default UV cache dir if not provided:
    if [ -z "$UV_CACHE_DIR" ]; then
      if [ -n "$XDG_CACHE_HOME" ]; then
        UV_CACHE_DIR="$XDG_CACHE_HOME/uv"
      else
        UV_CACHE_DIR="$HOME/.cache/uv"
      fi
      export UV_CACHE_DIR
    fi
    mkdir -p "$UV_CACHE_DIR"

    # Run the module (avoids broken console-script)
    exec ${pkgs.uv}/bin/uvx \
      --from ${lib.escapeShellArg fromSpec} \
      python -m org_roam_mcp.server \
      --root "${orgDir}" \
      ${dbFlag} \
      ${extraArgsStr} \
      "$@"
    EOF
    chmod +x "$out/bin/${commandName}"
  '';

  meta = with lib; {
    description = "Wrapper that runs org-roam-mcp via uvx (Git source, module entry)";
    platforms   = platforms.unix;
    homepage    = "https://github.com/iocanel/org-roam-mcp";
    license     = licenses.mit;
    mainProgram = commandName;
  };
}
