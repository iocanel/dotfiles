{ lib
, writeShellApplication
, curl
, coreutils
, findutils
, bash
}:

writeShellApplication {
  name = "grab";

  # Tools your script calls will be on PATH at runtime:
  runtimeInputs = [ curl coreutils findutils bash ];

  # Disable shellcheck for this legacy script
  checkPhase = "";

  # Read the script from the neighboring file:
  text = builtins.readFile ./grab.sh;

  meta = {
    description = "Shellib grab tool for downloading and caching shell libraries from GitHub";
    mainProgram = "grab";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}