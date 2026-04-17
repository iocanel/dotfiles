{ pkgs
, lib ? pkgs.lib
, version ? "0.1-SNAPSHOT"
}:

let
  src = /home/iocanel/workspace/src/gitserver.silensec.com/iocanel/clara;

  mavenRepository = pkgs.stdenvNoCC.mkDerivation {
    name = "clara-cli-maven-deps";
    src = /home/iocanel/.m2/repository;
    dontUnpack = true;
    dontFixup = true;
    installPhase = ''
      cp -r $src $out
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-vyglF0MqR3N/KrpT52OVtK7wdlwGl1CnCxIG8YCUoVo=";
  };

in
pkgs.stdenvNoCC.mkDerivation {
  pname = "clara-cli";
  inherit version src;

  nativeBuildInputs = [
    pkgs.temurin-bin-21
    pkgs.graalvmPackages.graalvm-ce
    pkgs.maven
  ];

  buildPhase = ''
    export JAVA_HOME=${pkgs.temurin-bin-21}
    export PATH=${pkgs.temurin-bin-21}/bin:$PATH

    # Maven needs a writable local repo; copy from read-only store
    cp -r ${mavenRepository} $TMPDIR/repo
    chmod -R u+w $TMPDIR/repo
    # Remove remote tracking markers so Maven treats all artifacts as local
    find $TMPDIR/repo -name "_remote.repositories" -delete

    mvn package -Pnative \
      -pl cli -am \
      -DskipTests \
      -Dmaven.repo.local=$TMPDIR/repo \
      --no-transfer-progress \
      --offline \
      -Dquarkus.native.graalvm-home=${pkgs.graalvmPackages.graalvm-ce}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp cli/target/clara-cli-${version}-runner $out/bin/clara
    chmod +x $out/bin/clara
  '';

  meta = with lib; {
    description = "Clara CLI with MCP server support";
    homepage = "https://gitserver.silensec.com/iocanel/clara";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "clara";
    maintainers = [];
  };
}
