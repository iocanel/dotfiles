{ pkgs
, lib ? pkgs.lib
, remaxSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/remax.gr
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  remaxCli = pkgs.writeShellScriptBin "remax-property" ''
    cd ${remaxSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

  remaxMcp = pkgs.writeShellScriptBin "remax-property-mcp" ''
    cd ${remaxSrc}
    exec ${nodejs}/bin/node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "remax-scrapper-${version}";
  paths = [ remaxCli remaxMcp ];

  meta = with lib; {
    description = "CLI and MCP server for remax.gr property listings";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "remax-property";
    maintainers = [];
  };
}
