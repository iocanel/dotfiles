{ pkgs
, src ? null
, gitUrl ? "https://github.com/iocanel/org-cli"
, gitRef ? "main"
}:

let
  # If src is provided, use it; otherwise fetch from git
  actualSrc = if src != null then src else pkgs.fetchgit {
    url = gitUrl;
    ref = gitRef;
    # This will need to be updated when the repo is pushed
    # For now, use local source by passing src argument
    sha256 = pkgs.lib.fakeSha256;
  };
in
pkgs.rustPlatform.buildRustPackage {
  pname = "org-cli";
  version = "0.1.0";
  src = actualSrc;

  cargoLock.lockFile = "${actualSrc}/Cargo.lock";

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ openssl ];

  meta = with pkgs.lib; {
    description = "CLI and MCP server for org-agenda and org-roam integration";
    homepage = "https://github.com/iocanel/org-cli";
    license = licenses.mit;
    mainProgram = "org-cli";
    platforms = platforms.unix;
  };
}
