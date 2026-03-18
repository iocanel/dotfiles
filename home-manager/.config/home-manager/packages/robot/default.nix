{ pkgs, lib, ... }:

let
  version = "1.9.10";

  robotJar = pkgs.fetchurl {
    url = "https://github.com/ontodev/robot/releases/download/v${version}/robot.jar";
    sha256 = "01b1fzm1k5kfg6wip4vz243gx1c7g3hb914a6fkmkwrx9w3kr9qn";
  };

  robotWrapper = pkgs.writeShellScriptBin "robot" ''
    exec ${pkgs.jdk}/bin/java -jar ${robotJar} "$@"
  '';

in
pkgs.symlinkJoin {
  name = "robot-${version}";
  paths = [ robotWrapper ];

  meta = with lib; {
    description = "ROBOT is an OBO Tool for ontology editing and processing";
    homepage = "https://github.com/ontodev/robot";
    license = licenses.bsd3;
    platforms = platforms.all;
    maintainers = [];
  };
}
