{ pkgs
, lib ? pkgs.lib
, version ? "1.0.0-SNAPSHOT"
}:

let
  src = /home/iocanel/workspace/src/github.com/iocanel/fuseki-cli;

in
pkgs.maven.buildMavenPackage {
  pname = "fuseki-cli";
  inherit version src;

  mvnHash = "sha256-Gs52oxjM3OeKRjbOz9fdnonovmAm3FHvAK8XFRZlBRU=";

  mvnJdk = pkgs.temurin-bin-21;

  nativeBuildInputs = [
    pkgs.graalvmPackages.graalvm-ce
  ];

  mvnParameters = "-Pnative -DskipTests --no-transfer-progress -Dquarkus.native.graalvm-home=${pkgs.graalvmPackages.graalvm-ce}";

  installPhase = ''
    mkdir -p $out/bin
    cp target/fuseki-${version}-runner $out/bin/fuseki
    chmod +x $out/bin/fuseki
  '';

  meta = with lib; {
    description = "MCP server for Apache Jena Fuseki";
    homepage = "https://github.com/iocanel/fuseki-cli";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "fuseki";
    maintainers = [];
  };
}
