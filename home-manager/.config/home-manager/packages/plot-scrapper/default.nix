{ pkgs
, lib ? pkgs.lib
, plotSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/plot.gr
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  # plot.gr fingerprints the TLS handshake and rejects Node's HTTP client, so
  # the scrapper shells out to curl and needs it on PATH.
  runtimePath = lib.makeBinPath [ pkgs.curl ];

  plotCli = pkgs.writeShellScriptBin "plot-property" ''
    export PATH=${runtimePath}:$PATH
    cd ${plotSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

  plotMcp = pkgs.writeShellScriptBin "plot-property-mcp" ''
    export PATH=${runtimePath}:$PATH
    cd ${plotSrc}
    exec ${nodejs}/bin/node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "plot-scrapper-${version}";
  paths = [ plotCli plotMcp ];

  meta = with lib; {
    description = "CLI and MCP server for plot.gr property listings";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "plot-property";
    maintainers = [];
  };
}
