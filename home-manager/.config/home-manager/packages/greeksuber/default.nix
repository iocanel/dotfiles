{ pkgs
, lib ? pkgs.lib
, greeksuberSrc ? /home/iocanel/workspace/src/github.com/iocanel/greeksuber
, version ? "0.1.0"
}:

let
  # Pin nixpkgs so the CUDA stack (torch, ctranslate2) is not recompiled on every
  # channel bump. This commit matches what these packages were first built against;
  # bump it deliberately when you want newer CUDA builds (and accept the rebuild).
  pinnedNixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/3c9db02515ef1d9b6b709fc60ba9a540957f661c.tar.gz";
  };

  cudaPkgs = import pinnedNixpkgs {
    inherit (pkgs) system;
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };

  # faster-whisper does its GPU work via ctranslate2 (CUDA); its onnxruntime
  # dependency is only the CPU-side VAD. Feed it the non-CUDA onnxruntime so we
  # use the cached build instead of compiling onnxruntime-cuda from source.
  cpuPkgs = import pinnedNixpkgs {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
  fasterWhisperCpuOnnx = cudaPkgs.python312Packages.faster-whisper.override {
    onnxruntime = cpuPkgs.python312Packages.onnxruntime;
  };

  pythonEnv = cudaPkgs.python312.withPackages (ps: with ps; [
    torch
    transformers
    sentencepiece
    sacremoses
    tqdm
    pysrt
    ffmpeg-python
    fasterWhisperCpuOnnx
    openai-whisper
    rapidfuzz
  ]);

  greeksuberWrapper = pkgs.writeShellScriptBin "greeksuber" ''
    unset LD_LIBRARY_PATH
    export PATH="${lib.makeBinPath [ pkgs.ffmpeg ]}:$PATH"
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
