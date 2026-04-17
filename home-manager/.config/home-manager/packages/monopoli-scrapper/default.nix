{ pkgs
, lib ? pkgs.lib
, version ? "0.1.0"
}:

let
  # Use string path to avoid nix copying to store (allows local updates)
  monopoliSrc = "/home/iocanel/workspace/src/github.com/iocanel/scrappers/monopoli.gr";

  # Uses 'node' from PATH to match the node_modules build
  monopoliCli = pkgs.writeShellScriptBin "monopoli" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${monopoliSrc}
    exec node dist/cli.js "$@"
  '';

  monopoliMcp = pkgs.writeShellScriptBin "monopoli-mcp" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${monopoliSrc}
    exec node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "monopoli-scrapper-${version}";
  paths = [ monopoliCli monopoliMcp ];

  meta = with lib; {
    description = "CLI and MCP server for monopoli.gr - Athens cultural and entertainment guide";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "monopoli";
    maintainers = [];
  };
}
