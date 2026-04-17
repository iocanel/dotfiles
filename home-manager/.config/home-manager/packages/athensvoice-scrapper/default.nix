{ pkgs
, lib ? pkgs.lib
, version ? "0.1.0"
}:

let
  # Use string path to avoid nix copying to store (allows local node_modules updates)
  athensvoiceSrc = "/home/iocanel/workspace/src/github.com/iocanel/scrappers/athensvoice.gr";

  # Uses 'node' from PATH to match the node_modules build
  athensvoiceCli = pkgs.writeShellScriptBin "athensvoice" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${athensvoiceSrc}
    exec node dist/cli.js "$@"
  '';

  athensvoiceMcp = pkgs.writeShellScriptBin "athensvoice-mcp" ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    cd ${athensvoiceSrc}
    exec node dist/mcp.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "athensvoice-scrapper-${version}";
  paths = [ athensvoiceCli athensvoiceMcp ];

  meta = with lib; {
    description = "CLI and MCP server for athensvoice.gr - Athens lifestyle and culture";
    homepage = "https://github.com/iocanel/scrappers";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "athensvoice";
    maintainers = [];
  };
}
