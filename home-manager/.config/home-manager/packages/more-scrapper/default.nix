{ pkgs
, lib ? pkgs.lib
, moreSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/more.com
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  moreCli = pkgs.writeShellScriptBin "more" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${moreSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

  moreMcp = pkgs.writeShellScriptBin "more-mcp" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${moreSrc}
    exec ${nodejs}/bin/node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "more-scrapper-${version}";
  paths = [ moreCli moreMcp ];

  meta = with lib; {
    description = "CLI and MCP server for more.com - Greece's ticketing platform for events";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "more";
    maintainers = [];
  };
}
