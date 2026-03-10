{ pkgs
, commandName ? "org-mcp"
}:

let
  lib = pkgs.lib;
  flake = builtins.getFlake "github:iocanel/org-mcp/main";
  org-mcp = flake.packages.${pkgs.system}.default;
in
pkgs.stdenv.mkDerivation {
  pname = commandName;
  version = "wrapper";

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p "$out/bin"
    ln -s "${org-mcp}/bin/org-mcp" "$out/bin/${commandName}"
  '';

  meta = with lib; {
    description = "MCP server for org-mode and org-roam integration";
    platforms   = platforms.unix;
    homepage    = "https://github.com/iocanel/org-mcp";
    license     = licenses.asl20;
    mainProgram = commandName;
  };
}
