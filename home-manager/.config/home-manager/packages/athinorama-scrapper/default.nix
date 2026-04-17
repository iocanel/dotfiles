{ pkgs
, lib ? pkgs.lib
, athinoramaSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/athinorama.gr
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  athinoramaCli = pkgs.writeShellScriptBin "athinorama" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${athinoramaSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

  athinoramaMcp = pkgs.writeShellScriptBin "athinorama-mcp" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${athinoramaSrc}
    exec ${nodejs}/bin/node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "athinorama-scrapper-${version}";
  paths = [ athinoramaCli athinoramaMcp ];

  meta = with lib; {
    description = "CLI and MCP server for athinorama.gr - Athens entertainment guide";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "athinorama";
    maintainers = [];
  };
}
