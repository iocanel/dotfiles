{ pkgs
, lib ? pkgs.lib
, clickatlifeSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/clickatlife.gr
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  clickatlifeCli = pkgs.writeShellScriptBin "clickatlife" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${clickatlifeSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

  clickatlifeMcp = pkgs.writeShellScriptBin "clickatlife-mcp" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${clickatlifeSrc}
    exec ${nodejs}/bin/node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "clickatlife-scrapper-${version}";
  paths = [ clickatlifeCli clickatlifeMcp ];

  meta = with lib; {
    description = "CLI and MCP server for clickatlife.gr - Greek lifestyle and entertainment guide";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "clickatlife";
    maintainers = [];
  };
}
