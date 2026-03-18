{ pkgs
, lib ? pkgs.lib
, version ? "1.0.0-SNAPSHOT"
}:

let
  fusekiWrapper = pkgs.writeShellScriptBin "fuseki" ''
    exec ${pkgs.jdk17}/bin/java -jar /home/iocanel/workspace/src/github.com/iocanel/fuseki-cli/target/fuseki-${version}-runner.jar "$@"
  '';

in
pkgs.symlinkJoin {
  name = "fuseki-${version}";
  paths = [ fusekiWrapper ];

  meta = with lib; {
    description = "MCP server for Apache Jena Fuseki";
    homepage = "https://github.com/iocanel/fuseki-cli";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "fuseki";
    maintainers = [];
  };
}
