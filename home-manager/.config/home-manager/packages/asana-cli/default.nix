{ pkgs
, lib ? pkgs.lib
, version ? "999-SNAPSHOT"
}:

let
  src = /home/iocanel/workspace/src/gitserver.silensec.com/iocanel/asana-client;

in
pkgs.maven.buildMavenPackage {
  pname = "asana-cli";
  inherit version src;

  mvnHash = "sha256-qMsUlXMakzeySu0J4lZT/lY99Rf8aTXmjo7zE2TEErU=";

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
