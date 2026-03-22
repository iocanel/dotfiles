{ pkgs
, lib ? pkgs.lib
, greeksuberSrc ? /home/iocanel/workspace/src/github.com/iocanel/greeksuber
, version ? "0.1.0"
}:

let
  pythonEnv = pkgs.python312.withPackages (ps: with ps; [
    torch
    transformers
    sentencepiece
    sacremoses
    tqdm
    pysrt
    ffmpeg-python
    faster-whisper
    openai-whisper
    rapidfuzz
  ]);

  greeksuberWrapper = pkgs.writeShellScriptBin "greeksuber" ''
    export PYTHONPATH="${greeksuberSrc}/src:$PYTHONPATH"
    exec ${pythonEnv}/bin/python -m greeksuber "$@"
  '';

in
pkgs.symlinkJoin {
  name = "greeksuber-${version}";
  paths = [ greeksuberWrapper ];

  meta = with lib; {
    description = "CLI tool for creating Greek subtitles from videos using Whisper and MarianMT";
    homepage = "https://github.com/iocanel/greeksuber";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "greeksuber";
    maintainers = [];
  };
}
