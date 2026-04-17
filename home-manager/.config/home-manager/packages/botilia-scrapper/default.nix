{ pkgs
, lib ? pkgs.lib
, botiliaSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/botilia.gr
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  botiliaCli = pkgs.writeShellScriptBin "botilia" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${botiliaSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

  botiliaMcp = pkgs.writeShellScriptBin "botilia-mcp" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${botiliaSrc}
    exec ${nodejs}/bin/node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "botilia-scrapper-${version}";
  paths = [ botiliaCli botiliaMcp ];

  meta = with lib; {
    description = "CLI and MCP server for botilia.gr - Wine and spirits e-shop";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "botilia";
    maintainers = [];
  };
}
