{ pkgs
, src ? null
, gitUrl ? "https://github.com/iocanel/glab-mr-tracker"
, gitRef ? "main"
}:

let
  actualSrc = if src != null then src else pkgs.fetchgit {
    url = gitUrl;
    ref = gitRef;
    sha256 = pkgs.lib.fakeSha256;
  };
in
pkgs.rustPlatform.buildRustPackage {
  pname = "glab-mr-tracker";
  version = "0.1.0";
  src = actualSrc;

  cargoLock.lockFile = "${actualSrc}/Cargo.lock";

  nativeBuildInputs = with pkgs; [ pkg-config ];

  # Uses rustls, no openssl needed
  buildInputs = with pkgs; [ ];

  meta = with pkgs.lib; {
    description = "MCP server for tracking GitLab merge requests requiring attention";
    homepage = "https://github.com/iocanel/glab-mr-tracker";
    license = licenses.mit;
    mainProgram = "glab-mr-tracker";
    platforms = platforms.unix;
  };
}
