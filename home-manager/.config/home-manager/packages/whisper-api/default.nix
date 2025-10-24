{ lib
, writeShellApplication
, curl
, jq
, ffmpeg
, coreutils
, gawk
}:

writeShellApplication {
  name = "whisper-api";

  # Tools your script calls will be on PATH at runtime:
  runtimeInputs = [ curl jq ffmpeg coreutils gawk ];

  # Read the script from the neighboring file (no ${} escaping required):
  text = builtins.readFile ./whisper-api.sh;

  meta = {
    description = "CLI wrapper to transcribe via OpenAI /v1/audio/transcriptions (splitting, merging, sane output)";
    mainProgram = "whisper-api";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
