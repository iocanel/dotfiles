{ pkgs
, lib ? pkgs.lib
, version ? "0.1-SNAPSHOT"
}:

let
  src = /home/iocanel/workspace/src/github.com/iocanel/apis/asana-client;

in
pkgs.maven.buildMavenPackage {
  pname = "asana-cli";
  inherit version src;

  mvnHash = "sha256-lv2XZCv5IL+uTd1EWwyaaG1MD2AYZsEIIT6aHd60+wY=";

  mvnJdk = pkgs.temurin-bin-21;

  nativeBuildInputs = [
    pkgs.graalvmPackages.graalvm-ce
  ];

  mvnParameters = "-Pnative -pl cli -am -DskipTests --no-transfer-progress -Dquarkus.native.graalvm-home=${pkgs.graalvmPackages.graalvm-ce}";

  installPhase = ''
    mkdir -p $out/bin
    cp cli/target/asana-cli-${version}-runner $out/bin/asana
    chmod +x $out/bin/asana
  '';

  meta = with lib; {
    description = "Asana CLI client with MCP server support";
    homepage = "https://github.com/iocanel/apis";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "asana";
    maintainers = [];
  };
}
