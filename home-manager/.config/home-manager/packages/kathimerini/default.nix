{ pkgs
, lib ? pkgs.lib
, kathimeriniSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/kathimerini.gr
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  kathimeriniCli = pkgs.writeShellScriptBin "kathimerini" ''
    cd ${kathimeriniSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

  kathimeriniMcp = pkgs.writeShellScriptBin "kathimerini-mcp" ''
    cd ${kathimeriniSrc}
    exec ${nodejs}/bin/node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "kathimerini-${version}";
  paths = [ kathimeriniCli kathimeriniMcp ];

  meta = with lib; {
    description = "CLI and MCP server for Kathimerini.gr Greek news scrapper";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "kathimerini";
    maintainers = [];
  };
}
