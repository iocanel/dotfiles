{ pkgs
, lib ? pkgs.lib
, villagecinemasSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/villagecinemas.gr
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  villagecinemasCli = pkgs.writeShellScriptBin "villagecinemas" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${villagecinemasSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

  villagecinemasMcp = pkgs.writeShellScriptBin "villagecinemas-mcp" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${villagecinemasSrc}
    exec ${nodejs}/bin/node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "villagecinemas-scrapper-${version}";
  paths = [ villagecinemasCli villagecinemasMcp ];

  meta = with lib; {
    description = "CLI and MCP server for villagecinemas.gr - Village Cinemas Greece";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "villagecinemas";
    maintainers = [];
  };
}
