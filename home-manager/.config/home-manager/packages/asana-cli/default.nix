{ pkgs
, lib ? pkgs.lib
, asanaSrc ? /home/iocanel/workspace/src/gitserver.silensec.com/iocanel/asana-client
, version ? "0.1-SNAPSHOT"
}:

let
  binaryName = "asana-cli-${version}-runner";
  binaryPath = "${asanaSrc}/cli/target/${binaryName}";

  asanaWrapper = pkgs.writeShellScriptBin "asana" ''
    exec ${binaryPath} "$@"
  '';

in
pkgs.symlinkJoin {
  name = "asana-cli-${version}";
  paths = [ asanaWrapper ];

  meta = with lib; {
    description = "Asana CLI client with MCP server support";
    homepage = "https://gitserver.silensec.com/iocanel/asana-client";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "asana";
    maintainers = [];
  };
}
