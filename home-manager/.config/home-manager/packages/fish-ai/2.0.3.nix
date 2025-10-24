{ lib, buildFishPlugin, fetchFromGitHub, python3, makeWrapper }:

buildFishPlugin rec {
  pname = "fish-ai";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "Realiserad";
    repo = "fish-ai";
    rev = version;
    hash = "sha256-leajpGBLLCzchFmeauJpJYgPMvHOTJwGBHwhAqyW4/M=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    # Copy Python library
    mkdir -p $out/lib/fish-ai
    cp -r src/fish_ai $out/lib/fish-ai/

    # Wrap Python entry points
    mkdir -p $out/bin
    for tool in codify explain fix lookup_setting put_api_key redact switch_context; do
      makeWrapper ${python3.interpreter} $out/bin/$tool \
        --add-flags "$out/lib/fish-ai/$tool.py"
    done
  '';

  meta = with lib; {
    description = "AI-powered CLI tools for the fish shell";
    homepage = "https://github.com/Realiserad/fish-ai";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
