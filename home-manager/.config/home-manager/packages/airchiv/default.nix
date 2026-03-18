{ pkgs
, lib ? pkgs.lib
, airchivSrc ? /home/iocanel/workspace/src/github.com/iocanel/airchiv
, version ? "0.1.0"
}:

let
  binaryPath = "${airchivSrc}/target/release/airchiv";

  airchivWrapper = pkgs.writeShellScriptBin "airchiv" ''
    exec ${binaryPath} "$@"
  '';

in
pkgs.symlinkJoin {
  name = "airchiv-${version}";
  paths = [ airchivWrapper ];

  meta = with lib; {
    description = "A local semantic archive for your knowledge";
    homepage = "https://github.com/iocanel/airchiv";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "airchiv";
    maintainers = [];
  };
}
