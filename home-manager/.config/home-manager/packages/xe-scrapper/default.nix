{ pkgs
, lib ? pkgs.lib
, xeSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/xe.gr
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  xeCli = pkgs.writeShellScriptBin "xe-property" ''
    cd ${xeSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

  xeMcp = pkgs.writeShellScriptBin "xe-property-mcp" ''
    cd ${xeSrc}
    exec ${nodejs}/bin/node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "xe-scrapper-${version}";
  paths = [ xeCli xeMcp ];

  meta = with lib; {
    description = "CLI and MCP server for xe.gr property listings";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "xe-property";
    maintainers = [];
  };
}
