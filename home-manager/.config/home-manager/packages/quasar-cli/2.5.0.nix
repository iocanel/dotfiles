{ config, pkgs, ... }:

let
  # Quasar CLI is published on npm as @quasar/cli. :contentReference[oaicite:1]{index=1}
  quasar-cli = pkgs.buildNpmPackage rec {
    pname = "quasar-cli";
    version = "2.5.0"; # update as you like (keep hashes in sync)

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@quasar/cli/-/cli-${version}.tgz";
      # 1) put lib.fakeSha256 here first
      # 2) run: home-manager switch (or nix build)
      # 3) replace with the “got: sha256-...” value from the error
      sha256 = "sha256-00gd6pi5jn36slhm4llmh3irb31qhqsahhr5xj1b6329hdkkdw0m";
    };

    # Same workflow as sha256 above: start with fake, build once, paste the real one.
    npmDepsHash = pkgs.lib.fakeSha256;

    # Quasar CLI is a CLI tool; usually no “build” step is needed beyond deps install.
    # If you hit issues, try removing this line.
    dontNpmBuild = true;
  };
in
{
  home.packages = [
    pkgs.nodejs_20
    quasar-cli
  ];
}
