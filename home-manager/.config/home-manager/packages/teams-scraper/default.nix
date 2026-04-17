{ pkgs
, lib ? pkgs.lib
, teamsSrc ? /home/iocanel/workspace/src/github.com/iocanel/scrappers/teams.microsoft.com
, version ? "0.1.0"
}:

let
  nodejs = pkgs.nodejs_20;

  teamsCli = pkgs.writeShellScriptBin "teams" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${teamsSrc}
    exec ${nodejs}/bin/node dist/cli.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "teams-scraper-${version}";
  paths = [ teamsCli ];

  meta = with lib; {
    description = "CLI to scrape chat dialogs from Microsoft Teams via browser automation";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "teams";
    maintainers = [];
  };
}
