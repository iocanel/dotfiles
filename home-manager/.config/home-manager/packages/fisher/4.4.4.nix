{ lib, buildFishPlugin, fetchFromGitHub }:

buildFishPlugin rec {
  pname = "fisher";
  version = "4.4.4";

  src = fetchFromGitHub {
    owner = "jorgebucaran";
    repo = "fisher";
    rev = version;
    hash = "sha256-e8gIaVbuUzTwKtuMPNXBT5STeddYqQegduWBtURLT3M=";
  };

  meta = with lib; {
    description = "A plugin manager for Fish";
    homepage = "https://github.com/jorgebucaran/fisher";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
