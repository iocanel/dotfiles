{
  description = "AltaCV LaTeX template";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages.altacv = pkgs.stdenv.mkDerivation {
        pname = "altacv";
        version = "latest";
        src = pkgs.fetchFromGitHub {
          owner = "liantze";
          repo = "AltaCV";
        };

        buildInputs = [ pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-medium biblatex biber pgfplots xifthen xstring;
        } ];

        installPhase = ''
          mkdir -p $out/share/texmf/tex/latex/altacv
          cp -r * $out/share/texmf/tex/latex/altacv
          texhash $out/share/texmf
        '';
      };
    });
}
