{ pkgs
, lib ? pkgs.lib
}:

let
  gws-flake = builtins.getFlake "github:googleworkspace/cli";
  gws = gws-flake.packages.${pkgs.system}.default;
in
pkgs.symlinkJoin {
  name = "gws-cli";
  paths = [ gws ];

  meta = with lib; {
    description = "Google Workspace CLI - unified access to all Google Workspace APIs";
    homepage = "https://github.com/googleworkspace/cli";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "gws";
    maintainers = [];
  };
}
