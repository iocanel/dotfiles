{ pkgs
, lib ? pkgs.lib
, airbnbSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/airbnb.com
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  airbnbCli = pkgs.writeShellScriptBin "airbnb-stays" ''
    cd ${airbnbSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

  airbnbMcp = pkgs.writeShellScriptBin "airbnb-stays-mcp" ''
    cd ${airbnbSrc}
    exec ${nodejs}/bin/node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "airbnb-scrapper-${version}";
  paths = [ airbnbCli airbnbMcp ];

  meta = with lib; {
    description = "CLI and MCP server for airbnb.com stay listings";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "airbnb-stays";
    maintainers = [];
  };
}
