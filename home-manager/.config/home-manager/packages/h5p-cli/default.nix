{ pkgs
, lib ? pkgs.lib
, version ? "1.1.5"
}:

let
  npmTarball = pkgs.fetchurl {
    url = "https://registry.npmjs.org/h5p-cli/-/h5p-cli-${version}.tgz";
    sha256 = "sha256-SBybOyHyPpQwAfdjTlhpH6f/T+H3cX7S7byldgM8u0g=";
  };

  src = pkgs.runCommand "h5p-cli-src-${version}" {} ''
    mkdir -p $out
    tar -xzf ${npmTarball} --strip-components=1 -C $out
    cp ${./package-lock.json} $out/package-lock.json
  '';

in
pkgs.buildNpmPackage {
  pname = "h5p-cli";
  inherit version src;

  npmDepsHash = "sha256-t47NKOor4GdN+wzHdP+MTRuz/+/4uWL1RWedixH7fcA=";

  dontNpmBuild = true;
  npmInstallFlags = [ "--ignore-scripts" ];

  meta = with lib; {
    description = "H5P CLI tool for managing H5P content types and libraries";
    homepage = "https://github.com/h5p/h5p-cli";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "h5p";
    maintainers = [];
  };
}
