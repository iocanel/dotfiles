{ pkgs
, lib ? pkgs.lib
, outlookMcpSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/outlook.com
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  outlookCli = pkgs.writeShellScriptBin "outlook" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${outlookMcpSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "outlook-mcp-${version}";
  paths = [ outlookCli ];

  meta = with lib; {
    description = "CLI and MCP server for Outlook calendar and email via browser automation";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "outlook";
    maintainers = [];
  };
}
