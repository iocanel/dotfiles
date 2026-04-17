{ pkgs
, lib ? pkgs.lib
, version ? "0.35.0"
}:

let
  src = pkgs.fetchurl {
    url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "30c852a6f415a8a270aaa333c614bb02dfd0d60bc57af382f5bb44c3b61a6ff9";
  };

in pkgs.stdenv.mkDerivation {
  pname = "rtk";
  inherit version src;

  nativeBuildInputs = [ pkgs.gnutar ];

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp rtk $out/bin/rtk
    chmod +x $out/bin/rtk
  '';

  meta = with lib; {
    description = "High-performance CLI proxy that reduces LLM token consumption by filtering command output";
    homepage = "https://github.com/rtk-ai/rtk";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "rtk";
    maintainers = [];
  };
}
