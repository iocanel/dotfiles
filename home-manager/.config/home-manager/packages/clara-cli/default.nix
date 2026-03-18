{ pkgs
, lib ? pkgs.lib
, claraSrc ? /home/iocanel/workspace/src/gitserver.silensec.com/iocanel/clara
, version ? "0.1-SNAPSHOT"
}:

let
  quarkusRunJar = "${claraSrc}/cli/target/quarkus-app/quarkus-run.jar";

  claraWrapper = pkgs.writeShellScriptBin "clara" ''
    exec ${pkgs.temurin-bin-25}/bin/java -jar ${quarkusRunJar} "$@"
  '';

in
pkgs.symlinkJoin {
  name = "clara-cli-${version}";
  paths = [ claraWrapper ];

  meta = with lib; {
    description = "Clara CLI with MCP server support";
    homepage = "https://gitserver.silensec.com/iocanel/clara";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "clara";
    maintainers = [];
  };
}
