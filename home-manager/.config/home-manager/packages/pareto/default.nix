{ pkgs
, projectDir ? /home/iocanel/workspace/src/github.com/iocanel/pareto
}:

pkgs.stdenv.mkDerivation {
  pname = "pareto";
  version = "0.1.0";

  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    # Wrap uv run pareto, pinned to the project directory.
    # LD_LIBRARY_PATH is required on NixOS for numpy/pgvector C extensions.
    makeWrapper ${pkgs.uv}/bin/uv $out/bin/pareto \
      --chdir ${toString projectDir} \
      --add-flags "run pareto" \
      --set LD_LIBRARY_PATH "${pkgs.gcc-unwrapped.lib}/lib"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Scientific paper database with citation-based scoring and semantic search";
    homepage = "https://github.com/iocanel/pareto";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "pareto";
  };
}
